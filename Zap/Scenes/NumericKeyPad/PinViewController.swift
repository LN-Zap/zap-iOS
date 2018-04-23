//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import UIKit

class PinViewController: UIViewController {
    
    @IBOutlet private weak var pinStackView: UIStackView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = AuthenticationViewModel.instance
                
        view.backgroundColor = Color.darkBackground
        
        for _ in (0..<(viewModel.pin?.count ?? 0)) {
            let imageView = UIImageView(image: #imageLiteral(resourceName: "pin-circle"))
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .black
            pinStackView.addArrangedSubview(imageView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let numPad = segue.destination as? NumericKeyPadViewController {
            numPad.view.backgroundColor = .clear
            numPad.textColor = .white
            numPad.isPin = true
        
            numPad.handler = { [weak self] number in
                self?.updatePinView(for: number)
                return (AuthenticationViewModel.instance.pin?.count ?? Int.max) >= number.count
            }
        }
    }
    
    private func updatePinView(for string: String) {
        let imageViews = pinStackView.arrangedSubviews
        for (count, view) in imageViews.enumerated() {
            view.tintColor = count < string.count ? .white : .black
        }
    }
}
