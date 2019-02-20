//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Lightning
import SafariServices
import UIKit

final class ConnectCellBond: TableViewBinder<Observable2DArray<String?, ConnectRemoteNodeViewModel.CellType>> {
    
    override init() {
        super.init()
        rowAnimation = .fade
    }
    
    private func dequeueCell(for tableView: UITableView, style: UITableViewCell.CellStyle) -> UITableViewCell {
        let reuseIdentifier = String(style.rawValue)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
            return cell
        } else {
            let cell = UITableViewCell(style: style, reuseIdentifier: reuseIdentifier)

            cell.imageView?.image = nil
            cell.imageView?.tintColor = .white
            cell.backgroundColor = UIColor.Zap.seaBlue

            if let cellTextLabel = cell.textLabel {
                Style.Label.custom().apply(to: cellTextLabel)
                cellTextLabel.textColor = .white
            }
            
            return cell
        }
    }
    
    override func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<String?, ConnectRemoteNodeViewModel.CellType>) -> UITableViewCell {

        let cellType = dataSource.item(at: indexPath)
        let cell: UITableViewCell
        
        switch cellType {
        case .emptyState:
            cell = dequeueCell(for: tableView, style: .default)
            cell.textLabel?.text = L10n.Scene.ConnectRemoteNode.emptyState
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none
        case .address(let urlString):
            cell = dequeueCell(for: tableView, style: .value1)
            cell.textLabel?.text = L10n.Scene.ConnectRemoteNode.urlLabel
            cell.detailTextLabel?.text = urlString
            cell.accessoryType = .disclosureIndicator
        case .certificate(let certificateString):
            cell = dequeueCell(for: tableView, style: .value1)
            cell.textLabel?.text = L10n.Scene.ConnectRemoteNode.certificateLabel
            cell.detailTextLabel?.text = certificateString
            cell.accessoryType = .disclosureIndicator
        case .connect:
            cell = dequeueCell(for: tableView, style: .default)
            cell.textLabel?.text = L10n.Scene.ConnectRemoteNode.connectButton
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.Zap.lightningOrange
        case .scan:
            cell = dequeueCell(for: tableView, style: .default)
            cell.textLabel?.text = L10n.Scene.ConnectRemoteNode.scanButton
            cell.imageView?.image = Asset.iconQrCode.image
        case .paste:
            cell = dequeueCell(for: tableView, style: .default)
            cell.textLabel?.text = L10n.Scene.ConnectRemoteNode.pasteButton
            cell.imageView?.image = Asset.iconCopy.image
        case .help:
            cell = dequeueCell(for: tableView, style: .default)
            cell.textLabel?.text = L10n.Scene.ConnectRemoteNode.helpButton
        }
        
        return cell
    }
}

final class ConnectRemoteNodeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var presentQRCodeScannerButtonTapped: (() -> Void)?
    private var didSetupWallet: ((WalletConfiguration) -> Void)?
    private var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    
    private var isConnecting = false
    
    static func instantiate(didSetupWallet: @escaping (WalletConfiguration) -> Void, connectRemoteNodeViewModel: ConnectRemoteNodeViewModel, presentQRCodeScannerButtonTapped: @escaping (() -> Void)) -> ConnectRemoteNodeViewController {
        let viewController = StoryboardScene.ConnectRemoteNode.connectRemoteNodeViewController.instantiate()
        viewController.didSetupWallet = didSetupWallet
        viewController.connectRemoteNodeViewModel = connectRemoteNodeViewModel
        viewController.presentQRCodeScannerButtonTapped = presentQRCodeScannerButtonTapped
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.Scene.ConnectRemoteNode.title
        
        tableView.delegate = self
        tableView.backgroundColor = UIColor.Zap.deepSeaBlue
        tableView.separatorColor = UIColor.Zap.gray
        tableView.reactive.dataSource.forwardTo = self
                
        connectRemoteNodeViewModel?.dataSource
            .bind(to: tableView, using: ConnectCellBond())
            .dispose(in: reactive.bag)
    }
    
    private func displayError(_ error: Error) {
        DispatchQueue.main.async {
            Toast.presentError("\(L10n.Scene.ConnectRemoteNode.serverError) (\(error.localizedDescription))")
        }
    }
    
    private func presentHelp() {
        guard let url = URL(string: L10n.Link.Help.zapconnect) else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor.Zap.deepSeaBlue
        safariViewController.preferredControlTintColor = UIColor.Zap.lightningOrange
        present(safariViewController, animated: true, completion: nil)
    }
    
    private func connect(cell: UITableViewCell) {
        guard !isConnecting else { return }
        isConnecting = true
        
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.startAnimating()
        cell.addAutolayoutSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ])
        
        cell.textLabel?.isHidden = true
        
        connectRemoteNodeViewModel?.connect { [weak self] configuration, result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.didSetupWallet?(configuration)
                case .failure(let error):
                    self?.displayError(error)
                }
                
                activityIndicator.removeFromSuperview()
                cell.textLabel?.isHidden = false
                self?.isConnecting = false
            }
        }
    }
    
    private func presentAddressDetail() {
        guard let viewModel = connectRemoteNodeViewModel else { return }
        let viewController = UpdateAddressViewController.instantiate(connectRemoteNodeViewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentCertificateDetail() {
        guard let viewModel = connectRemoteNodeViewModel else { return }
        let viewController = CertificateDetailViewController.instantiate(connectRemoteNodeViewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func paste() {
        if let pasteboardContent = UIPasteboard.general.string {
            connectRemoteNodeViewModel?.pasteCertificates(pasteboardContent) { result in
                switch result {
                case .success:
                    Toast.presentSuccess(L10n.RpcConnectQrcodeError.codeUpdated)
                case .failure(let error):
                    Toast.presentError(error.localizedDescription)
                }
            }
        } else {
            Toast.presentError(L10n.RpcConnectQrcodeError.cantReadQrcode)
        }
    }
}

extension ConnectRemoteNodeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let connectRemoteNodeViewModel = connectRemoteNodeViewModel else { return }
        let cellType = connectRemoteNodeViewModel.dataSource[indexPath]
        
        switch cellType {
        case .address:
            presentAddressDetail()
        case .certificate:
            presentCertificateDetail()
        case .help:
            presentHelp()
        case .scan:
            presentQRCodeScannerButtonTapped?()
        case .paste:
            paste()
        case .connect:
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            connect(cell: cell)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellHeight: CGFloat = 76
        
        guard let connectRemoteNodeViewModel = connectRemoteNodeViewModel else { return cellHeight }
        if case .emptyState = connectRemoteNodeViewModel.dataSource[indexPath] {
            return cellHeight * 3
        } else {
            return cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        view.textLabel?.text = connectRemoteNodeViewModel?.dataSource[section].metadata
    }
}

extension ConnectRemoteNodeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("not implemented")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("not implemented")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return connectRemoteNodeViewModel?.dataSource[section].metadata
    }
}
