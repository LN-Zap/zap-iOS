
/**  The CardView class defines the attributes and behavior of the cards that appear in WalletView objects. */
open class CardView: UIView {
    
    // MARK: Public methods
    
    /**
     Initializes and returns a newly allocated card view object with the specified frame rectangle.
     
     - parameter aRect: The frame rectangle for the card view, measured in points.
     - returns: An initialized card view.
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }
    
    /**
     Returns a card view object initialized from data in a given unarchiver.
     
     - parameter aDecoder: An unarchiver object.
     - returns: A card view, initialized using the data in decoder.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestures()
    }
    
    /**  A Boolean value that determines whether the view is presented. */
    open var presented: Bool = false
    
    
    /**  A parent wallet view object, or nil if the card view is not visible. */
    public var walletView: WalletView? {
        return container()
    }
    
    /** This method is called when the card view is tapped. */
    @objc open func tapped() {
        if let _ = walletView?.presentedCardView {
            walletView?.dismissPresentedCardView(animated: true)
        } else {
            walletView?.present(cardView: self, animated: true)
        }
    }
    
    /** This method is called when the card view is panned. */
    @objc open func panned(gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            walletView?.grab(cardView: self, popup: false)
        case .changed:
            updateGrabbedCardViewOffset(gestureRecognizer: gestureRecognizer)
        default:
            walletView?.releaseGrabbedCardView()
        }
        
    }
    
    /** This method is called when the card view is long pressed. */
    @objc open func longPressed(gestureRecognizer: UILongPressGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            walletView?.grab(cardView: self, popup: true)
        case .changed: ()
        default:
            walletView?.releaseGrabbedCardView()
        }
        
        
    }
    
    // MARK: Private methods
    
    let tapGestureRecognizer    = UITapGestureRecognizer()
    let panGestureRecognizer    = UIPanGestureRecognizer()
    let longGestureRecognizer   = UILongPressGestureRecognizer()
    
    func setupGestures() {
        
        tapGestureRecognizer.addTarget(self, action: #selector(CardView.tapped))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
        
        panGestureRecognizer.addTarget(self, action: #selector(CardView.panned(gestureRecognizer:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
        
        longGestureRecognizer.addTarget(self, action: #selector(CardView.longPressed(gestureRecognizer:)))
        longGestureRecognizer.delegate = self
        addGestureRecognizer(longGestureRecognizer)
        
    }
    
    
    func updateGrabbedCardViewOffset(gestureRecognizer: UIPanGestureRecognizer) {
        let offset = gestureRecognizer.translation(in: walletView).y
        if presented && offset > 0 {
            walletView?.updateGrabbedCardView(offset: offset)
        } else if !presented {
            walletView?.updateGrabbedCardView(offset: offset)
        }
    }
    
}

extension CardView: UIGestureRecognizerDelegate {
    
    /**
     Asks the delegate if a gesture recognizer should begin interpreting touches.
     
     - parameter gestureRecognizer: An instance of a subclass of the abstract base class UIGestureRecognizer. This gesture-recognizer object is about to begin processing touches to determine if its gesture is occurring.
     */
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == longGestureRecognizer && presented {
            return false
        } else if gestureRecognizer == panGestureRecognizer && !presented && walletView?.grabbedCardView != self {
            return false
        }
        
        return true
        
    }
    
    /**
     Asks the delegate if two gesture recognizers should be allowed to recognize gestures simultaneously.
     
     - parameter gestureRecognizer: An instance of a subclass of the abstract base class UIGestureRecognizer. This gesture-recognizer object is about to begin processing touches to determine if its gesture is occurring.
     - parameter otherGestureRecognizer: An instance of a subclass of the abstract base class UIGestureRecognizer.

     */
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer != tapGestureRecognizer && otherGestureRecognizer != tapGestureRecognizer
    }
    
    
}

internal extension UIView {
    
    func container<T: UIView>() -> T? {
        
        var view = superview
        
        while view != nil {
            if let view = view as? T {
                return view
            }
            view = view?.superview
        }
        
        return nil
    }
    
}
