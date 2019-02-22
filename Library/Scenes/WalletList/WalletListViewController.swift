//
//  Library
//
//  Created by Otto Suess on 13.02.19.
//  Copyright © 2019 Zap. All rights reserved.
//

import UIKit

final class WalletListViewController: ModalDetailViewController {
    private let walletConfigurationStore: WalletConfigurationStore
    private var configurations = [UITapGestureRecognizer: WalletConfiguration]()
    private weak var disconnectWalletDelegate: DisconnectWalletDelegate?
    
    init(walletConfigurationStore: WalletConfigurationStore, disconnectWalletDelegate: DisconnectWalletDelegate) {
        self.walletConfigurationStore = walletConfigurationStore
        self.disconnectWalletDelegate = disconnectWalletDelegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentStackView.addArrangedElement(.label(text: L10n.Scene.WalletList.title, style: Style.Label.headline.with({ $0.textAlignment = .center })))
        
        for configuration in walletConfigurationStore.configurations {
            addWalletConfiguration(configuration)
        }

    }
    
    private func isSelectedConfiguration(_ configuration: WalletConfiguration) -> Bool {
        return configuration == walletConfigurationStore.selectedWallet
    }
    
    func addWalletConfiguration(_ configuration: WalletConfiguration) {
        contentStackView.addArrangedElement(.separator)
        var horizontalStackViewContent: [StackViewElement] = [
            .verticalStackView(content: [
                .label(text: configuration.alias ?? "?", style: Style.Label.body),
                .label(text: configuration.network?.localized ?? "?", style: Style.Label.subHeadline)
            ], spacing: 4)
        ]
        
        if isSelectedConfiguration(configuration) {
            let imageView = UIImageView(image: Asset.iconCheckGreen.image)
            imageView.contentMode = .scaleAspectFit
            horizontalStackViewContent.append(.customView(imageView))
        }
        
        let configurationCell = contentStackView.addArrangedElement(.horizontalStackView(compressionResistant: .last, content: horizontalStackViewContent))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        configurationCell.addGestureRecognizer(tapGestureRecognizer)
        
        configurations[tapGestureRecognizer] = configuration
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard
            let configuration = configurations[sender],
            !isSelectedConfiguration(configuration)
            else { return }
        
        disconnectWalletDelegate?.reconnect(walletConfiguration: configuration)
        dismiss(animated: true, completion: nil)
    }
}
