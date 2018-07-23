//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import SafariServices
import UIKit

extension UIStoryboard {
    static func instantiateConnectRemoteNodeViewController(didSetupWallet: @escaping () -> Void, connectRemoteNodeViewModel: ConnectRemoteNodeViewModel, presentQRCodeScannerButtonTapped: @escaping (() -> Void)) -> ConnectRemoteNodeViewController {
        let viewController = Storyboard.connectRemoteNode.initial(viewController: ConnectRemoteNodeViewController.self)
        viewController.didSetupWallet = didSetupWallet
        viewController.connectRemoteNodeViewModel = connectRemoteNodeViewModel
        viewController.presentQRCodeScannerButtonTapped = presentQRCodeScannerButtonTapped
        return viewController
    }
}

final class ConnectCellBond: TableViewBinder<Observable2DArray<String?, ConnectRemoteNodeViewModel.CellType>> {
    
    override init() {
        super.init()
        rowAnimation = .fade
    }
    
    private func dequeueCell(for tableView: UITableView, style: UITableViewCellStyle) -> UITableViewCell {
        let reuseIdentifier = String(style.rawValue)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
            return cell
        } else {
            let cell = UITableViewCell(style: style, reuseIdentifier: reuseIdentifier)

            cell.imageView?.image = nil
            cell.imageView?.tintColor = .white
            cell.backgroundColor = UIColor.zap.charcoalGreyLight

            if let cellTextLabel = cell.textLabel {
                Style.label.apply(to: cellTextLabel)
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
            cell.textLabel?.text = "scene.connect_remote_node.empty_state".localized
            cell.textLabel?.textColor = .lightGray
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none
        case .address(let urlString):
            cell = dequeueCell(for: tableView, style: .value1)
            cell.textLabel?.text = "scene.connect_remote_node.url_label".localized
            cell.detailTextLabel?.text = urlString
            cell.accessoryType = .disclosureIndicator
        case .certificate(let certificateString):
            cell = dequeueCell(for: tableView, style: .value1)
            cell.textLabel?.text = "scene.connect_remote_node.certificate_label".localized
            cell.detailTextLabel?.text = certificateString
            cell.accessoryType = .disclosureIndicator
        case .connect:
            cell = dequeueCell(for: tableView, style: .default)
            cell.textLabel?.text = "scene.connect_remote_node.connect_button".localized
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.zap.peach
        case .scan:
            cell = dequeueCell(for: tableView, style: .default)
            cell.textLabel?.text = "scene.connect_remote_node.scan_button".localized
            cell.imageView?.image = UIImage(named: "icon_qr_code", in: .library, compatibleWith: nil)
        case .paste:
            cell = dequeueCell(for: tableView, style: .default)
            cell.textLabel?.text = "scene.connect_remote_node.paste_button".localized
            cell.imageView?.image = UIImage(named: "icon_copy", in: .library, compatibleWith: nil)
        case .help:
            cell = dequeueCell(for: tableView, style: .default)
            cell.textLabel?.text = "scene.connect_remote_node.help_button".localized
        }
        
        return cell
    }
}

final class ConnectRemoteNodeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate var presentQRCodeScannerButtonTapped: (() -> Void)?
    fileprivate var didSetupWallet: (() -> Void)?
    fileprivate var connectRemoteNodeViewModel: ConnectRemoteNodeViewModel?
    
    private var isConnecting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "scene.connect_remote_node.title".localized
        
        tableView.delegate = self
        tableView.backgroundColor = UIColor.zap.charcoalGrey
        tableView.separatorColor = UIColor.zap.warmGrey
        tableView.reactive.dataSource.forwardTo = self
                
        connectRemoteNodeViewModel?.dataSource
            .bind(to: tableView, using: ConnectCellBond())
            .dispose(in: reactive.bag)
    }
    
    private func displayError() {
        DispatchQueue.main.async { [weak self] in
            self?.presentErrorToast("scene.connect_remote_node.server_error".localized)
        }
    }
    
    fileprivate func presentHelp() {
        guard let url = URL(string: "link.help.zapconnect".localized) else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor.zap.charcoalGrey
        safariViewController.preferredControlTintColor = UIColor.zap.peach
        present(safariViewController, animated: true, completion: nil)
    }
    
    fileprivate func connect(cell: UITableViewCell) {
        guard !isConnecting else { return }
        isConnecting = true
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        cell.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ])
        
        cell.textLabel?.isHidden = true
        
        connectRemoteNodeViewModel?.connect { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.didSetupWallet?()
                } else {
                    self?.displayError()
                }
                
                activityIndicator.removeFromSuperview()
                cell.textLabel?.isHidden = false
                self?.isConnecting = false
            }
        }
    }
    
    private func presentAddressDetail() {
        guard let viewModel = connectRemoteNodeViewModel else { return }
        let viewController = UIStoryboard.instantiateUpdateAddressViewController(connectRemoteNodeViewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentCertificateDetail() {
        guard let viewModel = connectRemoteNodeViewModel else { return }
        let viewController = UIStoryboard.instantiateCertificateDetailViewController(connectRemoteNodeViewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func paste() {
        connectRemoteNodeViewModel?.pasteCertificates { [weak self] error in
            self?.presentErrorToast(error.localized)
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
        view.textLabel?.font = UIFont.zap.light
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
