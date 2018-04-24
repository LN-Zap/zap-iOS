#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#import "Rpc.pbobjc.h"
#endif

#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import <ProtoRPC/ProtoService.h>
#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>
#endif

#if defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) && GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
  @class AddInvoiceResponse;
  @class ChanInfoRequest;
  @class ChannelBalanceRequest;
  @class ChannelBalanceResponse;
  @class ChannelEdge;
  @class ChannelGraph;
  @class ChannelGraphRequest;
  @class ChannelPoint;
  @class CloseChannelRequest;
  @class CloseStatusUpdate;
  @class ConnectPeerRequest;
  @class ConnectPeerResponse;
  @class DebugLevelRequest;
  @class DebugLevelResponse;
  @class DeleteAllPaymentsRequest;
  @class DeleteAllPaymentsResponse;
  @class DisconnectPeerRequest;
  @class DisconnectPeerResponse;
  @class FeeReportRequest;
  @class FeeReportResponse;
  @class ForwardingHistoryRequest;
  @class ForwardingHistoryResponse;
  @class GenSeedRequest;
  @class GenSeedResponse;
  @class GetInfoRequest;
  @class GetInfoResponse;
  @class GetTransactionsRequest;
  @class GraphTopologySubscription;
  @class GraphTopologyUpdate;
  @class InitWalletRequest;
  @class InitWalletResponse;
  @class Invoice;
  @class InvoiceSubscription;
  @class ListChannelsRequest;
  @class ListChannelsResponse;
  @class ListInvoiceRequest;
  @class ListInvoiceResponse;
  @class ListPaymentsRequest;
  @class ListPaymentsResponse;
  @class ListPeersRequest;
  @class ListPeersResponse;
  @class NetworkInfo;
  @class NetworkInfoRequest;
  @class NewAddressRequest;
  @class NewAddressResponse;
  @class NewWitnessAddressRequest;
  @class NodeInfo;
  @class NodeInfoRequest;
  @class OpenChannelRequest;
  @class OpenStatusUpdate;
  @class PayReq;
  @class PayReqString;
  @class PaymentHash;
  @class PendingChannelsRequest;
  @class PendingChannelsResponse;
  @class PolicyUpdateRequest;
  @class PolicyUpdateResponse;
  @class QueryRoutesRequest;
  @class QueryRoutesResponse;
  @class SendCoinsRequest;
  @class SendCoinsResponse;
  @class SendManyRequest;
  @class SendManyResponse;
  @class SendRequest;
  @class SendResponse;
  @class SignMessageRequest;
  @class SignMessageResponse;
  @class StopRequest;
  @class StopResponse;
  @class Transaction;
  @class TransactionDetails;
  @class UnlockWalletRequest;
  @class UnlockWalletResponse;
  @class VerifyMessageRequest;
  @class VerifyMessageResponse;
  @class WalletBalanceRequest;
  @class WalletBalanceResponse;
#else
//  #import "google/api/Annotations.pbobjc.h"
#endif

@class GRPCProtoCall;


NS_ASSUME_NONNULL_BEGIN

@protocol WalletUnlocker <NSObject>

#pragma mark GenSeed(GenSeedRequest) returns (GenSeedResponse)

/**
 * *
 * GenSeed is the first method that should be used to instantiate a new lnd
 * instance. This method allows a caller to generate a new aezeed cipher seed
 * given an optional passphrase. If provided, the passphrase will be necessary
 * to decrypt the cipherseed to expose the internal wallet seed.
 * 
 * Once the cipherseed is obtained and verified by the user, the InitWallet
 * method should be used to commit the newly generated seed, and create the
 * wallet.
 */
- (void)genSeedWithRequest:(GenSeedRequest *)request handler:(void(^)(GenSeedResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * *
 * GenSeed is the first method that should be used to instantiate a new lnd
 * instance. This method allows a caller to generate a new aezeed cipher seed
 * given an optional passphrase. If provided, the passphrase will be necessary
 * to decrypt the cipherseed to expose the internal wallet seed.
 * 
 * Once the cipherseed is obtained and verified by the user, the InitWallet
 * method should be used to commit the newly generated seed, and create the
 * wallet.
 */
- (GRPCProtoCall *)RPCToGenSeedWithRequest:(GenSeedRequest *)request handler:(void(^)(GenSeedResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark InitWallet(InitWalletRequest) returns (InitWalletResponse)

/**
 * * 
 * InitWallet is used when lnd is starting up for the first time to fully
 * initialize the daemon and its internal wallet. At the very least a wallet
 * password must be provided. This will be used to encrypt sensitive material
 * on disk.
 * 
 * In the case of a recovery scenario, the user can also specify their aezeed
 * mnemonic and passphrase. If set, then the daemon will use this prior state
 * to initialize its internal wallet.
 * 
 * Alternatively, this can be used along with the GenSeed RPC to obtain a
 * seed, then present it to the user. Once it has been verified by the user,
 * the seed can be fed into this RPC in order to commit the new wallet.
 */
- (void)initWalletWithRequest:(InitWalletRequest *)request handler:(void(^)(InitWalletResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * 
 * InitWallet is used when lnd is starting up for the first time to fully
 * initialize the daemon and its internal wallet. At the very least a wallet
 * password must be provided. This will be used to encrypt sensitive material
 * on disk.
 * 
 * In the case of a recovery scenario, the user can also specify their aezeed
 * mnemonic and passphrase. If set, then the daemon will use this prior state
 * to initialize its internal wallet.
 * 
 * Alternatively, this can be used along with the GenSeed RPC to obtain a
 * seed, then present it to the user. Once it has been verified by the user,
 * the seed can be fed into this RPC in order to commit the new wallet.
 */
- (GRPCProtoCall *)RPCToInitWalletWithRequest:(InitWalletRequest *)request handler:(void(^)(InitWalletResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark UnlockWallet(UnlockWalletRequest) returns (UnlockWalletResponse)

/**
 * * lncli: `unlock`
 * UnlockWallet is used at startup of lnd to provide a password to unlock
 * the wallet database.
 */
- (void)unlockWalletWithRequest:(UnlockWalletRequest *)request handler:(void(^)(UnlockWalletResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `unlock`
 * UnlockWallet is used at startup of lnd to provide a password to unlock
 * the wallet database.
 */
- (GRPCProtoCall *)RPCToUnlockWalletWithRequest:(UnlockWalletRequest *)request handler:(void(^)(UnlockWalletResponse *_Nullable response, NSError *_Nullable error))handler;


@end

@protocol Lightning <NSObject>

#pragma mark WalletBalance(WalletBalanceRequest) returns (WalletBalanceResponse)

/**
 * * lncli: `walletbalance`
 * WalletBalance returns total unspent outputs(confirmed and unconfirmed), all
 * confirmed unspent outputs and all unconfirmed unspent outputs under control
 * of the wallet. 
 */
- (void)walletBalanceWithRequest:(WalletBalanceRequest *)request handler:(void(^)(WalletBalanceResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `walletbalance`
 * WalletBalance returns total unspent outputs(confirmed and unconfirmed), all
 * confirmed unspent outputs and all unconfirmed unspent outputs under control
 * of the wallet. 
 */
- (GRPCProtoCall *)RPCToWalletBalanceWithRequest:(WalletBalanceRequest *)request handler:(void(^)(WalletBalanceResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ChannelBalance(ChannelBalanceRequest) returns (ChannelBalanceResponse)

/**
 * * lncli: `channelbalance`
 * ChannelBalance returns the total funds available across all open channels
 * in satoshis.
 */
- (void)channelBalanceWithRequest:(ChannelBalanceRequest *)request handler:(void(^)(ChannelBalanceResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `channelbalance`
 * ChannelBalance returns the total funds available across all open channels
 * in satoshis.
 */
- (GRPCProtoCall *)RPCToChannelBalanceWithRequest:(ChannelBalanceRequest *)request handler:(void(^)(ChannelBalanceResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetTransactions(GetTransactionsRequest) returns (TransactionDetails)

/**
 * * lncli: `listchaintxns`
 * GetTransactions returns a list describing all the known transactions
 * relevant to the wallet.
 */
- (void)getTransactionsWithRequest:(GetTransactionsRequest *)request handler:(void(^)(TransactionDetails *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listchaintxns`
 * GetTransactions returns a list describing all the known transactions
 * relevant to the wallet.
 */
- (GRPCProtoCall *)RPCToGetTransactionsWithRequest:(GetTransactionsRequest *)request handler:(void(^)(TransactionDetails *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SendCoins(SendCoinsRequest) returns (SendCoinsResponse)

/**
 * * lncli: `sendcoins`
 * SendCoins executes a request to send coins to a particular address. Unlike
 * SendMany, this RPC call only allows creating a single output at a time. If
 * neither target_conf, or sat_per_byte are set, then the internal wallet will
 * consult its fee model to determine a fee for the default confirmation
 * target.
 */
- (void)sendCoinsWithRequest:(SendCoinsRequest *)request handler:(void(^)(SendCoinsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `sendcoins`
 * SendCoins executes a request to send coins to a particular address. Unlike
 * SendMany, this RPC call only allows creating a single output at a time. If
 * neither target_conf, or sat_per_byte are set, then the internal wallet will
 * consult its fee model to determine a fee for the default confirmation
 * target.
 */
- (GRPCProtoCall *)RPCToSendCoinsWithRequest:(SendCoinsRequest *)request handler:(void(^)(SendCoinsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SubscribeTransactions(GetTransactionsRequest) returns (stream Transaction)

/**
 * *
 * SubscribeTransactions creates a uni-directional stream from the server to
 * the client in which any newly discovered transactions relevant to the
 * wallet are sent over.
 */
- (void)subscribeTransactionsWithRequest:(GetTransactionsRequest *)request eventHandler:(void(^)(BOOL done, Transaction *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * *
 * SubscribeTransactions creates a uni-directional stream from the server to
 * the client in which any newly discovered transactions relevant to the
 * wallet are sent over.
 */
- (GRPCProtoCall *)RPCToSubscribeTransactionsWithRequest:(GetTransactionsRequest *)request eventHandler:(void(^)(BOOL done, Transaction *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark SendMany(SendManyRequest) returns (SendManyResponse)

/**
 * * lncli: `sendmany`
 * SendMany handles a request for a transaction that creates multiple specified
 * outputs in parallel. If neither target_conf, or sat_per_byte are set, then
 * the internal wallet will consult its fee model to determine a fee for the
 * default confirmation target.
 */
- (void)sendManyWithRequest:(SendManyRequest *)request handler:(void(^)(SendManyResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `sendmany`
 * SendMany handles a request for a transaction that creates multiple specified
 * outputs in parallel. If neither target_conf, or sat_per_byte are set, then
 * the internal wallet will consult its fee model to determine a fee for the
 * default confirmation target.
 */
- (GRPCProtoCall *)RPCToSendManyWithRequest:(SendManyRequest *)request handler:(void(^)(SendManyResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark NewAddress(NewAddressRequest) returns (NewAddressResponse)

/**
 * * lncli: `newaddress`
 * NewAddress creates a new address under control of the local wallet.
 */
- (void)newAddressWithRequest:(NewAddressRequest *)request handler:(void(^)(NewAddressResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `newaddress`
 * NewAddress creates a new address under control of the local wallet.
 */
- (GRPCProtoCall *)RPCToNewAddressWithRequest:(NewAddressRequest *)request handler:(void(^)(NewAddressResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark NewWitnessAddress(NewWitnessAddressRequest) returns (NewAddressResponse)

/**
 * *
 * NewWitnessAddress creates a new witness address under control of the local wallet.
 */
- (void)newWitnessAddressWithRequest:(NewWitnessAddressRequest *)request handler:(void(^)(NewAddressResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * *
 * NewWitnessAddress creates a new witness address under control of the local wallet.
 */
- (GRPCProtoCall *)RPCToNewWitnessAddressWithRequest:(NewWitnessAddressRequest *)request handler:(void(^)(NewAddressResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SignMessage(SignMessageRequest) returns (SignMessageResponse)

/**
 * * lncli: `signmessage`
 * SignMessage signs a message with this node's private key. The returned
 * signature string is `zbase32` encoded and pubkey recoverable, meaning that
 * only the message digest and signature are needed for verification.
 */
- (void)signMessageWithRequest:(SignMessageRequest *)request handler:(void(^)(SignMessageResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `signmessage`
 * SignMessage signs a message with this node's private key. The returned
 * signature string is `zbase32` encoded and pubkey recoverable, meaning that
 * only the message digest and signature are needed for verification.
 */
- (GRPCProtoCall *)RPCToSignMessageWithRequest:(SignMessageRequest *)request handler:(void(^)(SignMessageResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark VerifyMessage(VerifyMessageRequest) returns (VerifyMessageResponse)

/**
 * * lncli: `verifymessage`
 * VerifyMessage verifies a signature over a msg. The signature must be
 * zbase32 encoded and signed by an active node in the resident node's
 * channel database. In addition to returning the validity of the signature,
 * VerifyMessage also returns the recovered pubkey from the signature.
 */
- (void)verifyMessageWithRequest:(VerifyMessageRequest *)request handler:(void(^)(VerifyMessageResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `verifymessage`
 * VerifyMessage verifies a signature over a msg. The signature must be
 * zbase32 encoded and signed by an active node in the resident node's
 * channel database. In addition to returning the validity of the signature,
 * VerifyMessage also returns the recovered pubkey from the signature.
 */
- (GRPCProtoCall *)RPCToVerifyMessageWithRequest:(VerifyMessageRequest *)request handler:(void(^)(VerifyMessageResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ConnectPeer(ConnectPeerRequest) returns (ConnectPeerResponse)

/**
 * * lncli: `connect`
 * ConnectPeer attempts to establish a connection to a remote peer. This is at
 * the networking level, and is used for communication between nodes. This is
 * distinct from establishing a channel with a peer.
 */
- (void)connectPeerWithRequest:(ConnectPeerRequest *)request handler:(void(^)(ConnectPeerResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `connect`
 * ConnectPeer attempts to establish a connection to a remote peer. This is at
 * the networking level, and is used for communication between nodes. This is
 * distinct from establishing a channel with a peer.
 */
- (GRPCProtoCall *)RPCToConnectPeerWithRequest:(ConnectPeerRequest *)request handler:(void(^)(ConnectPeerResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark DisconnectPeer(DisconnectPeerRequest) returns (DisconnectPeerResponse)

/**
 * * lncli: `disconnect`
 * DisconnectPeer attempts to disconnect one peer from another identified by a
 * given pubKey. In the case that we currently have a pending or active channel
 * with the target peer, then this action will be not be allowed.
 */
- (void)disconnectPeerWithRequest:(DisconnectPeerRequest *)request handler:(void(^)(DisconnectPeerResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `disconnect`
 * DisconnectPeer attempts to disconnect one peer from another identified by a
 * given pubKey. In the case that we currently have a pending or active channel
 * with the target peer, then this action will be not be allowed.
 */
- (GRPCProtoCall *)RPCToDisconnectPeerWithRequest:(DisconnectPeerRequest *)request handler:(void(^)(DisconnectPeerResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ListPeers(ListPeersRequest) returns (ListPeersResponse)

/**
 * * lncli: `listpeers`
 * ListPeers returns a verbose listing of all currently active peers.
 */
- (void)listPeersWithRequest:(ListPeersRequest *)request handler:(void(^)(ListPeersResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listpeers`
 * ListPeers returns a verbose listing of all currently active peers.
 */
- (GRPCProtoCall *)RPCToListPeersWithRequest:(ListPeersRequest *)request handler:(void(^)(ListPeersResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetInfo(GetInfoRequest) returns (GetInfoResponse)

/**
 * * lncli: `getinfo`
 * GetInfo returns general information concerning the lightning node including
 * it's identity pubkey, alias, the chains it is connected to, and information
 * concerning the number of open+pending channels.
 */
- (void)getInfoWithRequest:(GetInfoRequest *)request handler:(void(^)(GetInfoResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `getinfo`
 * GetInfo returns general information concerning the lightning node including
 * it's identity pubkey, alias, the chains it is connected to, and information
 * concerning the number of open+pending channels.
 */
- (GRPCProtoCall *)RPCToGetInfoWithRequest:(GetInfoRequest *)request handler:(void(^)(GetInfoResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark PendingChannels(PendingChannelsRequest) returns (PendingChannelsResponse)

/**
 * TODO(roasbeef): merge with below with bool?
 * 
 * * lncli: `pendingchannels`
 * PendingChannels returns a list of all the channels that are currently
 * considered "pending". A channel is pending if it has finished the funding
 * workflow and is waiting for confirmations for the funding txn, or is in the
 * process of closure, either initiated cooperatively or non-cooperatively.
 */
- (void)pendingChannelsWithRequest:(PendingChannelsRequest *)request handler:(void(^)(PendingChannelsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * TODO(roasbeef): merge with below with bool?
 * 
 * * lncli: `pendingchannels`
 * PendingChannels returns a list of all the channels that are currently
 * considered "pending". A channel is pending if it has finished the funding
 * workflow and is waiting for confirmations for the funding txn, or is in the
 * process of closure, either initiated cooperatively or non-cooperatively.
 */
- (GRPCProtoCall *)RPCToPendingChannelsWithRequest:(PendingChannelsRequest *)request handler:(void(^)(PendingChannelsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ListChannels(ListChannelsRequest) returns (ListChannelsResponse)

/**
 * * lncli: `listchannels`
 * ListChannels returns a description of all the open channels that this node
 * is a participant in.
 */
- (void)listChannelsWithRequest:(ListChannelsRequest *)request handler:(void(^)(ListChannelsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listchannels`
 * ListChannels returns a description of all the open channels that this node
 * is a participant in.
 */
- (GRPCProtoCall *)RPCToListChannelsWithRequest:(ListChannelsRequest *)request handler:(void(^)(ListChannelsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark OpenChannelSync(OpenChannelRequest) returns (ChannelPoint)

/**
 * *
 * OpenChannelSync is a synchronous version of the OpenChannel RPC call. This
 * call is meant to be consumed by clients to the REST proxy. As with all
 * other sync calls, all byte slices are intended to be populated as hex
 * encoded strings.
 */
- (void)openChannelSyncWithRequest:(OpenChannelRequest *)request handler:(void(^)(ChannelPoint *_Nullable response, NSError *_Nullable error))handler;

/**
 * *
 * OpenChannelSync is a synchronous version of the OpenChannel RPC call. This
 * call is meant to be consumed by clients to the REST proxy. As with all
 * other sync calls, all byte slices are intended to be populated as hex
 * encoded strings.
 */
- (GRPCProtoCall *)RPCToOpenChannelSyncWithRequest:(OpenChannelRequest *)request handler:(void(^)(ChannelPoint *_Nullable response, NSError *_Nullable error))handler;


#pragma mark OpenChannel(OpenChannelRequest) returns (stream OpenStatusUpdate)

/**
 * * lncli: `openchannel`
 * OpenChannel attempts to open a singly funded channel specified in the
 * request to a remote peer. Users are able to specify a target number of
 * blocks that the funding transaction should be confirmed in, or a manual fee
 * rate to us for the funding transaction. If neither are specified, then a
 * lax block confirmation target is used.
 */
- (void)openChannelWithRequest:(OpenChannelRequest *)request eventHandler:(void(^)(BOOL done, OpenStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * * lncli: `openchannel`
 * OpenChannel attempts to open a singly funded channel specified in the
 * request to a remote peer. Users are able to specify a target number of
 * blocks that the funding transaction should be confirmed in, or a manual fee
 * rate to us for the funding transaction. If neither are specified, then a
 * lax block confirmation target is used.
 */
- (GRPCProtoCall *)RPCToOpenChannelWithRequest:(OpenChannelRequest *)request eventHandler:(void(^)(BOOL done, OpenStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark CloseChannel(CloseChannelRequest) returns (stream CloseStatusUpdate)

/**
 * * lncli: `closechannel`
 * CloseChannel attempts to close an active channel identified by its channel
 * outpoint (ChannelPoint). The actions of this method can additionally be
 * augmented to attempt a force close after a timeout period in the case of an
 * inactive peer. If a non-force close (cooperative closure) is requested,
 * then the user can specify either a target number of blocks until the
 * closure transaction is confirmed, or a manual fee rate. If neither are
 * specified, then a default lax, block confirmation target is used.
 */
- (void)closeChannelWithRequest:(CloseChannelRequest *)request eventHandler:(void(^)(BOOL done, CloseStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * * lncli: `closechannel`
 * CloseChannel attempts to close an active channel identified by its channel
 * outpoint (ChannelPoint). The actions of this method can additionally be
 * augmented to attempt a force close after a timeout period in the case of an
 * inactive peer. If a non-force close (cooperative closure) is requested,
 * then the user can specify either a target number of blocks until the
 * closure transaction is confirmed, or a manual fee rate. If neither are
 * specified, then a default lax, block confirmation target is used.
 */
- (GRPCProtoCall *)RPCToCloseChannelWithRequest:(CloseChannelRequest *)request eventHandler:(void(^)(BOOL done, CloseStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark SendPayment(stream SendRequest) returns (stream SendResponse)

/**
 * * lncli: `sendpayment`
 * SendPayment dispatches a bi-directional streaming RPC for sending payments
 * through the Lightning Network. A single RPC invocation creates a persistent
 * bi-directional stream allowing clients to rapidly send payments through the
 * Lightning Network with a single persistent connection.
 */
- (void)sendPaymentWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, SendResponse *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * * lncli: `sendpayment`
 * SendPayment dispatches a bi-directional streaming RPC for sending payments
 * through the Lightning Network. A single RPC invocation creates a persistent
 * bi-directional stream allowing clients to rapidly send payments through the
 * Lightning Network with a single persistent connection.
 */
- (GRPCProtoCall *)RPCToSendPaymentWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, SendResponse *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark SendPaymentSync(SendRequest) returns (SendResponse)

/**
 * *
 * SendPaymentSync is the synchronous non-streaming version of SendPayment.
 * This RPC is intended to be consumed by clients of the REST proxy.
 * Additionally, this RPC expects the destination's public key and the payment
 * hash (if any) to be encoded as hex strings.
 */
- (void)sendPaymentSyncWithRequest:(SendRequest *)request handler:(void(^)(SendResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * *
 * SendPaymentSync is the synchronous non-streaming version of SendPayment.
 * This RPC is intended to be consumed by clients of the REST proxy.
 * Additionally, this RPC expects the destination's public key and the payment
 * hash (if any) to be encoded as hex strings.
 */
- (GRPCProtoCall *)RPCToSendPaymentSyncWithRequest:(SendRequest *)request handler:(void(^)(SendResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark AddInvoice(Invoice) returns (AddInvoiceResponse)

/**
 * * lncli: `addinvoice`
 * AddInvoice attempts to add a new invoice to the invoice database. Any
 * duplicated invoices are rejected, therefore all invoices *must* have a
 * unique payment preimage.
 */
- (void)addInvoiceWithRequest:(Invoice *)request handler:(void(^)(AddInvoiceResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `addinvoice`
 * AddInvoice attempts to add a new invoice to the invoice database. Any
 * duplicated invoices are rejected, therefore all invoices *must* have a
 * unique payment preimage.
 */
- (GRPCProtoCall *)RPCToAddInvoiceWithRequest:(Invoice *)request handler:(void(^)(AddInvoiceResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ListInvoices(ListInvoiceRequest) returns (ListInvoiceResponse)

/**
 * * lncli: `listinvoices`
 * ListInvoices returns a list of all the invoices currently stored within the
 * database. Any active debug invoices are ignored.
 */
- (void)listInvoicesWithRequest:(ListInvoiceRequest *)request handler:(void(^)(ListInvoiceResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listinvoices`
 * ListInvoices returns a list of all the invoices currently stored within the
 * database. Any active debug invoices are ignored.
 */
- (GRPCProtoCall *)RPCToListInvoicesWithRequest:(ListInvoiceRequest *)request handler:(void(^)(ListInvoiceResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark LookupInvoice(PaymentHash) returns (Invoice)

/**
 * * lncli: `lookupinvoice`
 * LookupInvoice attempts to look up an invoice according to its payment hash.
 * The passed payment hash *must* be exactly 32 bytes, if not, an error is
 * returned.
 */
- (void)lookupInvoiceWithRequest:(PaymentHash *)request handler:(void(^)(Invoice *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `lookupinvoice`
 * LookupInvoice attempts to look up an invoice according to its payment hash.
 * The passed payment hash *must* be exactly 32 bytes, if not, an error is
 * returned.
 */
- (GRPCProtoCall *)RPCToLookupInvoiceWithRequest:(PaymentHash *)request handler:(void(^)(Invoice *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SubscribeInvoices(InvoiceSubscription) returns (stream Invoice)

/**
 * *
 * SubscribeInvoices returns a uni-directional stream (sever -> client) for
 * notifying the client of newly added/settled invoices.
 */
- (void)subscribeInvoicesWithRequest:(InvoiceSubscription *)request eventHandler:(void(^)(BOOL done, Invoice *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * *
 * SubscribeInvoices returns a uni-directional stream (sever -> client) for
 * notifying the client of newly added/settled invoices.
 */
- (GRPCProtoCall *)RPCToSubscribeInvoicesWithRequest:(InvoiceSubscription *)request eventHandler:(void(^)(BOOL done, Invoice *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark DecodePayReq(PayReqString) returns (PayReq)

/**
 * * lncli: `decodepayreq`
 * DecodePayReq takes an encoded payment request string and attempts to decode
 * it, returning a full description of the conditions encoded within the
 * payment request.
 */
- (void)decodePayReqWithRequest:(PayReqString *)request handler:(void(^)(PayReq *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `decodepayreq`
 * DecodePayReq takes an encoded payment request string and attempts to decode
 * it, returning a full description of the conditions encoded within the
 * payment request.
 */
- (GRPCProtoCall *)RPCToDecodePayReqWithRequest:(PayReqString *)request handler:(void(^)(PayReq *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ListPayments(ListPaymentsRequest) returns (ListPaymentsResponse)

/**
 * * lncli: `listpayments`
 * ListPayments returns a list of all outgoing payments.
 */
- (void)listPaymentsWithRequest:(ListPaymentsRequest *)request handler:(void(^)(ListPaymentsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listpayments`
 * ListPayments returns a list of all outgoing payments.
 */
- (GRPCProtoCall *)RPCToListPaymentsWithRequest:(ListPaymentsRequest *)request handler:(void(^)(ListPaymentsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark DeleteAllPayments(DeleteAllPaymentsRequest) returns (DeleteAllPaymentsResponse)

/**
 * *
 * DeleteAllPayments deletes all outgoing payments from DB.
 */
- (void)deleteAllPaymentsWithRequest:(DeleteAllPaymentsRequest *)request handler:(void(^)(DeleteAllPaymentsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * *
 * DeleteAllPayments deletes all outgoing payments from DB.
 */
- (GRPCProtoCall *)RPCToDeleteAllPaymentsWithRequest:(DeleteAllPaymentsRequest *)request handler:(void(^)(DeleteAllPaymentsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark DescribeGraph(ChannelGraphRequest) returns (ChannelGraph)

/**
 * * lncli: `describegraph`
 * DescribeGraph returns a description of the latest graph state from the
 * point of view of the node. The graph information is partitioned into two
 * components: all the nodes/vertexes, and all the edges that connect the
 * vertexes themselves.  As this is a directed graph, the edges also contain
 * the node directional specific routing policy which includes: the time lock
 * delta, fee information, etc.
 */
- (void)describeGraphWithRequest:(ChannelGraphRequest *)request handler:(void(^)(ChannelGraph *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `describegraph`
 * DescribeGraph returns a description of the latest graph state from the
 * point of view of the node. The graph information is partitioned into two
 * components: all the nodes/vertexes, and all the edges that connect the
 * vertexes themselves.  As this is a directed graph, the edges also contain
 * the node directional specific routing policy which includes: the time lock
 * delta, fee information, etc.
 */
- (GRPCProtoCall *)RPCToDescribeGraphWithRequest:(ChannelGraphRequest *)request handler:(void(^)(ChannelGraph *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetChanInfo(ChanInfoRequest) returns (ChannelEdge)

/**
 * * lncli: `getchaninfo`
 * GetChanInfo returns the latest authenticated network announcement for the
 * given channel identified by its channel ID: an 8-byte integer which
 * uniquely identifies the location of transaction's funding output within the
 * blockchain.
 */
- (void)getChanInfoWithRequest:(ChanInfoRequest *)request handler:(void(^)(ChannelEdge *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `getchaninfo`
 * GetChanInfo returns the latest authenticated network announcement for the
 * given channel identified by its channel ID: an 8-byte integer which
 * uniquely identifies the location of transaction's funding output within the
 * blockchain.
 */
- (GRPCProtoCall *)RPCToGetChanInfoWithRequest:(ChanInfoRequest *)request handler:(void(^)(ChannelEdge *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetNodeInfo(NodeInfoRequest) returns (NodeInfo)

/**
 * * lncli: `getnodeinfo`
 * GetNodeInfo returns the latest advertised, aggregated, and authenticated
 * channel information for the specified node identified by its public key.
 */
- (void)getNodeInfoWithRequest:(NodeInfoRequest *)request handler:(void(^)(NodeInfo *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `getnodeinfo`
 * GetNodeInfo returns the latest advertised, aggregated, and authenticated
 * channel information for the specified node identified by its public key.
 */
- (GRPCProtoCall *)RPCToGetNodeInfoWithRequest:(NodeInfoRequest *)request handler:(void(^)(NodeInfo *_Nullable response, NSError *_Nullable error))handler;


#pragma mark QueryRoutes(QueryRoutesRequest) returns (QueryRoutesResponse)

/**
 * * lncli: `queryroutes`
 * QueryRoutes attempts to query the daemon's Channel Router for a possible
 * route to a target destination capable of carrying a specific amount of
 * satoshis. The retuned route contains the full details required to craft and
 * send an HTLC, also including the necessary information that should be
 * present within the Sphinx packet encapsulated within the HTLC.
 */
- (void)queryRoutesWithRequest:(QueryRoutesRequest *)request handler:(void(^)(QueryRoutesResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `queryroutes`
 * QueryRoutes attempts to query the daemon's Channel Router for a possible
 * route to a target destination capable of carrying a specific amount of
 * satoshis. The retuned route contains the full details required to craft and
 * send an HTLC, also including the necessary information that should be
 * present within the Sphinx packet encapsulated within the HTLC.
 */
- (GRPCProtoCall *)RPCToQueryRoutesWithRequest:(QueryRoutesRequest *)request handler:(void(^)(QueryRoutesResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetNetworkInfo(NetworkInfoRequest) returns (NetworkInfo)

/**
 * * lncli: `getnetworkinfo`
 * GetNetworkInfo returns some basic stats about the known channel graph from
 * the point of view of the node.
 */
- (void)getNetworkInfoWithRequest:(NetworkInfoRequest *)request handler:(void(^)(NetworkInfo *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `getnetworkinfo`
 * GetNetworkInfo returns some basic stats about the known channel graph from
 * the point of view of the node.
 */
- (GRPCProtoCall *)RPCToGetNetworkInfoWithRequest:(NetworkInfoRequest *)request handler:(void(^)(NetworkInfo *_Nullable response, NSError *_Nullable error))handler;


#pragma mark StopDaemon(StopRequest) returns (StopResponse)

/**
 * * lncli: `stop`
 * StopDaemon will send a shutdown request to the interrupt handler, triggering
 * a graceful shutdown of the daemon.
 */
- (void)stopDaemonWithRequest:(StopRequest *)request handler:(void(^)(StopResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `stop`
 * StopDaemon will send a shutdown request to the interrupt handler, triggering
 * a graceful shutdown of the daemon.
 */
- (GRPCProtoCall *)RPCToStopDaemonWithRequest:(StopRequest *)request handler:(void(^)(StopResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SubscribeChannelGraph(GraphTopologySubscription) returns (stream GraphTopologyUpdate)

/**
 * *
 * SubscribeChannelGraph launches a streaming RPC that allows the caller to
 * receive notifications upon any changes to the channel graph topology from
 * the point of view of the responding node. Events notified include: new
 * nodes coming online, nodes updating their authenticated attributes, new
 * channels being advertised, updates in the routing policy for a directional
 * channel edge, and when channels are closed on-chain.
 */
- (void)subscribeChannelGraphWithRequest:(GraphTopologySubscription *)request eventHandler:(void(^)(BOOL done, GraphTopologyUpdate *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * *
 * SubscribeChannelGraph launches a streaming RPC that allows the caller to
 * receive notifications upon any changes to the channel graph topology from
 * the point of view of the responding node. Events notified include: new
 * nodes coming online, nodes updating their authenticated attributes, new
 * channels being advertised, updates in the routing policy for a directional
 * channel edge, and when channels are closed on-chain.
 */
- (GRPCProtoCall *)RPCToSubscribeChannelGraphWithRequest:(GraphTopologySubscription *)request eventHandler:(void(^)(BOOL done, GraphTopologyUpdate *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark DebugLevel(DebugLevelRequest) returns (DebugLevelResponse)

/**
 * * lncli: `debuglevel`
 * DebugLevel allows a caller to programmatically set the logging verbosity of
 * lnd. The logging can be targeted according to a coarse daemon-wide logging
 * level, or in a granular fashion to specify the logging for a target
 * sub-system.
 */
- (void)debugLevelWithRequest:(DebugLevelRequest *)request handler:(void(^)(DebugLevelResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `debuglevel`
 * DebugLevel allows a caller to programmatically set the logging verbosity of
 * lnd. The logging can be targeted according to a coarse daemon-wide logging
 * level, or in a granular fashion to specify the logging for a target
 * sub-system.
 */
- (GRPCProtoCall *)RPCToDebugLevelWithRequest:(DebugLevelRequest *)request handler:(void(^)(DebugLevelResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark FeeReport(FeeReportRequest) returns (FeeReportResponse)

/**
 * * lncli: `feereport`
 * FeeReport allows the caller to obtain a report detailing the current fee
 * schedule enforced by the node globally for each channel.
 */
- (void)feeReportWithRequest:(FeeReportRequest *)request handler:(void(^)(FeeReportResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `feereport`
 * FeeReport allows the caller to obtain a report detailing the current fee
 * schedule enforced by the node globally for each channel.
 */
- (GRPCProtoCall *)RPCToFeeReportWithRequest:(FeeReportRequest *)request handler:(void(^)(FeeReportResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark UpdateChannelPolicy(PolicyUpdateRequest) returns (PolicyUpdateResponse)

/**
 * * lncli: `updatechanpolicy`
 * UpdateChannelPolicy allows the caller to update the fee schedule and
 * channel policies for all channels globally, or a particular channel.
 */
- (void)updateChannelPolicyWithRequest:(PolicyUpdateRequest *)request handler:(void(^)(PolicyUpdateResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `updatechanpolicy`
 * UpdateChannelPolicy allows the caller to update the fee schedule and
 * channel policies for all channels globally, or a particular channel.
 */
- (GRPCProtoCall *)RPCToUpdateChannelPolicyWithRequest:(PolicyUpdateRequest *)request handler:(void(^)(PolicyUpdateResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ForwardingHistory(ForwardingHistoryRequest) returns (ForwardingHistoryResponse)

/**
 * * lncli: `fwdinghistory`
 * ForwardingHistory allows the caller to query the htlcswitch for a record of
 * all HTLC's forwarded within the target time range, and integer offset
 * within that time range. If no time-range is specified, then the first chunk
 * of the past 24 hrs of forwarding history are returned.
 * 
 * A list of forwarding events are returned. The size of each forwarding event
 * is 40 bytes, and the max message size able to be returned in gRPC is 4 MiB.
 * As a result each message can only contain 50k entries.  Each response has
 * the index offset of the last entry. The index offset can be provided to the
 * request to allow the caller to skip a series of records.
 */
- (void)forwardingHistoryWithRequest:(ForwardingHistoryRequest *)request handler:(void(^)(ForwardingHistoryResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `fwdinghistory`
 * ForwardingHistory allows the caller to query the htlcswitch for a record of
 * all HTLC's forwarded within the target time range, and integer offset
 * within that time range. If no time-range is specified, then the first chunk
 * of the past 24 hrs of forwarding history are returned.
 * 
 * A list of forwarding events are returned. The size of each forwarding event
 * is 40 bytes, and the max message size able to be returned in gRPC is 4 MiB.
 * As a result each message can only contain 50k entries.  Each response has
 * the index offset of the last entry. The index offset can be provided to the
 * request to allow the caller to skip a series of records.
 */
- (GRPCProtoCall *)RPCToForwardingHistoryWithRequest:(ForwardingHistoryRequest *)request handler:(void(^)(ForwardingHistoryResponse *_Nullable response, NSError *_Nullable error))handler;


@end


#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface WalletUnlocker : GRPCProtoService<WalletUnlocker>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface Lightning : GRPCProtoService<Lightning>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
#endif

NS_ASSUME_NONNULL_END

