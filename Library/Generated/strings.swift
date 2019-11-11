// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Channel {
    internal enum State {
      /// Online
      internal static let active = L10n.tr("Localizable", "channel.state.active")
      /// Closing
      internal static let closing = L10n.tr("Localizable", "channel.state.closing")
      /// Force Closing
      internal static let forceClosing = L10n.tr("Localizable", "channel.state.force_closing")
      /// Offline
      internal static let inactive = L10n.tr("Localizable", "channel.state.inactive")
      /// Opening
      internal static let opening = L10n.tr("Localizable", "channel.state.opening")
      /// Waiting Close
      internal static let waitingClose = L10n.tr("Localizable", "channel.state.waiting_close")
    }
  }

  internal enum Error {
    /// Unknown link format.
    internal static let wrongUriFormat = L10n.tr("Localizable", "error.wrong_uri_format")
    /// You tried opening a link for %@ but your node is connected to %@.
    internal static func wrongUriNetwork(_ p1: String, _ p2: String) -> String {
      return L10n.tr("Localizable", "error.wrong_uri_network", p1, p2)
    }
    internal enum BlockExplorer {
      /// %@ does not support %@.
      internal static func unsupportedNetwork(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "error.block_explorer.unsupported_network", p1, p2)
      }
    }
  }

  internal enum ExpiryTime {
    /// 1 Day
    internal static let oneDay = L10n.tr("Localizable", "expiry_time.one_day")
    /// 1 Hour
    internal static let oneHour = L10n.tr("Localizable", "expiry_time.one_hour")
    /// 1 Minute
    internal static let oneMinute = L10n.tr("Localizable", "expiry_time.one_minute")
    /// 1 Week
    internal static let oneWeek = L10n.tr("Localizable", "expiry_time.one_week")
    /// 1 Year
    internal static let oneYear = L10n.tr("Localizable", "expiry_time.one_year")
    /// 6 Hours
    internal static let sixHours = L10n.tr("Localizable", "expiry_time.six_hours")
    /// 10 Minutes
    internal static let tenMinutes = L10n.tr("Localizable", "expiry_time.ten_minutes")
    /// 30 Days
    internal static let thirtyDays = L10n.tr("Localizable", "expiry_time.thirty_days")
    /// 30 Minutes
    internal static let thirtyMinutes = L10n.tr("Localizable", "expiry_time.thirty_minutes")
  }

  internal enum Generic {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "generic.cancel")
    internal enum Memo {
      /// What is this for?
      internal static let placeholder = L10n.tr("Localizable", "generic.memo.placeholder")
    }
    internal enum Pasteboard {
      /// Invalid Address
      internal static let invalidAddress = L10n.tr("Localizable", "generic.pasteboard.invalid_address")
    }
    internal enum QrCode {
      /// Copy
      internal static let copyButton = L10n.tr("Localizable", "generic.qr_code.copy_button")
      /// Address has been copied to clipboard.
      internal static let copySuccessMessage = L10n.tr("Localizable", "generic.qr_code.copy_success_message")
      /// Share
      internal static let shareButton = L10n.tr("Localizable", "generic.qr_code.share_button")
    }
  }

  internal enum Link {
    /// https://github.com/LN-Zap/zap-iOS/issues
    internal static let bugReport = L10n.tr("Localizable", "link.bug_report")
    /// https://docs.zaphq.io/
    internal static let help = L10n.tr("Localizable", "link.help")
    /// https://github.com/lightningnetwork/lnd/releases
    internal static let lndReleases = L10n.tr("Localizable", "link.lnd_releases")
    /// http://zap.jackmallers.com/privacy
    internal static let privacy = L10n.tr("Localizable", "link.privacy")
    internal enum Help {
      /// https://docs.zaphq.io/docs-ios-remote-node-setup
      internal static let zapconnect = L10n.tr("Localizable", "link.help.zapconnect")
    }
  }

  internal enum NetworkType {
    /// Mainnet
    internal static let mainnet = L10n.tr("Localizable", "network_type.mainnet")
    /// Regtest
    internal static let regtest = L10n.tr("Localizable", "network_type.regtest")
    /// Simnet
    internal static let simnet = L10n.tr("Localizable", "network_type.simnet")
    /// Testnet
    internal static let testnet = L10n.tr("Localizable", "network_type.testnet")
  }

  internal enum Notification {
    internal enum Sync {
      /// Please sync
      internal static let title = L10n.tr("Localizable", "notification.sync.title")
      internal enum Day12 {
        /// Please remember syncing your wallet to make sure you stay safe
        internal static let body = L10n.tr("Localizable", "notification.sync.day_12.body")
      }
      internal enum Day13 {
        /// You have one more day to sync your wallet before it's getting dangerous.
        internal static let body = L10n.tr("Localizable", "notification.sync.day_13.body")
      }
      internal enum Day14 {
        /// Please sync your wallet as soon as possible.
        internal static let body = L10n.tr("Localizable", "notification.sync.day_14.body")
      }
    }
  }
    
  internal enum PaymentFeeLimitPercentage {
    /// None
    internal static let none = L10n.tr("Localizable", "payment_fee_limit_percentage.none")
  }

  internal enum RpcConnectQrcodeError {
    /// Could not read BTCPay configurations file.
    internal static let btcPayConfigurationBroken = L10n.tr("Localizable", "rpc_connect_qrcode_error.btc_pay_configuration_broken")
    /// Looks like the code is expired.
    internal static let btcPayExpired = L10n.tr("Localizable", "rpc_connect_qrcode_error.btc_pay_expired")
    /// Invalid code format.
    internal static let cantReadQrcode = L10n.tr("Localizable", "rpc_connect_qrcode_error.cant_read_qrcode")
    /// Connection updated.
    internal static let codeUpdated = L10n.tr("Localizable", "rpc_connect_qrcode_error.code_updated")
  }

  internal enum Scene {
    internal enum ChannelBackup {
      /// %@ channel.backup
      internal static func cellTitle(_ p1: String) -> String {
        return L10n.tr("Localizable", "scene.channel_backup.cell_title", p1)
      }
      /// file not found
      internal static let notFound = L10n.tr("Localizable", "scene.channel_backup.not_found")
      /// Channel Backup
      internal static let title = L10n.tr("Localizable", "scene.channel_backup.title")
      internal enum Error {
        /// iCloud backup failed.
        internal static let iCloudBackupFailed = L10n.tr("Localizable", "scene.channel_backup.error.iCloudBackupFailed")
        /// iCloud seems to be disabled.
        internal static let iCloudDisabled = L10n.tr("Localizable", "scene.channel_backup.error.iCloudDisabled")
        /// Could not get channel backup from lnd.
        internal static let lndError = L10n.tr("Localizable", "scene.channel_backup.error.lndError")
        /// Local file backup failed.
        internal static let localBackupFailed = L10n.tr("Localizable", "scene.channel_backup.error.localBackupFailed")
      }
    }
    internal enum ChannelDetail {
      /// Close Channel
      internal static let closeButton = L10n.tr("Localizable", "scene.channel_detail.close_button")
      /// Closing Transaction
      internal static let closingTransactionLabel = L10n.tr("Localizable", "scene.channel_detail.closing_transaction_label")
      /// Force Close Channel
      internal static let forceCloseButton = L10n.tr("Localizable", "scene.channel_detail.force_close_button")
      /// Funding Transaction
      internal static let fundingTransactionLabel = L10n.tr("Localizable", "scene.channel_detail.funding_transaction_label")
      /// Local Balance
      internal static let localBalanceLabel = L10n.tr("Localizable", "scene.channel_detail.local_balance_label")
      /// Remote Balance
      internal static let remoteBalanceLabel = L10n.tr("Localizable", "scene.channel_detail.remote_balance_label")
      /// Remote PubKey
      internal static let remotePubKeyLabel = L10n.tr("Localizable", "scene.channel_detail.remote_pub_key_label")
      internal enum ClosingTime {
        /// Closing in
        internal static let label = L10n.tr("Localizable", "scene.channel_detail.closing_time.label")
      }
    }
    internal enum Channels {
      /// Closing Channel
      internal static let closeLoadingView = L10n.tr("Localizable", "scene.channels.close_loading_view")
      /// Channels
      internal static let title = L10n.tr("Localizable", "scene.channels.title")
      internal enum Alert {
        /// Close Channel
        internal static let close = L10n.tr("Localizable", "scene.channels.alert.close")
        /// Force Close Channel
        internal static let forceClose = L10n.tr("Localizable", "scene.channels.alert.force_close")
      }
      internal enum Close {
        /// Do you really want to close the channel with node %@?
        internal static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "scene.channels.close.message", p1)
        }
        /// Close Channel
        internal static let title = L10n.tr("Localizable", "scene.channels.close.title")
      }
      internal enum CloseSuccess {
        /// Channel is closing.
        internal static let toast = L10n.tr("Localizable", "scene.channels.close_success.toast")
      }
      internal enum EmptyState {
        /// Open a channel
        internal static let buttonTitle = L10n.tr("Localizable", "scene.channels.empty_state.button_title")
        /// You can't transact on the Lightning Network yet! Let's open a channel to start transacting on the Lightning Network.
        internal static let message = L10n.tr("Localizable", "scene.channels.empty_state.message")
        /// Open a channel
        internal static let title = L10n.tr("Localizable", "scene.channels.empty_state.title")
      }
      internal enum ForceClose {
        /// %@ is offline, are you sure you want to force close this channel? You’d have to wait about %@ for your funds?
        internal static func message(_ p1: String, _ p2: String) -> String {
          return L10n.tr("Localizable", "scene.channels.force_close.message", p1, p2)
        }
        /// Force Close Channel
        internal static let title = L10n.tr("Localizable", "scene.channels.force_close.title")
      }
      internal enum Header {
        /// Total offline:
        internal static let offline = L10n.tr("Localizable", "scene.channels.header.offline")
        /// Total can receive:
        internal static let totalCanReceive = L10n.tr("Localizable", "scene.channels.header.total_can_receive")
        /// Total can send:
        internal static let totalCanSend = L10n.tr("Localizable", "scene.channels.header.total_can_send")
        /// Total pending:
        internal static let totalPending = L10n.tr("Localizable", "scene.channels.header.total_pending")
      }
    }
    internal enum ConfirmMnemonic {
      /// Select word number %d
      internal static func headline(_ p1: Int) -> String {
        return L10n.tr("Localizable", "scene.confirm_mnemonic.headline", p1)
      }
      /// Confirm Recovery Phrase
      internal static let title = L10n.tr("Localizable", "scene.confirm_mnemonic.title")
    }
    internal enum ConnectNodeUri {
      internal enum ActionSheet {
        /// Connect
        internal static let connectButton = L10n.tr("Localizable", "scene.connect_node_uri.action_sheet.connect_button")
        /// Do you really want to connect to node at %@?
        internal static func message(_ p1: String) -> String {
          return L10n.tr("Localizable", "scene.connect_node_uri.action_sheet.message", p1)
        }
        /// Connect
        internal static let title = L10n.tr("Localizable", "scene.connect_node_uri.action_sheet.title")
      }
    }
    internal enum ConnectRemoteNode {
      /// Credentials
      internal static let certificateLabel = L10n.tr("Localizable", "scene.connect_remote_node.certificate_label")
      /// Connect
      internal static let connectButton = L10n.tr("Localizable", "scene.connect_remote_node.connect_button")
      /// Scan the QRCode generated by lndconnect, BTCPay Server, or paste the link you get from running 'lndconnect -j' to connect to your node.
      internal static let emptyState = L10n.tr("Localizable", "scene.connect_remote_node.empty_state")
      /// Need Help?
      internal static let helpButton = L10n.tr("Localizable", "scene.connect_remote_node.help_button")
      /// Paste
      internal static let pasteButton = L10n.tr("Localizable", "scene.connect_remote_node.paste_button")
      /// Scan
      internal static let scanButton = L10n.tr("Localizable", "scene.connect_remote_node.scan_button")
      /// Could not connect to server.
      internal static let serverError = L10n.tr("Localizable", "scene.connect_remote_node.server_error")
      /// Connect Remote Node
      internal static let title = L10n.tr("Localizable", "scene.connect_remote_node.title")
      /// Address
      internal static let urlLabel = L10n.tr("Localizable", "scene.connect_remote_node.url_label")
      /// Your Node
      internal static let yourNodeTitle = L10n.tr("Localizable", "scene.connect_remote_node.your_node_title")
      internal enum CertificateDetail {
        /// Certificate
        internal static let certificateTitle = L10n.tr("Localizable", "scene.connect_remote_node.certificate_detail.certificate_title")
        /// Macaroon
        internal static let macaroonTitle = L10n.tr("Localizable", "scene.connect_remote_node.certificate_detail.macaroon_title")
      }
      internal enum EditUrl {
        /// Address
        internal static let title = L10n.tr("Localizable", "scene.connect_remote_node.edit_url.title")
      }
    }
    internal enum CreateWallet {
      /// Write down the recovery phrase and store it at a safe location.
      internal static let descriptionLabel = L10n.tr("Localizable", "scene.create_wallet.description_label")
      /// Next
      internal static let nextButton = L10n.tr("Localizable", "scene.create_wallet.next_button")
      /// Recovery Phrase
      internal static let title = L10n.tr("Localizable", "scene.create_wallet.title")
    }
    internal enum Filter {
      /// Expired Invoices
      internal static let displayExpiredInvoices = L10n.tr("Localizable", "scene.filter.display_expired_invoices")
      /// Channel Events
      internal static let displayChannelEvents = L10n.tr("Localizable", "scene.filter.displayChannelEvents")
      /// Created Invoices
      internal static let displayLightningInvoices = L10n.tr("Localizable", "scene.filter.displayLightningInvoices")
      /// Lightning Payments
      internal static let displayLightningPayments = L10n.tr("Localizable", "scene.filter.displayLightningPayments")
      /// On-chain Payments
      internal static let displayOnChainTransactions = L10n.tr("Localizable", "scene.filter.displayOnChainTransactions")
      /// Filter
      internal static let title = L10n.tr("Localizable", "scene.filter.title")
      internal enum SectionHeader {
        /// Transaction Types
        internal static let transactionTypes = L10n.tr("Localizable", "scene.filter.section_header.transaction_types")
      }
    }
    internal enum History {
      /// 0 transactions 🙁
      internal static let emptyStateLabel = L10n.tr("Localizable", "scene.history.empty_state_label")
      /// History
      internal static let title = L10n.tr("Localizable", "scene.history.title")
      internal enum Cell {
        /// Breach closed Channel
        internal static let breachCloseChannel = L10n.tr("Localizable", "scene.history.cell.breach_close_channel")
        /// Channel abandoned
        internal static let channelAbandoned = L10n.tr("Localizable", "scene.history.cell.channel_abandoned")
        /// Closed Channel
        internal static let channelClosed = L10n.tr("Localizable", "scene.history.cell.channel_closed")
        /// Opened Channel
        internal static let channelOpened = L10n.tr("Localizable", "scene.history.cell.channel_opened")
        /// Closed Channel (funding canceled)
        internal static let closeChannelFundingCanceled = L10n.tr("Localizable", "scene.history.cell.close_channel_funding_canceled")
        /// Force closed Channel
        internal static let forceCloseChannel = L10n.tr("Localizable", "scene.history.cell.force_close_channel")
        /// Payment Request created
        internal static let invoiceCreated = L10n.tr("Localizable", "scene.history.cell.invoice_created")
        /// Payment received
        internal static let paymentReceived = L10n.tr("Localizable", "scene.history.cell.payment_received")
        /// Payment sent
        internal static let paymentSent = L10n.tr("Localizable", "scene.history.cell.payment_sent")
        /// Remote forced close Channel
        internal static let remoteForceCloseChannel = L10n.tr("Localizable", "scene.history.cell.remote_force_close_channel")
        /// Payment received
        internal static let transactionReceived = L10n.tr("Localizable", "scene.history.cell.transaction_received")
        /// Payment sent
        internal static let transactionSent = L10n.tr("Localizable", "scene.history.cell.transaction_sent")
        internal enum Label {
          /// error
          internal static let error = L10n.tr("Localizable", "scene.history.cell.label.error")
          /// new
          internal static let new = L10n.tr("Localizable", "scene.history.cell.label.new")
        }
      }
    }
    internal enum Main {
      /// %@ per BTC
      internal static func exchangeRateLabel(_ p1: String) -> String {
        return L10n.tr("Localizable", "scene.main.exchange_rate_label", p1)
      }
      /// Receive
      internal static let receiveButton = L10n.tr("Localizable", "scene.main.receive_button")
      /// Send
      internal static let sendButton = L10n.tr("Localizable", "scene.main.send_button")
    }
    internal enum ManageWallets {
      /// Manage Wallets
      internal static let title = L10n.tr("Localizable", "scene.manage_wallets.title")
      internal enum Cell {
        /// local
        internal static let local = L10n.tr("Localizable", "scene.manage_wallets.cell.local")
        /// remote
        internal static let remote = L10n.tr("Localizable", "scene.manage_wallets.cell.remote")
      }
      internal enum SectionTitle {
        /// Local Wallet
        internal static let local = L10n.tr("Localizable", "scene.manage_wallets.section_title.local")
        /// Remote Wallets
        internal static let remote = L10n.tr("Localizable", "scene.manage_wallets.section_title.remote")
      }
    }
    internal enum ModalPin {
      /// Please enter your passcode to continue
      internal static let description = L10n.tr("Localizable", "scene.modal_pin.description")
      /// Enter Passcode
      internal static let headline = L10n.tr("Localizable", "scene.modal_pin.headline")
    }
    internal enum MyNode {
      /// My Node
      internal static let title = L10n.tr("Localizable", "scene.my_node.title")
      internal enum ChannelBackup {
        /// Setup emergency options
        internal static let subtitle = L10n.tr("Localizable", "scene.my_node.channel_backup.subtitle")
        /// Channel Backup
        internal static let title = L10n.tr("Localizable", "scene.my_node.channel_backup.title")
      }
      internal enum Channels {
        /// Manage your capacity
        internal static let subtitle = L10n.tr("Localizable", "scene.my_node.channels.subtitle")
        /// Channels
        internal static let title = L10n.tr("Localizable", "scene.my_node.channels.title")
      }
      internal enum Settings {
        /// Preferences & stuff
        internal static let subtitle = L10n.tr("Localizable", "scene.my_node.settings.subtitle")
        /// Settings
        internal static let title = L10n.tr("Localizable", "scene.my_node.settings.title")
      }
      internal enum Support {
        /// Get support and send feedback
        internal static let subtitle = L10n.tr("Localizable", "scene.my_node.support.subtitle")
        /// Support
        internal static let title = L10n.tr("Localizable", "scene.my_node.support.title")
      }
    }
    internal enum NodeUri {
      /// Alias
      internal static let aliasLabel = L10n.tr("Localizable", "scene.node_uri.alias_label")
      /// Connect to Node
      internal static let title = L10n.tr("Localizable", "scene.node_uri.title")
      /// URI
      internal static let uriLabel = L10n.tr("Localizable", "scene.node_uri.uri_label")
    }
    internal enum Onboarding {
      internal enum Page1 {
        /// Continue
        internal static let buttonTitle = L10n.tr("Localizable", "scene.onboarding.page_1.button_title")
        /// With Zap, you are in control of your money. To make sure your coins are always stored safely, Zap will provide a recovery phrase for you.
        internal static let message = L10n.tr("Localizable", "scene.onboarding.page_1.message")
        /// Your **keys**, your **coins**
        internal static let title = L10n.tr("Localizable", "scene.onboarding.page_1.title")
      }
      internal enum Page2 {
        /// Continue
        internal static let buttonTitle = L10n.tr("Localizable", "scene.onboarding.page_2.button_title")
        /// Write down your phrase. You can use your phrase to recover your funds anytime if you misplace your device.
        internal static let message = L10n.tr("Localizable", "scene.onboarding.page_2.message")
        /// Save your **recovery phrase**
        internal static let title = L10n.tr("Localizable", "scene.onboarding.page_2.title")
      }
      internal enum Page3 {
        /// Generate Recovery Phrase
        internal static let buttonTitle = L10n.tr("Localizable", "scene.onboarding.page_3.button_title")
        /// Make sure to keep your recovery phrase private. Store it somewhere only you will find it.
        internal static let message = L10n.tr("Localizable", "scene.onboarding.page_3.message")
        /// Keep it **safe**
        internal static let title = L10n.tr("Localizable", "scene.onboarding.page_3.title")
      }
    }
    internal enum OpenChannel {
      /// Open Channel
      internal static let addButton = L10n.tr("Localizable", "scene.open_channel.add_button")
      /// Node:
      internal static let channelUriLabel = L10n.tr("Localizable", "scene.open_channel.channel_uri_label")
      /// Open Channel
      internal static let title = L10n.tr("Localizable", "scene.open_channel.title")
      internal enum PasteButton {
        /// Paste Peer Address
        internal static let title = L10n.tr("Localizable", "scene.open_channel.paste_button.title")
      }
      internal enum Subtitle {
        /// On-chain balance: %@
        internal static func balance(_ p1: String) -> String {
          return L10n.tr("Localizable", "scene.open_channel.subtitle.balance", p1)
        }
        /// Maximum channel size: %@
        internal static func maximumSize(_ p1: String) -> String {
          return L10n.tr("Localizable", "scene.open_channel.subtitle.maximum_size", p1)
        }
        /// Minimum channel size: %@
        internal static func minimumSize(_ p1: String) -> String {
          return L10n.tr("Localizable", "scene.open_channel.subtitle.minimum_size", p1)
        }
      }
      internal enum SuggestedPeers {
        /// Suggested Peers
        internal static let title = L10n.tr("Localizable", "scene.open_channel.suggested_peers.title")
      }
    }
    internal enum Pin {
      internal enum Biometric {
        /// To access the secure data
        internal static let reason = L10n.tr("Localizable", "scene.pin.biometric.reason")
        internal enum Fallback {
          /// Use Passcode
          internal static let title = L10n.tr("Localizable", "scene.pin.biometric.fallback.title")
        }
      }
    }
    internal enum PushNotification {
      /// Turn on notifications
      internal static let confirmButtonTitle = L10n.tr("Localizable", "scene.push_notification.confirm_button_title")
      /// Stay **up to date**
      internal static let headline = L10n.tr("Localizable", "scene.push_notification.headline")
      /// To keep your funds safe, Zap needs to sync once in a while. Do you want to be notified when your wallet needs to sync?
      internal static let message = L10n.tr("Localizable", "scene.push_notification.message")
      /// Skip
      internal static let skipButtonTitle = L10n.tr("Localizable", "scene.push_notification.skip_button_title")
    }
    internal enum QrCodeDetail {
      /// Receive
      internal static let title = L10n.tr("Localizable", "scene.qr_code_detail.title")
    }
    internal enum QrcodeScanner {
      /// Scan QR-Code
      internal static let topLabel = L10n.tr("Localizable", "scene.qrcode_scanner.top_label")
      internal enum CameraAccessDeniedAlert {
        /// Turn on camera access in the settings to scan the QR code.
        internal static let message = L10n.tr("Localizable", "scene.qrcode_scanner.camera_access_denied_alert.message")
        /// Settings
        internal static let ok = L10n.tr("Localizable", "scene.qrcode_scanner.camera_access_denied_alert.ok")
        /// Camera access denied
        internal static let title = L10n.tr("Localizable", "scene.qrcode_scanner.camera_access_denied_alert.title")
      }
      internal enum Error {
        /// Unknown address format.
        internal static let unknownFormat = L10n.tr("Localizable", "scene.qrcode_scanner.error.unknown_format")
        /// You tried opening an invoice for %@ but your node is connected to %@.
        internal static func wrongNetwork(_ p1: String, _ p2: String) -> String {
          return L10n.tr("Localizable", "scene.qrcode_scanner.error.wrong_network", p1, p2)
        }
        /// For security reasons zap does not support invoices without a specified amount.
        internal static let zeroAmountInvoice = L10n.tr("Localizable", "scene.qrcode_scanner.error.zero_amount_invoice")
      }
    }
    internal enum RecoverWallet {
      /// Enter your recovery phrase:
      internal static let descriptionLabel = L10n.tr("Localizable", "scene.recover_wallet.description_label")
      /// Done
      internal static let doneButton = L10n.tr("Localizable", "scene.recover_wallet.done_button")
      /// abandon ability able about above absent absorb abstract absurd abuse access accident account accuse achieve acid acoustic acquire across act action actor actress actual
      internal static let placeholder = L10n.tr("Localizable", "scene.recover_wallet.placeholder")
      /// Select Channel Backup
      internal static let selectChannelBackupButton = L10n.tr("Localizable", "scene.recover_wallet.select_channel_backup_button")
      /// Recover Wallet
      internal static let title = L10n.tr("Localizable", "scene.recover_wallet.title")
    }
    internal enum Request {
      /// Generate Request
      internal static let generateRequestButton = L10n.tr("Localizable", "scene.request.generate_request_button")
      /// Lightning
      internal static let lightningButton = L10n.tr("Localizable", "scene.request.lightning_button")
      /// Lightning Payment Request
      internal static let lightningHeaderTitle = L10n.tr("Localizable", "scene.request.lightning_header_title")
      /// Next
      internal static let nextButtonTitle = L10n.tr("Localizable", "scene.request.next_button_title")
      /// On-chain
      internal static let onChainButton = L10n.tr("Localizable", "scene.request.on_chain_button")
      /// On-Chain Payment Request
      internal static let onChainHeaderTitle = L10n.tr("Localizable", "scene.request.on_chain_header_title")
      /// or
      internal static let orSeparatorLabel = L10n.tr("Localizable", "scene.request.or_separator_label")
      /// Receive
      internal static let title = L10n.tr("Localizable", "scene.request.title")
      internal enum Subtitle {
        /// Can receive: %@
        internal static func lightning(_ p1: String) -> String {
          return L10n.tr("Localizable", "scene.request.subtitle.lightning", p1)
        }
      }
    }
    internal enum SelectWalletConnection {
      /// Bitcoin for **everyone**
      internal static let message = L10n.tr("Localizable", "scene.select_wallet_connection.message")
      internal enum Connect {
        /// Connect
        internal static let title = L10n.tr("Localizable", "scene.select_wallet_connection.connect.title")
      }
      internal enum Create {
        /// Create
        internal static let title = L10n.tr("Localizable", "scene.select_wallet_connection.create.title")
      }
      internal enum Recover {
        /// Recover
        internal static let title = L10n.tr("Localizable", "scene.select_wallet_connection.recover.title")
      }
    }
    internal enum Send {
      /// To:
      internal static let addressHeadline = L10n.tr("Localizable", "scene.send.address_headline")
      /// Authentication failed
      internal static let authenticationFailed = L10n.tr("Localizable", "scene.send.authentication_failed")
      /// Expected Fee:
      internal static let maximumFee = L10n.tr("Localizable", "scene.send.maximum_fee")
      /// Memo:
      internal static let memoHeadline = L10n.tr("Localizable", "scene.send.memo_headline")
      /// Send
      internal static let sendButton = L10n.tr("Localizable", "scene.send.send_button")
      /// Sending...
      internal static let sending = L10n.tr("Localizable", "scene.send.sending")
      /// Payment Successful
      internal static let successLabel = L10n.tr("Localizable", "scene.send.success_label")
      /// Send
      internal static let title = L10n.tr("Localizable", "scene.send.title")
      /// The fee for this payment (%@) exceeds the limit specified in the settings (%@).
      internal static func feeExceedsUserLimit(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "scene.send.fee_exceeds_user_limit", p1, p2)
      }
      /// The fee for this payment (%@ sats) will be higher than the payment amount (%@ sats).
      internal static func feeExceedsPayment(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "scene.send.fee_exceeds_payment_amount", p1, p2)
      }
      internal enum FeeAlert {
        /// Fee Limit Alert
        internal static let title = L10n.tr("Localizable", "scene.send.fee_alert.title")
        internal enum CancelButton {
          /// No
          internal static let title = L10n.tr("Localizable", "scene.send.fee_alert.cancel_button.title")
        }
        internal enum ConfirmButton {
          /// Yes
          internal static let title = L10n.tr("Localizable", "scene.send.fee_alert.confirm_button.title")
        }
      }
      internal enum Lightning {
        /// Send Lightning Payment
        internal static let title = L10n.tr("Localizable", "scene.send.lightning.title")
        /// Do you really want to pay this invoice?
        internal static let paymentConfirmation = L10n.tr("Localizable", "scene.send.lightning.payment_confirmation")
      }
      internal enum OnChain {
        /// Fee:
        internal static let fee = L10n.tr("Localizable", "scene.send.on_chain.fee")
        /// Send On-Chain
        internal static let title = L10n.tr("Localizable", "scene.send.on_chain.title")
        /// Do you really want to send this payment?
        internal static let paymentConfirmation = L10n.tr("Localizable", "scene.send.on_chain.payment_confirmation")
        internal enum Fee {
          /// Estimated Delivery: %@
          internal static func estimatedDelivery(_ p1: String) -> String {
            return L10n.tr("Localizable", "scene.send.on_chain.fee.estimated_delivery", p1)
          }
          /// Fast
          internal static let fast = L10n.tr("Localizable", "scene.send.on_chain.fee.fast")
          /// Medium
          internal static let medium = L10n.tr("Localizable", "scene.send.on_chain.fee.medium")
          /// Slow
          internal static let slow = L10n.tr("Localizable", "scene.send.on_chain.fee.slow")
          internal enum Description {
            /// Fast Transaction
            internal static let fast = L10n.tr("Localizable", "scene.send.on_chain.fee.description.fast")
            /// Medium Transaction
            internal static let medium = L10n.tr("Localizable", "scene.send.on_chain.fee.description.medium")
            /// Slow Transaction
            internal static let slow = L10n.tr("Localizable", "scene.send.on_chain.fee.description.slow")
          }
        }
      }
      internal enum PasteButton {
        /// Paste Address
        internal static let title = L10n.tr("Localizable", "scene.send.paste_button.title")
      }
      internal enum Subtitle {
        /// Can send: %@
        internal static func lightningCanSendBalance(_ p1: String) -> String {
          return L10n.tr("Localizable", "scene.send.subtitle.lightning_can_send_balance", p1)
        }
        /// On-chain balance: %@
        internal static func onChainBalance(_ p1: String) -> String {
          return L10n.tr("Localizable", "scene.send.subtitle.on_chain_balance", p1)
        }
      }
    }
    internal enum Settings {
      /// Settings
      internal static let title = L10n.tr("Localizable", "scene.settings.title")
      internal enum Item {
        /// Bitcoin Unit
        internal static let bitcoinUnit = L10n.tr("Localizable", "scene.settings.item.bitcoin_unit")
        /// Block Explorer
        internal static let blockExplorer = L10n.tr("Localizable", "scene.settings.item.block_explorer")
        /// Change Pin
        internal static let changePin = L10n.tr("Localizable", "scene.settings.item.change_pin")
        /// Channel Backup
        internal static let channelBackup = L10n.tr("Localizable", "scene.settings.item.channel_backup")
        /// Currency
        internal static let currency = L10n.tr("Localizable", "scene.settings.item.currency")
        /// Need Help?
        internal static let help = L10n.tr("Localizable", "scene.settings.item.help")
        /// Lightning Payment Fee Limit
        internal static let lightningPaymentFeeLimit = L10n.tr("Localizable", "scene.settings.item.lightning_payment_fee_limit")
        /// Lightning Request Expiry
        internal static let lightningRequestExpiry = L10n.tr("Localizable", "scene.settings.item.lightning_request_expiry")
        /// Show lnd Log
        internal static let lndLog = L10n.tr("Localizable", "scene.settings.item.lnd_log")
        /// Manage Channels
        internal static let manageChannels = L10n.tr("Localizable", "scene.settings.item.manage_channels")
        /// Privacy Policy
        internal static let privacyPolicy = L10n.tr("Localizable", "scene.settings.item.privacy_policy")
        /// Manage Wallets
        internal static let removeRemoteNode = L10n.tr("Localizable", "scene.settings.item.remove_remote_node")
        /// Report an Issue
        internal static let reportIssue = L10n.tr("Localizable", "scene.settings.item.report_issue")
        /// Your lnd is outdated (%@). Zap iOS works best with lnd version %@ or above.
        internal static func versionWarning(_ p1: String, _ p2: String) -> String {
          return L10n.tr("Localizable", "scene.settings.item.version_warning", p1, p2)
        }
        internal enum Currency {
          /// Popular Currencies
          internal static let popular = L10n.tr("Localizable", "scene.settings.item.currency.popular")
        }
        internal enum OnChainRequestAddress {
          /// Bech32
          internal static let bech32 = L10n.tr("Localizable", "scene.settings.item.on_chain_request_address.bech32")
          /// P2SH
          internal static let p2sh = L10n.tr("Localizable", "scene.settings.item.on_chain_request_address.p2sh")
          /// Bitcoin Address Type
          internal static let title = L10n.tr("Localizable", "scene.settings.item.on_chain_request_address.title")
        }
      }
      internal enum Section {
        /// Lightning
        internal static let lightning = L10n.tr("Localizable", "scene.settings.section.lightning")
        /// Wallet
        internal static let wallet = L10n.tr("Localizable", "scene.settings.section.wallet")
        /// Warning
        internal static let warning = L10n.tr("Localizable", "scene.settings.section.warning")
      }
    }
    internal enum SetupPin {
      /// Done
      internal static let doneButton = L10n.tr("Localizable", "scene.setup_pin.done_button")
      internal enum TopLabel {
        /// Choose a pin.
        internal static let initial = L10n.tr("Localizable", "scene.setup_pin.top_label.initial")
        /// The pins didn't match. Please try again.
        internal static let nonMatching = L10n.tr("Localizable", "scene.setup_pin.top_label.non_matching")
        /// Enter the pin again to validate.
        internal static let validate = L10n.tr("Localizable", "scene.setup_pin.top_label.validate")
      }
    }
    internal enum Sync {
      /// Syncing to blockchain…
      internal static let descriptionLabel = L10n.tr("Localizable", "scene.sync.description_label")
    }
    internal enum TimeLock {
      /// Your wallet is locked for:
      internal static let description = L10n.tr("Localizable", "scene.time_lock.description")
      /// Wrong Passcode
      internal static let headline = L10n.tr("Localizable", "scene.time_lock.headline")
    }
    internal enum TransactionDetail {
      /// Address
      internal static let addressLabel = L10n.tr("Localizable", "scene.transaction_detail.address_label")
      /// Amount
      internal static let amountLabel = L10n.tr("Localizable", "scene.transaction_detail.amount_label")
      /// Date
      internal static let dateLabel = L10n.tr("Localizable", "scene.transaction_detail.date_label")
      /// Expiry
      internal static let expiryLabel = L10n.tr("Localizable", "scene.transaction_detail.expiry_label")
      /// Fee
      internal static let feeLabel = L10n.tr("Localizable", "scene.transaction_detail.fee_label")
      /// Invoice copied.
      internal static let invoiceCopyMessage = L10n.tr("Localizable", "scene.transaction_detail.invoice_copy_message")
      /// State
      internal static let invoiceStateLabel = L10n.tr("Localizable", "scene.transaction_detail.invoice_state_label")
      /// Memo
      internal static let memoLabel = L10n.tr("Localizable", "scene.transaction_detail.memo_label")
      /// Preimage copied.
      internal static let preimageCopyMessage = L10n.tr("Localizable", "scene.transaction_detail.preimage_copy_message")
      /// Preimage
      internal static let preimageLabel = L10n.tr("Localizable", "scene.transaction_detail.preimage_label")
      /// Transaction ID
      internal static let transactionIdLabel = L10n.tr("Localizable", "scene.transaction_detail.transaction_id_label")
      internal enum ExpiryLabel {
        /// Expired
        internal static let expired = L10n.tr("Localizable", "scene.transaction_detail.expiry_label.expired")
      }
      internal enum InvoiceStateLabel {
        /// settled
        internal static let settled = L10n.tr("Localizable", "scene.transaction_detail.invoice_state_label.settled")
      }
      internal enum Title {
        /// Channel Event
        internal static let channelEventDetail = L10n.tr("Localizable", "scene.transaction_detail.title.channel_event_detail")
        /// Failed Payment
        internal static let failedPayment = L10n.tr("Localizable", "scene.transaction_detail.title.failed_payment")
        /// Invoice Detail
        internal static let lightningInvoice = L10n.tr("Localizable", "scene.transaction_detail.title.lightning_invoice")
        /// Payment Detail
        internal static let paymentDetail = L10n.tr("Localizable", "scene.transaction_detail.title.payment_detail")
        /// Transaction Detail
        internal static let transactionDetail = L10n.tr("Localizable", "scene.transaction_detail.title.transaction_detail")
      }
    }
    internal enum Unlock {
      /// Password
      internal static let passwordPlaceholder = L10n.tr("Localizable", "scene.unlock.password_placeholder")
      /// Unlock Node
      internal static let title = L10n.tr("Localizable", "scene.unlock.title")
      /// Unlock %@
      internal static func titleLabel(_ p1: String) -> String {
        return L10n.tr("Localizable", "scene.unlock.title_label", p1)
      }
      /// Unlock
      internal static let unlockButton = L10n.tr("Localizable", "scene.unlock.unlock_button")
    }
    internal enum Wallet {
      /// Wallet
      internal static let title = L10n.tr("Localizable", "scene.wallet.title")
      /// Total Balance
      internal static let totalBalance = L10n.tr("Localizable", "scene.wallet.total_balance")
      internal enum Detail {
        /// Lightning:
        internal static let lightning = L10n.tr("Localizable", "scene.wallet.detail.lightning")
        /// On-chain:
        internal static let onChain = L10n.tr("Localizable", "scene.wallet.detail.on_chain")
        /// Pending:
        internal static let pending = L10n.tr("Localizable", "scene.wallet.detail.pending")
      }
      internal enum EmptyState {
        /// Deposit funds
        internal static let buttonTitle = L10n.tr("Localizable", "scene.wallet.empty_state.button_title")
        /// Your wallet is empty! Get started by depositing some funds.
        internal static let message = L10n.tr("Localizable", "scene.wallet.empty_state.message")
        /// Fund your wallet
        internal static let title = L10n.tr("Localizable", "scene.wallet.empty_state.title")
      }
      internal enum OpenChannel {
        /// Open a channel
        internal static let action = L10n.tr("Localizable", "scene.wallet.open_channel.action")
        /// You can’t transact on the the Lightning Network yet. Open a channel to start.
        internal static let message = L10n.tr("Localizable", "scene.wallet.open_channel.message")
      }
    }
    internal enum WalletList {
      /// Wallets
      internal static let title = L10n.tr("Localizable", "scene.wallet_list.title")
    }
  }

  internal enum Toast {
    /// Did receive %@
    internal static func invoice(_ p1: String) -> String {
      return L10n.tr("Localizable", "toast.invoice", p1)
    }
    /// Did receive %@ "%@"
    internal static func invoiceMemo(_ p1: String, _ p2: String) -> String {
      return L10n.tr("Localizable", "toast.invoice_memo", p1, p2)
    }
  }

  internal enum Transaction {
    /// No destination address
    internal static let noDestinationAddress = L10n.tr("Localizable", "transaction.no_destination_address")
  }

  internal enum Unit {
    internal enum Bitcoin {
      /// Bits
      internal static let bit = L10n.tr("Localizable", "unit.bitcoin.bit")
      /// Bitcoin
      internal static let btc = L10n.tr("Localizable", "unit.bitcoin.btc")
      /// Milli Bitcoin
      internal static let mbtc = L10n.tr("Localizable", "unit.bitcoin.mbtc")
      /// Satoshis
      internal static let satoshi = L10n.tr("Localizable", "unit.bitcoin.satoshi")
    }
  }

  internal enum View {
    internal enum AmountInput {
      /// Amount
      internal static let placeholder = L10n.tr("Localizable", "view.amount_input.placeholder")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
