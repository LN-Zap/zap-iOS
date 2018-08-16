//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import Lightning
import UIKit

extension UIStoryboard {
    static func instantiateDetailViewController(
        detailViewModel: DetailViewModel,
        dismissButtonTapped: @escaping () -> Void,
        blockExplorerButtonTapped: @escaping (String, BlockExplorer.CodeType) -> Void) -> UINavigationController {
        let viewController = Storyboard.detail.initial(viewController: UINavigationController.self)
        viewController.navigationBar.backgroundColor = UIColor.Zap.seaBlue
        viewController.navigationBar.shadowImage = UIImage()
        viewController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        viewController.navigationBar.titleTextStyle = .light
        
        if let detailViewController = viewController.topViewController as? DetailViewController {
            detailViewController.detailViewModel = detailViewModel
            detailViewController.dismissButtonTapped = dismissButtonTapped
            detailViewController.blockExplorerButtonTapped = blockExplorerButtonTapped
        }
        return viewController
    }
}

final class DetailViewController: UIViewController, KeyboardAdjustable {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    fileprivate var dismissButtonTapped: (() -> Void)?
    fileprivate var blockExplorerButtonTapped: ((String, BlockExplorer.CodeType) -> Void)?
    
    var detailViewModel: DetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.Zap.seaBlue
        tableView.separatorColor = UIColor.Zap.gray
        
        title = detailViewModel?.detailViewControllerTitle
        
        tableView.registerCell(DetailTableViewCell.self)
        tableView.registerCell(DetailMemoTableViewCell.self)
        tableView.registerCell(DetailQRCodeTableViewCell.self)
        tableView.registerCell(DetailTimerTableViewCell.self)
        tableView.registerCell(DetailSeparatorTableViewCell.self)
        tableView.registerCell(DetailDestructiveActionTableViewCell.self)
        tableView.registerCell(DetailBlockExplorerTableViewCell.self)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        detailViewModel?.detailCells
            .bind(to: tableView, createCell: { [unowned self] in
                self.createCell(data: $0, indexPath: $1, tableView: $2)
            })
            .dispose(in: reactive.bag)
        
        setupKeyboardNotifications(constraint: tableViewBottomConstraint)
    }
    
    private func createCell(data: ObservableArray<DetailCellType>, indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        switch data[indexPath.row] {
        case .info(let info):
            let cell: DetailTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.info = info
            return cell
        case .memo(let info):
            let cell: DetailMemoTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.info = info
            return cell
        case .qrCode(let address):
            let cell: DetailQRCodeTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.address = address
            cell.delegate = self
            return cell
        case .timer(let info):
            let cell: DetailTimerTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.info = info
            return cell
        case .separator:
            return tableView.dequeueCellForIndexPath(indexPath) as DetailSeparatorTableViewCell
        case .destructiveAction(let info):
            let cell: DetailDestructiveActionTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.delegate = self
            cell.info = info
            return cell
        case .transactionHash(let info):
            let cell: DetailBlockExplorerTableViewCell = tableView.dequeueCellForIndexPath(indexPath)
            cell.delegate = self
            cell.info = info
            return cell
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        dismissButtonTapped?()
    }
}

extension DetailViewController: DetailCellDelegate {
    func dismiss() {
        dismissButtonTapped?()
    }
    
    func presentBlockExplorer(_ transactionId: String, type: BlockExplorer.CodeType) {
        blockExplorerButtonTapped?(transactionId, type)
    }
}
