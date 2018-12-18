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
    /// https://ln-zap.github.io/zap-tutorials/
    internal static let help = L10n.tr("Localizable", "link.help")
    internal enum Help {
      /// https://ln-zap.github.io/zap-tutorials/iOS-remote-node-setup
      internal static let zapconnect = L10n.tr("Localizable", "link.help.zapconnect")
    }
  }

  internal enum NetworkType {
    /// Mainnet
    internal static let mainnet = L10n.tr("Localizable", "network_type.mainnet")
    /// Testnet
    internal static let testnet = L10n.tr("Localizable", "network_type.testnet")
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
    internal enum ChannelDetail {
      /// Close Channel
      internal static let closeButton = L10n.tr("Localizable", "scene.channel_detail.close_button")
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
      internal enum ForceClose {
        /// %@ is offline, are you sure you want to force close this channel? You’d have to wait about %@ for your funds?
        internal static func message(_ p1: String, _ p2: String) -> String {
          return L10n.tr("Localizable", "scene.channels.force_close.message", p1, p2)
        }
        /// Force Close Channel
        internal static let title = L10n.tr("Localizable", "scene.channels.force_close.title")
      }
    }
    internal enum ConfirmMnemonic {
      /// Enter your key.
      internal static let description = L10n.tr("Localizable", "scene.confirm_mnemonic.description")
      /// Confirm Seed
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
      /// Certificate
      internal static let certificateLabel = L10n.tr("Localizable", "scene.connect_remote_node.certificate_label")
      /// Connect
      internal static let connectButton = L10n.tr("Localizable", "scene.connect_remote_node.connect_button")
      /// Scan the QRCode generated by zapconnect or paste the connection code to connect to your node.
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
      /// Make sure to store the mnemonic at a save location.
      internal static let descriptionLabel = L10n.tr("Localizable", "scene.create_wallet.description_label")
      /// Next
      internal static let nextButton = L10n.tr("Localizable", "scene.create_wallet.next_button")
      /// Create Wallet
      internal static let title = L10n.tr("Localizable", "scene.create_wallet.title")
    }
    internal enum Filter {
      /// Internal Transactions
      internal static let displayUnknownTransactionType = L10n.tr("Localizable", "scene.filter.display_unknown_transaction_type")
      /// Channel Events
      internal static let displayChannelEvents = L10n.tr("Localizable", "scene.filter.displayChannelEvents")
      /// Failed Payments
      internal static let displayFailedPaymentEvents = L10n.tr("Localizable", "scene.filter.displayFailedPaymentEvents")
      /// Created Invoices
      internal static let displayLightningInvoices = L10n.tr("Localizable", "scene.filter.displayLightningInvoices")
      /// Lightning Payments
      internal static let displayLightningPayments = L10n.tr("Localizable", "scene.filter.displayLightningPayments")
      /// On-chain Payments
      internal static let displayOnChainTransactions = L10n.tr("Localizable", "scene.filter.displayOnChainTransactions")
      /// Filter
      internal static let title = L10n.tr("Localizable", "scene.filter.title")
      internal enum SectionHeader {
        /// Advanced
        internal static let advanced = L10n.tr("Localizable", "scene.filter.section_header.advanced")
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
        /// Breach close Channel
        internal static let breachCloseChannel = L10n.tr("Localizable", "scene.history.cell.breach_close_channel")
        /// Channel abandoned
        internal static let channelAbandoned = L10n.tr("Localizable", "scene.history.cell.channel_abandoned")
        /// Close Channel
        internal static let channelClosed = L10n.tr("Localizable", "scene.history.cell.channel_closed")
        /// Open Channel
        internal static let channelOpened = L10n.tr("Localizable", "scene.history.cell.channel_opened")
        /// Close Channel (funding canceled)
        internal static let closeChannelFundingCanceled = L10n.tr("Localizable", "scene.history.cell.close_channel_funding_canceled")
        /// Force close Channel
        internal static let forceCloseChannel = L10n.tr("Localizable", "scene.history.cell.force_close_channel")
        /// Payment Request created
        internal static let invoiceCreated = L10n.tr("Localizable", "scene.history.cell.invoice_created")
        /// Payment failed (%@)
        internal static func paymentFailed(_ p1: String) -> String {
          return L10n.tr("Localizable", "scene.history.cell.payment_failed", p1)
        }
        /// Payment received
        internal static let paymentReceived = L10n.tr("Localizable", "scene.history.cell.payment_received")
        /// Payment sent
        internal static let paymentSent = L10n.tr("Localizable", "scene.history.cell.payment_sent")
        /// Remote force close Channel
        internal static let remoteForceCloseChannel = L10n.tr("Localizable", "scene.history.cell.remote_force_close_channel")
        /// Payment received
        internal static let transactionReceived = L10n.tr("Localizable", "scene.history.cell.transaction_received")
        /// Payment sent
        internal static let transactionSent = L10n.tr("Localizable", "scene.history.cell.transaction_sent")
        internal enum Action {
          /// Try Again
          internal static let tryAgain = L10n.tr("Localizable", "scene.history.cell.action.try_again")
        }
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
    internal enum ModalPin {
      /// Please enter your passcode to continue
      internal static let description = L10n.tr("Localizable", "scene.modal_pin.description")
      /// Enter Passcode
      internal static let headline = L10n.tr("Localizable", "scene.modal_pin.headline")
    }
    internal enum NodeUri {
      /// Alias
      internal static let aliasLabel = L10n.tr("Localizable", "scene.node_uri.alias_label")
      /// Connect to Node
      internal static let title = L10n.tr("Localizable", "scene.node_uri.title")
      /// URI
      internal static let uriLabel = L10n.tr("Localizable", "scene.node_uri.uri_label")
    }
    internal enum OpenChannel {
      /// Open Channel
      internal static let addButton = L10n.tr("Localizable", "scene.open_channel.add_button")
      /// Channel:
      internal static let channelUriLabel = L10n.tr("Localizable", "scene.open_channel.channel_uri_label")
      /// Open Channel
      internal static let title = L10n.tr("Localizable", "scene.open_channel.title")
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
    internal enum QrCodeDetail {
      /// Receive
      internal static let title = L10n.tr("Localizable", "scene.qr_code_detail.title")
    }
    internal enum QrcodeScanner {
      /// Scan QR-Code
      internal static let topLabel = L10n.tr("Localizable", "scene.qrcode_scanner.top_label")
    }
    internal enum RecoverWallet {
      /// Enter your seed:
      internal static let descriptionLabel = L10n.tr("Localizable", "scene.recover_wallet.description_label")
      /// Done
      internal static let doneButton = L10n.tr("Localizable", "scene.recover_wallet.done_button")
      /// abandon ability able about above absent absorb abstract absurd abuse access accident account accuse achieve acid acoustic acquire across act action actor actress actual
      internal static let placeholder = L10n.tr("Localizable", "scene.recover_wallet.placeholder")
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
      /// On Chain Payment Request
      internal static let onChainHeaderTitle = L10n.tr("Localizable", "scene.request.on_chain_header_title")
      /// or
      internal static let orSeparatorLabel = L10n.tr("Localizable", "scene.request.or_separator_label")
      /// Receive
      internal static let title = L10n.tr("Localizable", "scene.request.title")
    }
    internal enum SelectWalletConnection {
      /// Setup Zap
      internal static let title = L10n.tr("Localizable", "scene.select_wallet_connection.title")
      internal enum Connect {
        /// remote node
        internal static let message = L10n.tr("Localizable", "scene.select_wallet_connection.connect.message")
        /// Connect
        internal static let title = L10n.tr("Localizable", "scene.select_wallet_connection.connect.title")
      }
      internal enum Create {
        /// Need Help?
        internal static let help = L10n.tr("Localizable", "scene.select_wallet_connection.create.help")
        /// new wallet
        internal static let message = L10n.tr("Localizable", "scene.select_wallet_connection.create.message")
        /// Create
        internal static let title = L10n.tr("Localizable", "scene.select_wallet_connection.create.title")
      }
      internal enum DisabledAlert {
        /// Running Lnd on the phone is disabled in this beta. Connect to a remote node instead.
        internal static let message = L10n.tr("Localizable", "scene.select_wallet_connection.disabled_alert.message")
        /// Ok
        internal static let okButton = L10n.tr("Localizable", "scene.select_wallet_connection.disabled_alert.ok_button")
        /// Sorry!
        internal static let title = L10n.tr("Localizable", "scene.select_wallet_connection.disabled_alert.title")
      }
      internal enum Recover {
        /// existing wallet
        internal static let message = L10n.tr("Localizable", "scene.select_wallet_connection.recover.message")
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
      /// Send
      internal static let title = L10n.tr("Localizable", "scene.send.title")
      internal enum Lightning {
        /// Send Lightning Payment
        internal static let title = L10n.tr("Localizable", "scene.send.lightning.title")
      }
      internal enum OnChain {
        /// Send On Chain
        internal static let title = L10n.tr("Localizable", "scene.send.on_chain.title")
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
        /// Currency
        internal static let currency = L10n.tr("Localizable", "scene.settings.item.currency")
        /// Need Help?
        internal static let help = L10n.tr("Localizable", "scene.settings.item.help")
        /// Manage Channels
        internal static let manageChannels = L10n.tr("Localizable", "scene.settings.item.manage_channels")
        /// Node URI
        internal static let nodeUri = L10n.tr("Localizable", "scene.settings.item.node_uri")
        /// Privacy Policy
        internal static let privacyPolicy = L10n.tr("Localizable", "scene.settings.item.privacy_policy")
        /// Reset Remote Node Connection
        internal static let removeRemoteNode = L10n.tr("Localizable", "scene.settings.item.remove_remote_node")
        /// Report an Issue
        internal static let reportIssue = L10n.tr("Localizable", "scene.settings.item.report_issue")
        internal enum OnChainRequestAddress {
          /// Bech32
          internal static let bech32 = L10n.tr("Localizable", "scene.settings.item.on_chain_request_address.bech32")
          /// P2SH
          internal static let p2sh = L10n.tr("Localizable", "scene.settings.item.on_chain_request_address.p2sh")
          /// Bitcoin Address Type
          internal static let title = L10n.tr("Localizable", "scene.settings.item.on_chain_request_address.title")
        }
        internal enum RemoveRemoteNode {
          internal enum Confirmation {
            /// Disconnect
            internal static let button = L10n.tr("Localizable", "scene.settings.item.remove_remote_node.confirmation.button")
            /// You will have to reconnect to your node afterwards.
            internal static let message = L10n.tr("Localizable", "scene.settings.item.remove_remote_node.confirmation.message")
            /// Disconnect Remote Node?
            internal static let title = L10n.tr("Localizable", "scene.settings.item.remove_remote_node.confirmation.title")
          }
        }
      }
      internal enum Section {
        /// Wallet
        internal static let wallet = L10n.tr("Localizable", "scene.settings.section.wallet")
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
      /// Disconnect
      internal static let disconnectBarButton = L10n.tr("Localizable", "scene.sync.disconnect_bar_button")
      internal enum DisconnectAlert {
        /// Cancel
        internal static let cancelAction = L10n.tr("Localizable", "scene.sync.disconnect_alert.cancel_action")
        /// Disconnect Node
        internal static let destructiveAction = L10n.tr("Localizable", "scene.sync.disconnect_alert.destructive_action")
        /// Do you really want to cancel syncing? You will have to reconnect to your node afterwards.
        internal static let message = L10n.tr("Localizable", "scene.sync.disconnect_alert.message")
        /// Disconnect
        internal static let title = L10n.tr("Localizable", "scene.sync.disconnect_alert.title")
      }
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
      /// Memo
      internal static let memoLabel = L10n.tr("Localizable", "scene.transaction_detail.memo_label")
      /// Transaction ID
      internal static let transactionIdLabel = L10n.tr("Localizable", "scene.transaction_detail.transaction_id_label")
      internal enum ExpiryLabel {
        /// Expired
        internal static let expired = L10n.tr("Localizable", "scene.transaction_detail.expiry_label.expired")
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
    internal enum Wallet {
      /// Wallet
      internal static let title = L10n.tr("Localizable", "scene.wallet.title")
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
