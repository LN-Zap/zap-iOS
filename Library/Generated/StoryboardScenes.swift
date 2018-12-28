// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum Background: StoryboardType {
    internal static let storyboardName = "Background"

    internal static let backgoundViewController = SceneType<BackgoundViewController>(storyboard: Background.self, identifier: "BackgoundViewController")
  }
  internal enum ChannelList: StoryboardType {
    internal static let storyboardName = "ChannelList"

    internal static let initialScene = InitialSceneType<ChannelListViewController>(storyboard: ChannelList.self)

    internal static let channelViewController = SceneType<ChannelListViewController>(storyboard: ChannelList.self, identifier: "ChannelViewController")
  }
  internal enum ConnectRemoteNode: StoryboardType {
    internal static let storyboardName = "ConnectRemoteNode"

    internal static let initialScene = InitialSceneType<ConnectRemoteNodeViewController>(storyboard: ConnectRemoteNode.self)

    internal static let certificateDetailViewController = SceneType<CertificateDetailViewController>(storyboard: ConnectRemoteNode.self, identifier: "CertificateDetailViewController")

    internal static let connectRemoteNodeViewController = SceneType<ConnectRemoteNodeViewController>(storyboard: ConnectRemoteNode.self, identifier: "ConnectRemoteNodeViewController")

    internal static let remoteNodeCertificatesScannerViewController = SceneType<RemoteNodeCertificatesScannerViewController>(storyboard: ConnectRemoteNode.self, identifier: "RemoteNodeCertificatesScannerViewController")

    internal static let updateAddressViewController = SceneType<UpdateAddressViewController>(storyboard: ConnectRemoteNode.self, identifier: "UpdateAddressViewController")
  }
  internal enum CreateWallet: StoryboardType {
    internal static let storyboardName = "CreateWallet"

    internal static let confirmMnemonicViewController = SceneType<ConfirmMnemonicViewController>(storyboard: CreateWallet.self, identifier: "ConfirmMnemonicViewController")

    internal static let mnemonicViewController = SceneType<MnemonicViewController>(storyboard: CreateWallet.self, identifier: "MnemonicViewController")

    internal static let mnemonicWordListViewController = SceneType<MnemonicWordListViewController>(storyboard: CreateWallet.self, identifier: "MnemonicWordListViewController")

    internal static let recoverWalletViewController = SceneType<RecoverWalletViewController>(storyboard: CreateWallet.self, identifier: "RecoverWalletViewController")

    internal static let selectWalletCreationMethodViewController = SceneType<SelectWalletCreationMethodViewController>(storyboard: CreateWallet.self, identifier: "SelectWalletCreationMethodViewController")
  }
  internal enum Debug: StoryboardType {
    internal static let storyboardName = "Debug"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Debug.self)
  }
  internal enum History: StoryboardType {
    internal static let storyboardName = "History"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: History.self)

    internal static let filterViewController = SceneType<FilterViewController>(storyboard: History.self, identifier: "FilterViewController")

    internal static let historyViewController = SceneType<HistoryViewController>(storyboard: History.self, identifier: "HistoryViewController")
  }
  internal enum Loading: StoryboardType {
    internal static let storyboardName = "Loading"

    internal static let initialScene = InitialSceneType<LoadingViewController>(storyboard: Loading.self)
  }
  internal enum ModalPin: StoryboardType {
    internal static let storyboardName = "ModalPin"

    internal static let modalPinViewController = SceneType<ModalPinViewController>(storyboard: ModalPin.self, identifier: "ModalPinViewController")
  }
  internal enum NumericKeyPad: StoryboardType {
    internal static let storyboardName = "NumericKeyPad"

    internal static let initialScene = InitialSceneType<PinViewController>(storyboard: NumericKeyPad.self)

    internal static let setupPinViewController = SceneType<SetupPinViewController>(storyboard: NumericKeyPad.self, identifier: "SetupPinViewController")
  }
  internal enum PoS: StoryboardType {
    internal static let storyboardName = "PoS"

    internal static let initialScene = InitialSceneType<ZapNavigationController>(storyboard: PoS.self)

    internal static let favouritePageContentViewController = SceneType<FavouritePageContentViewController>(storyboard: PoS.self, identifier: "FavouritePageContentViewController")

    internal static let productSearchViewController = SceneType<ProductSearchViewController>(storyboard: PoS.self, identifier: "ProductSearchViewController")

    internal static let productViewController = SceneType<FavouriteProductsViewController>(storyboard: PoS.self, identifier: "ProductViewController")

    internal static let shoppingCartViewController = SceneType<ShoppingCartViewController>(storyboard: PoS.self, identifier: "ShoppingCartViewController")
  }
  internal enum QRCodeDetail: StoryboardType {
    internal static let storyboardName = "QRCodeDetail"

    internal static let initialScene = InitialSceneType<QRCodeDetailViewController>(storyboard: QRCodeDetail.self)

    internal static let qrCodeDetailViewController = SceneType<QRCodeDetailViewController>(storyboard: QRCodeDetail.self, identifier: "QRCodeDetailViewController")
  }
  internal enum QRCodeScanner: StoryboardType {
    internal static let storyboardName = "QRCodeScanner"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: QRCodeScanner.self)

    internal static let qrCodeScannerViewController = SceneType<QRCodeScannerViewController>(storyboard: QRCodeScanner.self, identifier: "QRCodeScannerViewController")
  }
  internal enum Root: StoryboardType {
    internal static let storyboardName = "Root"

    internal static let initialScene = InitialSceneType<RootViewController>(storyboard: Root.self)
  }
  internal enum Sync: StoryboardType {
    internal static let storyboardName = "Sync"

    internal static let initialScene = InitialSceneType<SyncViewController>(storyboard: Sync.self)

    internal static let syncViewController = SceneType<SyncViewController>(storyboard: Sync.self, identifier: "SyncViewController")
  }
  internal enum TimeLocked: StoryboardType {
    internal static let storyboardName = "TimeLocked"

    internal static let timeLockedViewController = SceneType<TimeLockedViewController>(storyboard: TimeLocked.self, identifier: "TimeLockedViewController")
  }
  internal enum Wallet: StoryboardType {
    internal static let storyboardName = "Wallet"

    internal static let walletViewController = SceneType<WalletViewController>(storyboard: Wallet.self, identifier: "WalletViewController")
  }
  internal enum WalletInvoiceOnly: StoryboardType {
    internal static let storyboardName = "WalletInvoiceOnly"

    internal static let tipViewController = SceneType<TipViewController>(storyboard: WalletInvoiceOnly.self, identifier: "TipViewController")

    internal static let waiterRequestViewController = SceneType<WaiterRequestViewController>(storyboard: WalletInvoiceOnly.self, identifier: "WaiterRequestViewController")

    internal static let walletInvoiceOnlyViewController = SceneType<WalletInvoiceOnlyViewController>(storyboard: WalletInvoiceOnly.self, identifier: "WalletInvoiceOnlyViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
