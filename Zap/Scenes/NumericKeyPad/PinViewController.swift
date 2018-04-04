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
        
        //        BiometricAuthentication.authenticate()
        //            .observeOn(MainScheduler.instance)
        //            .subscribe(onCompleted: {
        //                AuthenticationViewModel.instance.authenticated.onNext(true)
        //            }, onError: { [weak self] error in
        //                self?.displayError(error.localizedDescription)
        //            })
        //            .dispose(in: reactive.bag)
        //
        //        viewModel.authenticated
        //            .bind(to: activityIndicator.rx.isAnimating)
        //            .dispose(in: reactive.bag)
        //
        //        viewModel.authenticated
        //            .bind(to: pinStackView.rx.isHidden)
        //            .dispose(in: reactive.bag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let numPad = segue.destination as? NumericKeyPadViewController {
//            let viewModel = AuthenticationViewModel.instance
            
            numPad.view.backgroundColor = .clear
            numPad.textColor = .white
//            numPad.maxLength = viewModel.pin?.count ?? 0
            numPad.isPin = true
//            numPad.handler = { [weak self] number in
//                guard let imageViews = self?.pinStackView.arrangedSubviews else { return }
//
//                for (count, view) in imageViews.enumerated() {
//                    view.tintColor = count < number.count ? .white : .black
//                }
//
//                if number == viewModel.pin {
//                    self?.viewModel.authenticated.onNext(true)
//                }
//            }
        }
    }
}
