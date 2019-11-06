// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let channelBackupFile = ImageAsset(name: "channel_backup_file")
  internal static let channelBackupFileError = ImageAsset(name: "channel_backup_file_error")
  internal static let iconErrorSmall = ImageAsset(name: "icon_error_small")
  internal static let iconSuccessSmall = ImageAsset(name: "icon_success_small")
  internal static let iconCopy = ImageAsset(name: "icon_copy")
  internal static let iconQrCode = ImageAsset(name: "icon_qr_code")
  internal static let lightningBoltBackground = ImageAsset(name: "lightning_bolt_background")
  internal static let loadingCheck = ImageAsset(name: "loading_check")
  internal static let loadingLightning = ImageAsset(name: "loading_lightning")
  internal static let loadingOnChain = ImageAsset(name: "loading_on_chain")
  internal static let logo = ImageAsset(name: "logo")
  internal static let iconSwap = ImageAsset(name: "icon_swap")
  internal static let iconClose = ImageAsset(name: "icon_close")
  internal static let iconHeaderLightning = ImageAsset(name: "icon_header_lightning")
  internal static let iconHeaderOnChain = ImageAsset(name: "icon_header_on_chain")
  internal static let arrowLeft = ImageAsset(name: "arrow.left")
  internal static let arrowRight = ImageAsset(name: "arrow.right")
  internal static let iconPlus = ImageAsset(name: "icon-plus")
  internal static let nodeBackup = ImageAsset(name: "node_backup")
  internal static let nodeChannels = ImageAsset(name: "node_channels")
  internal static let nodeQrCode = ImageAsset(name: "node_qr_code")
  internal static let nodeSettings = ImageAsset(name: "node_settings")
  internal static let nodeSupport = ImageAsset(name: "node_support")
  internal static let nodeTor = ImageAsset(name: "node_tor")
  internal static let onboarding01Layer01 = ImageAsset(name: "onboarding_01_layer_01")
  internal static let onboarding01Layer02 = ImageAsset(name: "onboarding_01_layer_02")
  internal static let onboarding01Layer03 = ImageAsset(name: "onboarding_01_layer_03")
  internal static let onboarding02Layer01 = ImageAsset(name: "onboarding_02_layer_01")
  internal static let onboarding02Layer02 = ImageAsset(name: "onboarding_02_layer_02")
  internal static let onboarding02Layer03 = ImageAsset(name: "onboarding_02_layer_03")
  internal static let onboarding02Layer04 = ImageAsset(name: "onboarding_02_layer_04")
  internal static let onboarding03Layer01 = ImageAsset(name: "onboarding_03_layer_01")
  internal static let onboarding03Layer02 = ImageAsset(name: "onboarding_03_layer_02")
  internal static let onboarding03Layer03 = ImageAsset(name: "onboarding_03_layer_03")
  internal static let onboarding04 = ImageAsset(name: "onboarding_04")
  internal static let iconFaceId = ImageAsset(name: "icon_face_id")
  internal static let iconTouchId = ImageAsset(name: "icon_touch_id")
  internal static let pinBackSymbol = ImageAsset(name: "pin-back-symbol")
  internal static let iconFlashlight = ImageAsset(name: "icon_flashlight")
  internal static let qrSuccess = ImageAsset(name: "qr-success")
  internal static let iconRequestLightningButton = ImageAsset(name: "icon_request_lightning_button")
  internal static let iconRequestOnChainButton = ImageAsset(name: "icon_request_on_chain_button")
  internal static let iconArrowDownSmall = ImageAsset(name: "icon_arrow_down_small")
  internal static let iconArrowUpSmall = ImageAsset(name: "icon_arrow_up_small")
  internal static let iconSendArrow = ImageAsset(name: "icon_send_arrow")
  internal static let iconSliders = ImageAsset(name: "icon-sliders")
  internal static let history = ImageAsset(name: "history")
  internal static let nodeView = ImageAsset(name: "node_view")
  internal static let iconCheckGreen = ImageAsset(name: "iconCheckGreen")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
