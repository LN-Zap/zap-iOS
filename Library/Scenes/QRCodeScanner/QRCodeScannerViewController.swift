//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Lightning
import SwiftBTC
import UIKit

class QRCodeScannerViewController: UIViewController {
    // swiftlint:disable implicitly_unwrapped_optional
    private weak var scannerView: QRCodeScannerView!
    weak var pasteButton: UIButton!
    // swiftlint:enable implicitly_unwrapped_optional

    private let strategy: QRCodeScannerStrategy

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(strategy: QRCodeScannerStrategy) {
        self.strategy = strategy
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        title = strategy.title

        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped(_:)))

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Asset.iconFlashlight.image, style: .plain, target: self, action: #selector(toggleTorch))

        setupScannerView()
        setupPasteButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        scannerView.presentWarningIfAccessDenied(on: self)
    }

    private func setupScannerView() {
        let scannerView = QRCodeScannerView(frame: .zero)
        view.addAutolayoutSubview(scannerView)
        scannerView.constrainEdges(to: view)

        scannerView.handler = { [weak self] address in
            self?.tryPresentingViewController(for: address)
        }

        self.scannerView = scannerView
    }

    private func setupPasteButton() {
        let pasteButton = UIButton(type: .system)
        pasteButton.setTitle(strategy.pasteButtonTitle, for: .normal)
        Style.Button.background.apply(to: pasteButton)

        view.addAutolayoutSubview(pasteButton)

        NSLayoutConstraint.activate([
            pasteButton.heightAnchor.constraint(equalToConstant: 56),
            pasteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: pasteButton.trailingAnchor, constant: 20),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: pasteButton.bottomAnchor, constant: 20)
        ])

        pasteButton.addTarget(self, action: #selector(pasteButtonTapped(_:)), for: .touchUpInside)

        self.pasteButton = pasteButton
    }

    func tryPresentingViewController(for address: String) {
        strategy.viewControllerForAddress(address: address) { [weak self] result in
            DispatchQueue.main.async {
                self?.pasteButton.isEnabled = true
                switch result {
                case .success(let viewController):
                    self?.presentViewController(viewController)
                    self?.scannerView.stop()
                    UISelectionFeedbackGenerator().selectionChanged()
                case .failure(let error):
                    self?.presentError(message: error.message)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }

    func presentViewController(_ viewController: UIViewController) {
        if let modalDetailViewController = viewController as? ModalDetailViewController {
            modalDetailViewController.delegate = self
        }
        
        present(viewController, animated: true)
    }

    @objc private func pasteButtonTapped(_ sender: Any) {
        if let pasteboardContent = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) {
            pasteButton.isEnabled = false
            tryPresentingViewController(for: pasteboardContent)
        } else {
            presentError(message: L10n.Generic.Pasteboard.invalidAddress)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    @objc private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func toggleTorch() {
        scannerView.toggleTorch()
    }
}

extension QRCodeScannerViewController: ModalDetailViewControllerDelegate {
    func childWillDisappear() {
        scannerView.start()
    }

    func presentError(message: String) {
        Toast.presentError(message)
    }
}
