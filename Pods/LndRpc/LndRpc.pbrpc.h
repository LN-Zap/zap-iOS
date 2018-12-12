#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
#import "LndRpc.pbobjc.h"
#endif

#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import <ProtoRPC/ProtoService.h>
#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>
#endif

@class LNDAbandonChannelRequest;
@class LNDAbandonChannelResponse;
@class LNDAddInvoiceResponse;
@class LNDChanInfoRequest;
@class LNDChangePasswordRequest;
@class LNDChangePasswordResponse;
@class LNDChannelBalanceRequest;
@class LNDChannelBalanceResponse;
@class LNDChannelEdge;
@class LNDChannelGraph;
@class LNDChannelGraphRequest;
@class LNDChannelPoint;
@class LNDCloseChannelRequest;
@class LNDCloseStatusUpdate;
@class LNDClosedChannelsRequest;
@class LNDClosedChannelsResponse;
@class LNDConnectPeerRequest;
@class LNDConnectPeerResponse;
@class LNDDebugLevelRequest;
@class LNDDebugLevelResponse;
@class LNDDeleteAllPaymentsRequest;
@class LNDDeleteAllPaymentsResponse;
@class LNDDisconnectPeerRequest;
@class LNDDisconnectPeerResponse;
@class LNDFeeReportRequest;
@class LNDFeeReportResponse;
@class LNDForwardingHistoryRequest;
@class LNDForwardingHistoryResponse;
@class LNDGenSeedRequest;
@class LNDGenSeedResponse;
@class LNDGetInfoRequest;
@class LNDGetInfoResponse;
@class LNDGetTransactionsRequest;
@class LNDGraphTopologySubscription;
@class LNDGraphTopologyUpdate;
@class LNDInitWalletRequest;
@class LNDInitWalletResponse;
@class LNDInvoice;
@class LNDInvoiceSubscription;
@class LNDListChannelsRequest;
@class LNDListChannelsResponse;
@class LNDListInvoiceRequest;
@class LNDListInvoiceResponse;
@class LNDListPaymentsRequest;
@class LNDListPaymentsResponse;
@class LNDListPeersRequest;
@class LNDListPeersResponse;
@class LNDNetworkInfo;
@class LNDNetworkInfoRequest;
@class LNDNewAddressRequest;
@class LNDNewAddressResponse;
@class LNDNodeInfo;
@class LNDNodeInfoRequest;
@class LNDOpenChannelRequest;
@class LNDOpenStatusUpdate;
@class LNDPayReq;
@class LNDPayReqString;
@class LNDPaymentHash;
@class LNDPendingChannelsRequest;
@class LNDPendingChannelsResponse;
@class LNDPolicyUpdateRequest;
@class LNDPolicyUpdateResponse;
@class LNDQueryRoutesRequest;
@class LNDQueryRoutesResponse;
@class LNDSendCoinsRequest;
@class LNDSendCoinsResponse;
@class LNDSendManyRequest;
@class LNDSendManyResponse;
@class LNDSendRequest;
@class LNDSendResponse;
@class LNDSendToRouteRequest;
@class LNDSignMessageRequest;
@class LNDSignMessageResponse;
@class LNDStopRequest;
@class LNDStopResponse;
@class LNDTransaction;
@class LNDTransactionDetails;
@class LNDUnlockWalletRequest;
@class LNDUnlockWalletResponse;
@class LNDVerifyMessageRequest;
@class LNDVerifyMessageResponse;
@class LNDWalletBalanceRequest;
@class LNDWalletBalanceResponse;

#if !defined(GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO) || !GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO
//  #import "google/api/Annotations.pbobjc.h"
#endif

@class GRPCProtoCall;


NS_ASSUME_NONNULL_BEGIN

@protocol LNDWalletUnlocker <NSObject>

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
- (void)genSeedWithRequest:(LNDGenSeedRequest *)request handler:(void(^)(LNDGenSeedResponse *_Nullable response, NSError *_Nullable error))handler;

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
- (GRPCProtoCall *)RPCToGenSeedWithRequest:(LNDGenSeedRequest *)request handler:(void(^)(LNDGenSeedResponse *_Nullable response, NSError *_Nullable error))handler;


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
- (void)initWalletWithRequest:(LNDInitWalletRequest *)request handler:(void(^)(LNDInitWalletResponse *_Nullable response, NSError *_Nullable error))handler;

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
- (GRPCProtoCall *)RPCToInitWalletWithRequest:(LNDInitWalletRequest *)request handler:(void(^)(LNDInitWalletResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark UnlockWallet(UnlockWalletRequest) returns (UnlockWalletResponse)

/**
 * * lncli: `unlock`
 * UnlockWallet is used at startup of lnd to provide a password to unlock
 * the wallet database.
 */
- (void)unlockWalletWithRequest:(LNDUnlockWalletRequest *)request handler:(void(^)(LNDUnlockWalletResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `unlock`
 * UnlockWallet is used at startup of lnd to provide a password to unlock
 * the wallet database.
 */
- (GRPCProtoCall *)RPCToUnlockWalletWithRequest:(LNDUnlockWalletRequest *)request handler:(void(^)(LNDUnlockWalletResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ChangePassword(ChangePasswordRequest) returns (ChangePasswordResponse)

/**
 * * lncli: `changepassword`
 * ChangePassword changes the password of the encrypted wallet. This will
 * automatically unlock the wallet database if successful.
 */
- (void)changePasswordWithRequest:(LNDChangePasswordRequest *)request handler:(void(^)(LNDChangePasswordResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `changepassword`
 * ChangePassword changes the password of the encrypted wallet. This will
 * automatically unlock the wallet database if successful.
 */
- (GRPCProtoCall *)RPCToChangePasswordWithRequest:(LNDChangePasswordRequest *)request handler:(void(^)(LNDChangePasswordResponse *_Nullable response, NSError *_Nullable error))handler;


@end

@protocol LNDLightning <NSObject>

#pragma mark WalletBalance(WalletBalanceRequest) returns (WalletBalanceResponse)

/**
 * * lncli: `walletbalance`
 * WalletBalance returns total unspent outputs(confirmed and unconfirmed), all
 * confirmed unspent outputs and all unconfirmed unspent outputs under control
 * of the wallet. 
 */
- (void)walletBalanceWithRequest:(LNDWalletBalanceRequest *)request handler:(void(^)(LNDWalletBalanceResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `walletbalance`
 * WalletBalance returns total unspent outputs(confirmed and unconfirmed), all
 * confirmed unspent outputs and all unconfirmed unspent outputs under control
 * of the wallet. 
 */
- (GRPCProtoCall *)RPCToWalletBalanceWithRequest:(LNDWalletBalanceRequest *)request handler:(void(^)(LNDWalletBalanceResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ChannelBalance(ChannelBalanceRequest) returns (ChannelBalanceResponse)

/**
 * * lncli: `channelbalance`
 * ChannelBalance returns the total funds available across all open channels
 * in satoshis.
 */
- (void)channelBalanceWithRequest:(LNDChannelBalanceRequest *)request handler:(void(^)(LNDChannelBalanceResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `channelbalance`
 * ChannelBalance returns the total funds available across all open channels
 * in satoshis.
 */
- (GRPCProtoCall *)RPCToChannelBalanceWithRequest:(LNDChannelBalanceRequest *)request handler:(void(^)(LNDChannelBalanceResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetTransactions(GetTransactionsRequest) returns (TransactionDetails)

/**
 * * lncli: `listchaintxns`
 * GetTransactions returns a list describing all the known transactions
 * relevant to the wallet.
 */
- (void)getTransactionsWithRequest:(LNDGetTransactionsRequest *)request handler:(void(^)(LNDTransactionDetails *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listchaintxns`
 * GetTransactions returns a list describing all the known transactions
 * relevant to the wallet.
 */
- (GRPCProtoCall *)RPCToGetTransactionsWithRequest:(LNDGetTransactionsRequest *)request handler:(void(^)(LNDTransactionDetails *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SendCoins(SendCoinsRequest) returns (SendCoinsResponse)

/**
 * * lncli: `sendcoins`
 * SendCoins executes a request to send coins to a particular address. Unlike
 * SendMany, this RPC call only allows creating a single output at a time. If
 * neither target_conf, or sat_per_byte are set, then the internal wallet will
 * consult its fee model to determine a fee for the default confirmation
 * target.
 */
- (void)sendCoinsWithRequest:(LNDSendCoinsRequest *)request handler:(void(^)(LNDSendCoinsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `sendcoins`
 * SendCoins executes a request to send coins to a particular address. Unlike
 * SendMany, this RPC call only allows creating a single output at a time. If
 * neither target_conf, or sat_per_byte are set, then the internal wallet will
 * consult its fee model to determine a fee for the default confirmation
 * target.
 */
- (GRPCProtoCall *)RPCToSendCoinsWithRequest:(LNDSendCoinsRequest *)request handler:(void(^)(LNDSendCoinsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SubscribeTransactions(GetTransactionsRequest) returns (stream Transaction)

/**
 * *
 * SubscribeTransactions creates a uni-directional stream from the server to
 * the client in which any newly discovered transactions relevant to the
 * wallet are sent over.
 */
- (void)subscribeTransactionsWithRequest:(LNDGetTransactionsRequest *)request eventHandler:(void(^)(BOOL done, LNDTransaction *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * *
 * SubscribeTransactions creates a uni-directional stream from the server to
 * the client in which any newly discovered transactions relevant to the
 * wallet are sent over.
 */
- (GRPCProtoCall *)RPCToSubscribeTransactionsWithRequest:(LNDGetTransactionsRequest *)request eventHandler:(void(^)(BOOL done, LNDTransaction *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark SendMany(SendManyRequest) returns (SendManyResponse)

/**
 * * lncli: `sendmany`
 * SendMany handles a request for a transaction that creates multiple specified
 * outputs in parallel. If neither target_conf, or sat_per_byte are set, then
 * the internal wallet will consult its fee model to determine a fee for the
 * default confirmation target.
 */
- (void)sendManyWithRequest:(LNDSendManyRequest *)request handler:(void(^)(LNDSendManyResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `sendmany`
 * SendMany handles a request for a transaction that creates multiple specified
 * outputs in parallel. If neither target_conf, or sat_per_byte are set, then
 * the internal wallet will consult its fee model to determine a fee for the
 * default confirmation target.
 */
- (GRPCProtoCall *)RPCToSendManyWithRequest:(LNDSendManyRequest *)request handler:(void(^)(LNDSendManyResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark NewAddress(NewAddressRequest) returns (NewAddressResponse)

/**
 * * lncli: `newaddress`
 * NewAddress creates a new address under control of the local wallet.
 */
- (void)newAddressWithRequest:(LNDNewAddressRequest *)request handler:(void(^)(LNDNewAddressResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `newaddress`
 * NewAddress creates a new address under control of the local wallet.
 */
- (GRPCProtoCall *)RPCToNewAddressWithRequest:(LNDNewAddressRequest *)request handler:(void(^)(LNDNewAddressResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SignMessage(SignMessageRequest) returns (SignMessageResponse)

/**
 * * lncli: `signmessage`
 * SignMessage signs a message with this node's private key. The returned
 * signature string is `zbase32` encoded and pubkey recoverable, meaning that
 * only the message digest and signature are needed for verification.
 */
- (void)signMessageWithRequest:(LNDSignMessageRequest *)request handler:(void(^)(LNDSignMessageResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `signmessage`
 * SignMessage signs a message with this node's private key. The returned
 * signature string is `zbase32` encoded and pubkey recoverable, meaning that
 * only the message digest and signature are needed for verification.
 */
- (GRPCProtoCall *)RPCToSignMessageWithRequest:(LNDSignMessageRequest *)request handler:(void(^)(LNDSignMessageResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark VerifyMessage(VerifyMessageRequest) returns (VerifyMessageResponse)

/**
 * * lncli: `verifymessage`
 * VerifyMessage verifies a signature over a msg. The signature must be
 * zbase32 encoded and signed by an active node in the resident node's
 * channel database. In addition to returning the validity of the signature,
 * VerifyMessage also returns the recovered pubkey from the signature.
 */
- (void)verifyMessageWithRequest:(LNDVerifyMessageRequest *)request handler:(void(^)(LNDVerifyMessageResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `verifymessage`
 * VerifyMessage verifies a signature over a msg. The signature must be
 * zbase32 encoded and signed by an active node in the resident node's
 * channel database. In addition to returning the validity of the signature,
 * VerifyMessage also returns the recovered pubkey from the signature.
 */
- (GRPCProtoCall *)RPCToVerifyMessageWithRequest:(LNDVerifyMessageRequest *)request handler:(void(^)(LNDVerifyMessageResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ConnectPeer(ConnectPeerRequest) returns (ConnectPeerResponse)

/**
 * * lncli: `connect`
 * ConnectPeer attempts to establish a connection to a remote peer. This is at
 * the networking level, and is used for communication between nodes. This is
 * distinct from establishing a channel with a peer.
 */
- (void)connectPeerWithRequest:(LNDConnectPeerRequest *)request handler:(void(^)(LNDConnectPeerResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `connect`
 * ConnectPeer attempts to establish a connection to a remote peer. This is at
 * the networking level, and is used for communication between nodes. This is
 * distinct from establishing a channel with a peer.
 */
- (GRPCProtoCall *)RPCToConnectPeerWithRequest:(LNDConnectPeerRequest *)request handler:(void(^)(LNDConnectPeerResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark DisconnectPeer(DisconnectPeerRequest) returns (DisconnectPeerResponse)

/**
 * * lncli: `disconnect`
 * DisconnectPeer attempts to disconnect one peer from another identified by a
 * given pubKey. In the case that we currently have a pending or active channel
 * with the target peer, then this action will be not be allowed.
 */
- (void)disconnectPeerWithRequest:(LNDDisconnectPeerRequest *)request handler:(void(^)(LNDDisconnectPeerResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `disconnect`
 * DisconnectPeer attempts to disconnect one peer from another identified by a
 * given pubKey. In the case that we currently have a pending or active channel
 * with the target peer, then this action will be not be allowed.
 */
- (GRPCProtoCall *)RPCToDisconnectPeerWithRequest:(LNDDisconnectPeerRequest *)request handler:(void(^)(LNDDisconnectPeerResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ListPeers(ListPeersRequest) returns (ListPeersResponse)

/**
 * * lncli: `listpeers`
 * ListPeers returns a verbose listing of all currently active peers.
 */
- (void)listPeersWithRequest:(LNDListPeersRequest *)request handler:(void(^)(LNDListPeersResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listpeers`
 * ListPeers returns a verbose listing of all currently active peers.
 */
- (GRPCProtoCall *)RPCToListPeersWithRequest:(LNDListPeersRequest *)request handler:(void(^)(LNDListPeersResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetInfo(GetInfoRequest) returns (GetInfoResponse)

/**
 * * lncli: `getinfo`
 * GetInfo returns general information concerning the lightning node including
 * it's identity pubkey, alias, the chains it is connected to, and information
 * concerning the number of open+pending channels.
 */
- (void)getInfoWithRequest:(LNDGetInfoRequest *)request handler:(void(^)(LNDGetInfoResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `getinfo`
 * GetInfo returns general information concerning the lightning node including
 * it's identity pubkey, alias, the chains it is connected to, and information
 * concerning the number of open+pending channels.
 */
- (GRPCProtoCall *)RPCToGetInfoWithRequest:(LNDGetInfoRequest *)request handler:(void(^)(LNDGetInfoResponse *_Nullable response, NSError *_Nullable error))handler;


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
- (void)pendingChannelsWithRequest:(LNDPendingChannelsRequest *)request handler:(void(^)(LNDPendingChannelsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * TODO(roasbeef): merge with below with bool?
 * 
 * * lncli: `pendingchannels`
 * PendingChannels returns a list of all the channels that are currently
 * considered "pending". A channel is pending if it has finished the funding
 * workflow and is waiting for confirmations for the funding txn, or is in the
 * process of closure, either initiated cooperatively or non-cooperatively.
 */
- (GRPCProtoCall *)RPCToPendingChannelsWithRequest:(LNDPendingChannelsRequest *)request handler:(void(^)(LNDPendingChannelsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ListChannels(ListChannelsRequest) returns (ListChannelsResponse)

/**
 * * lncli: `listchannels`
 * ListChannels returns a description of all the open channels that this node
 * is a participant in.
 */
- (void)listChannelsWithRequest:(LNDListChannelsRequest *)request handler:(void(^)(LNDListChannelsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listchannels`
 * ListChannels returns a description of all the open channels that this node
 * is a participant in.
 */
- (GRPCProtoCall *)RPCToListChannelsWithRequest:(LNDListChannelsRequest *)request handler:(void(^)(LNDListChannelsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ClosedChannels(ClosedChannelsRequest) returns (ClosedChannelsResponse)

/**
 * * lncli: `closedchannels`
 * ClosedChannels returns a description of all the closed channels that 
 * this node was a participant in.
 */
- (void)closedChannelsWithRequest:(LNDClosedChannelsRequest *)request handler:(void(^)(LNDClosedChannelsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `closedchannels`
 * ClosedChannels returns a description of all the closed channels that 
 * this node was a participant in.
 */
- (GRPCProtoCall *)RPCToClosedChannelsWithRequest:(LNDClosedChannelsRequest *)request handler:(void(^)(LNDClosedChannelsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark OpenChannelSync(OpenChannelRequest) returns (ChannelPoint)

/**
 * *
 * OpenChannelSync is a synchronous version of the OpenChannel RPC call. This
 * call is meant to be consumed by clients to the REST proxy. As with all
 * other sync calls, all byte slices are intended to be populated as hex
 * encoded strings.
 */
- (void)openChannelSyncWithRequest:(LNDOpenChannelRequest *)request handler:(void(^)(LNDChannelPoint *_Nullable response, NSError *_Nullable error))handler;

/**
 * *
 * OpenChannelSync is a synchronous version of the OpenChannel RPC call. This
 * call is meant to be consumed by clients to the REST proxy. As with all
 * other sync calls, all byte slices are intended to be populated as hex
 * encoded strings.
 */
- (GRPCProtoCall *)RPCToOpenChannelSyncWithRequest:(LNDOpenChannelRequest *)request handler:(void(^)(LNDChannelPoint *_Nullable response, NSError *_Nullable error))handler;


#pragma mark OpenChannel(OpenChannelRequest) returns (stream OpenStatusUpdate)

/**
 * * lncli: `openchannel`
 * OpenChannel attempts to open a singly funded channel specified in the
 * request to a remote peer. Users are able to specify a target number of
 * blocks that the funding transaction should be confirmed in, or a manual fee
 * rate to us for the funding transaction. If neither are specified, then a
 * lax block confirmation target is used.
 */
- (void)openChannelWithRequest:(LNDOpenChannelRequest *)request eventHandler:(void(^)(BOOL done, LNDOpenStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * * lncli: `openchannel`
 * OpenChannel attempts to open a singly funded channel specified in the
 * request to a remote peer. Users are able to specify a target number of
 * blocks that the funding transaction should be confirmed in, or a manual fee
 * rate to us for the funding transaction. If neither are specified, then a
 * lax block confirmation target is used.
 */
- (GRPCProtoCall *)RPCToOpenChannelWithRequest:(LNDOpenChannelRequest *)request eventHandler:(void(^)(BOOL done, LNDOpenStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler;


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
- (void)closeChannelWithRequest:(LNDCloseChannelRequest *)request eventHandler:(void(^)(BOOL done, LNDCloseStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler;

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
- (GRPCProtoCall *)RPCToCloseChannelWithRequest:(LNDCloseChannelRequest *)request eventHandler:(void(^)(BOOL done, LNDCloseStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark AbandonChannel(AbandonChannelRequest) returns (AbandonChannelResponse)

/**
 * * lncli: `abandonchannel`
 * AbandonChannel removes all channel state from the database except for a
 * close summary. This method can be used to get rid of permanently unusable
 * channels due to bugs fixed in newer versions of lnd. Only available
 * when in debug builds of lnd.
 */
- (void)abandonChannelWithRequest:(LNDAbandonChannelRequest *)request handler:(void(^)(LNDAbandonChannelResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `abandonchannel`
 * AbandonChannel removes all channel state from the database except for a
 * close summary. This method can be used to get rid of permanently unusable
 * channels due to bugs fixed in newer versions of lnd. Only available
 * when in debug builds of lnd.
 */
- (GRPCProtoCall *)RPCToAbandonChannelWithRequest:(LNDAbandonChannelRequest *)request handler:(void(^)(LNDAbandonChannelResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SendPayment(stream SendRequest) returns (stream SendResponse)

/**
 * * lncli: `sendpayment`
 * SendPayment dispatches a bi-directional streaming RPC for sending payments
 * through the Lightning Network. A single RPC invocation creates a persistent
 * bi-directional stream allowing clients to rapidly send payments through the
 * Lightning Network with a single persistent connection.
 */
- (void)sendPaymentWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, LNDSendResponse *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * * lncli: `sendpayment`
 * SendPayment dispatches a bi-directional streaming RPC for sending payments
 * through the Lightning Network. A single RPC invocation creates a persistent
 * bi-directional stream allowing clients to rapidly send payments through the
 * Lightning Network with a single persistent connection.
 */
- (GRPCProtoCall *)RPCToSendPaymentWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, LNDSendResponse *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark SendPaymentSync(SendRequest) returns (SendResponse)

/**
 * *
 * SendPaymentSync is the synchronous non-streaming version of SendPayment.
 * This RPC is intended to be consumed by clients of the REST proxy.
 * Additionally, this RPC expects the destination's public key and the payment
 * hash (if any) to be encoded as hex strings.
 */
- (void)sendPaymentSyncWithRequest:(LNDSendRequest *)request handler:(void(^)(LNDSendResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * *
 * SendPaymentSync is the synchronous non-streaming version of SendPayment.
 * This RPC is intended to be consumed by clients of the REST proxy.
 * Additionally, this RPC expects the destination's public key and the payment
 * hash (if any) to be encoded as hex strings.
 */
- (GRPCProtoCall *)RPCToSendPaymentSyncWithRequest:(LNDSendRequest *)request handler:(void(^)(LNDSendResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SendToRoute(stream SendToRouteRequest) returns (stream SendResponse)

/**
 * * lncli: `sendtoroute`
 * SendToRoute is a bi-directional streaming RPC for sending payment through
 * the Lightning Network. This method differs from SendPayment in that it
 * allows users to specify a full route manually. This can be used for things
 * like rebalancing, and atomic swaps.
 */
- (void)sendToRouteWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, LNDSendResponse *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * * lncli: `sendtoroute`
 * SendToRoute is a bi-directional streaming RPC for sending payment through
 * the Lightning Network. This method differs from SendPayment in that it
 * allows users to specify a full route manually. This can be used for things
 * like rebalancing, and atomic swaps.
 */
- (GRPCProtoCall *)RPCToSendToRouteWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, LNDSendResponse *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark SendToRouteSync(SendToRouteRequest) returns (SendResponse)

/**
 * *
 * SendToRouteSync is a synchronous version of SendToRoute. It Will block
 * until the payment either fails or succeeds.
 */
- (void)sendToRouteSyncWithRequest:(LNDSendToRouteRequest *)request handler:(void(^)(LNDSendResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * *
 * SendToRouteSync is a synchronous version of SendToRoute. It Will block
 * until the payment either fails or succeeds.
 */
- (GRPCProtoCall *)RPCToSendToRouteSyncWithRequest:(LNDSendToRouteRequest *)request handler:(void(^)(LNDSendResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark AddInvoice(Invoice) returns (AddInvoiceResponse)

/**
 * * lncli: `addinvoice`
 * AddInvoice attempts to add a new invoice to the invoice database. Any
 * duplicated invoices are rejected, therefore all invoices *must* have a
 * unique payment preimage.
 */
- (void)addInvoiceWithRequest:(LNDInvoice *)request handler:(void(^)(LNDAddInvoiceResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `addinvoice`
 * AddInvoice attempts to add a new invoice to the invoice database. Any
 * duplicated invoices are rejected, therefore all invoices *must* have a
 * unique payment preimage.
 */
- (GRPCProtoCall *)RPCToAddInvoiceWithRequest:(LNDInvoice *)request handler:(void(^)(LNDAddInvoiceResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ListInvoices(ListInvoiceRequest) returns (ListInvoiceResponse)

/**
 * * lncli: `listinvoices`
 * ListInvoices returns a list of all the invoices currently stored within the
 * database. Any active debug invoices are ignored. It has full support for
 * paginated responses, allowing users to query for specific invoices through
 * their add_index. This can be done by using either the first_index_offset or
 * last_index_offset fields included in the response as the index_offset of the
 * next request. The reversed flag is set by default in order to paginate
 * backwards. If you wish to paginate forwards, you must explicitly set the
 * flag to false. If none of the parameters are specified, then the last 100
 * invoices will be returned.
 */
- (void)listInvoicesWithRequest:(LNDListInvoiceRequest *)request handler:(void(^)(LNDListInvoiceResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listinvoices`
 * ListInvoices returns a list of all the invoices currently stored within the
 * database. Any active debug invoices are ignored. It has full support for
 * paginated responses, allowing users to query for specific invoices through
 * their add_index. This can be done by using either the first_index_offset or
 * last_index_offset fields included in the response as the index_offset of the
 * next request. The reversed flag is set by default in order to paginate
 * backwards. If you wish to paginate forwards, you must explicitly set the
 * flag to false. If none of the parameters are specified, then the last 100
 * invoices will be returned.
 */
- (GRPCProtoCall *)RPCToListInvoicesWithRequest:(LNDListInvoiceRequest *)request handler:(void(^)(LNDListInvoiceResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark LookupInvoice(PaymentHash) returns (Invoice)

/**
 * * lncli: `lookupinvoice`
 * LookupInvoice attempts to look up an invoice according to its payment hash.
 * The passed payment hash *must* be exactly 32 bytes, if not, an error is
 * returned.
 */
- (void)lookupInvoiceWithRequest:(LNDPaymentHash *)request handler:(void(^)(LNDInvoice *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `lookupinvoice`
 * LookupInvoice attempts to look up an invoice according to its payment hash.
 * The passed payment hash *must* be exactly 32 bytes, if not, an error is
 * returned.
 */
- (GRPCProtoCall *)RPCToLookupInvoiceWithRequest:(LNDPaymentHash *)request handler:(void(^)(LNDInvoice *_Nullable response, NSError *_Nullable error))handler;


#pragma mark SubscribeInvoices(InvoiceSubscription) returns (stream Invoice)

/**
 * *
 * SubscribeInvoices returns a uni-directional stream (server -> client) for
 * notifying the client of newly added/settled invoices. The caller can
 * optionally specify the add_index and/or the settle_index. If the add_index
 * is specified, then we'll first start by sending add invoice events for all
 * invoices with an add_index greater than the specified value.  If the
 * settle_index is specified, the next, we'll send out all settle events for
 * invoices with a settle_index greater than the specified value.  One or both
 * of these fields can be set. If no fields are set, then we'll only send out
 * the latest add/settle events.
 */
- (void)subscribeInvoicesWithRequest:(LNDInvoiceSubscription *)request eventHandler:(void(^)(BOOL done, LNDInvoice *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * *
 * SubscribeInvoices returns a uni-directional stream (server -> client) for
 * notifying the client of newly added/settled invoices. The caller can
 * optionally specify the add_index and/or the settle_index. If the add_index
 * is specified, then we'll first start by sending add invoice events for all
 * invoices with an add_index greater than the specified value.  If the
 * settle_index is specified, the next, we'll send out all settle events for
 * invoices with a settle_index greater than the specified value.  One or both
 * of these fields can be set. If no fields are set, then we'll only send out
 * the latest add/settle events.
 */
- (GRPCProtoCall *)RPCToSubscribeInvoicesWithRequest:(LNDInvoiceSubscription *)request eventHandler:(void(^)(BOOL done, LNDInvoice *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark DecodePayReq(PayReqString) returns (PayReq)

/**
 * * lncli: `decodepayreq`
 * DecodePayReq takes an encoded payment request string and attempts to decode
 * it, returning a full description of the conditions encoded within the
 * payment request.
 */
- (void)decodePayReqWithRequest:(LNDPayReqString *)request handler:(void(^)(LNDPayReq *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `decodepayreq`
 * DecodePayReq takes an encoded payment request string and attempts to decode
 * it, returning a full description of the conditions encoded within the
 * payment request.
 */
- (GRPCProtoCall *)RPCToDecodePayReqWithRequest:(LNDPayReqString *)request handler:(void(^)(LNDPayReq *_Nullable response, NSError *_Nullable error))handler;


#pragma mark ListPayments(ListPaymentsRequest) returns (ListPaymentsResponse)

/**
 * * lncli: `listpayments`
 * ListPayments returns a list of all outgoing payments.
 */
- (void)listPaymentsWithRequest:(LNDListPaymentsRequest *)request handler:(void(^)(LNDListPaymentsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `listpayments`
 * ListPayments returns a list of all outgoing payments.
 */
- (GRPCProtoCall *)RPCToListPaymentsWithRequest:(LNDListPaymentsRequest *)request handler:(void(^)(LNDListPaymentsResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark DeleteAllPayments(DeleteAllPaymentsRequest) returns (DeleteAllPaymentsResponse)

/**
 * *
 * DeleteAllPayments deletes all outgoing payments from DB.
 */
- (void)deleteAllPaymentsWithRequest:(LNDDeleteAllPaymentsRequest *)request handler:(void(^)(LNDDeleteAllPaymentsResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * *
 * DeleteAllPayments deletes all outgoing payments from DB.
 */
- (GRPCProtoCall *)RPCToDeleteAllPaymentsWithRequest:(LNDDeleteAllPaymentsRequest *)request handler:(void(^)(LNDDeleteAllPaymentsResponse *_Nullable response, NSError *_Nullable error))handler;


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
- (void)describeGraphWithRequest:(LNDChannelGraphRequest *)request handler:(void(^)(LNDChannelGraph *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `describegraph`
 * DescribeGraph returns a description of the latest graph state from the
 * point of view of the node. The graph information is partitioned into two
 * components: all the nodes/vertexes, and all the edges that connect the
 * vertexes themselves.  As this is a directed graph, the edges also contain
 * the node directional specific routing policy which includes: the time lock
 * delta, fee information, etc.
 */
- (GRPCProtoCall *)RPCToDescribeGraphWithRequest:(LNDChannelGraphRequest *)request handler:(void(^)(LNDChannelGraph *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetChanInfo(ChanInfoRequest) returns (ChannelEdge)

/**
 * * lncli: `getchaninfo`
 * GetChanInfo returns the latest authenticated network announcement for the
 * given channel identified by its channel ID: an 8-byte integer which
 * uniquely identifies the location of transaction's funding output within the
 * blockchain.
 */
- (void)getChanInfoWithRequest:(LNDChanInfoRequest *)request handler:(void(^)(LNDChannelEdge *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `getchaninfo`
 * GetChanInfo returns the latest authenticated network announcement for the
 * given channel identified by its channel ID: an 8-byte integer which
 * uniquely identifies the location of transaction's funding output within the
 * blockchain.
 */
- (GRPCProtoCall *)RPCToGetChanInfoWithRequest:(LNDChanInfoRequest *)request handler:(void(^)(LNDChannelEdge *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetNodeInfo(NodeInfoRequest) returns (NodeInfo)

/**
 * * lncli: `getnodeinfo`
 * GetNodeInfo returns the latest advertised, aggregated, and authenticated
 * channel information for the specified node identified by its public key.
 */
- (void)getNodeInfoWithRequest:(LNDNodeInfoRequest *)request handler:(void(^)(LNDNodeInfo *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `getnodeinfo`
 * GetNodeInfo returns the latest advertised, aggregated, and authenticated
 * channel information for the specified node identified by its public key.
 */
- (GRPCProtoCall *)RPCToGetNodeInfoWithRequest:(LNDNodeInfoRequest *)request handler:(void(^)(LNDNodeInfo *_Nullable response, NSError *_Nullable error))handler;


#pragma mark QueryRoutes(QueryRoutesRequest) returns (QueryRoutesResponse)

/**
 * * lncli: `queryroutes`
 * QueryRoutes attempts to query the daemon's Channel Router for a possible
 * route to a target destination capable of carrying a specific amount of
 * satoshis. The retuned route contains the full details required to craft and
 * send an HTLC, also including the necessary information that should be
 * present within the Sphinx packet encapsulated within the HTLC.
 */
- (void)queryRoutesWithRequest:(LNDQueryRoutesRequest *)request handler:(void(^)(LNDQueryRoutesResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `queryroutes`
 * QueryRoutes attempts to query the daemon's Channel Router for a possible
 * route to a target destination capable of carrying a specific amount of
 * satoshis. The retuned route contains the full details required to craft and
 * send an HTLC, also including the necessary information that should be
 * present within the Sphinx packet encapsulated within the HTLC.
 */
- (GRPCProtoCall *)RPCToQueryRoutesWithRequest:(LNDQueryRoutesRequest *)request handler:(void(^)(LNDQueryRoutesResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark GetNetworkInfo(NetworkInfoRequest) returns (NetworkInfo)

/**
 * * lncli: `getnetworkinfo`
 * GetNetworkInfo returns some basic stats about the known channel graph from
 * the point of view of the node.
 */
- (void)getNetworkInfoWithRequest:(LNDNetworkInfoRequest *)request handler:(void(^)(LNDNetworkInfo *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `getnetworkinfo`
 * GetNetworkInfo returns some basic stats about the known channel graph from
 * the point of view of the node.
 */
- (GRPCProtoCall *)RPCToGetNetworkInfoWithRequest:(LNDNetworkInfoRequest *)request handler:(void(^)(LNDNetworkInfo *_Nullable response, NSError *_Nullable error))handler;


#pragma mark StopDaemon(StopRequest) returns (StopResponse)

/**
 * * lncli: `stop`
 * StopDaemon will send a shutdown request to the interrupt handler, triggering
 * a graceful shutdown of the daemon.
 */
- (void)stopDaemonWithRequest:(LNDStopRequest *)request handler:(void(^)(LNDStopResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `stop`
 * StopDaemon will send a shutdown request to the interrupt handler, triggering
 * a graceful shutdown of the daemon.
 */
- (GRPCProtoCall *)RPCToStopDaemonWithRequest:(LNDStopRequest *)request handler:(void(^)(LNDStopResponse *_Nullable response, NSError *_Nullable error))handler;


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
- (void)subscribeChannelGraphWithRequest:(LNDGraphTopologySubscription *)request eventHandler:(void(^)(BOOL done, LNDGraphTopologyUpdate *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * *
 * SubscribeChannelGraph launches a streaming RPC that allows the caller to
 * receive notifications upon any changes to the channel graph topology from
 * the point of view of the responding node. Events notified include: new
 * nodes coming online, nodes updating their authenticated attributes, new
 * channels being advertised, updates in the routing policy for a directional
 * channel edge, and when channels are closed on-chain.
 */
- (GRPCProtoCall *)RPCToSubscribeChannelGraphWithRequest:(LNDGraphTopologySubscription *)request eventHandler:(void(^)(BOOL done, LNDGraphTopologyUpdate *_Nullable response, NSError *_Nullable error))eventHandler;


#pragma mark DebugLevel(DebugLevelRequest) returns (DebugLevelResponse)

/**
 * * lncli: `debuglevel`
 * DebugLevel allows a caller to programmatically set the logging verbosity of
 * lnd. The logging can be targeted according to a coarse daemon-wide logging
 * level, or in a granular fashion to specify the logging for a target
 * sub-system.
 */
- (void)debugLevelWithRequest:(LNDDebugLevelRequest *)request handler:(void(^)(LNDDebugLevelResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `debuglevel`
 * DebugLevel allows a caller to programmatically set the logging verbosity of
 * lnd. The logging can be targeted according to a coarse daemon-wide logging
 * level, or in a granular fashion to specify the logging for a target
 * sub-system.
 */
- (GRPCProtoCall *)RPCToDebugLevelWithRequest:(LNDDebugLevelRequest *)request handler:(void(^)(LNDDebugLevelResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark FeeReport(FeeReportRequest) returns (FeeReportResponse)

/**
 * * lncli: `feereport`
 * FeeReport allows the caller to obtain a report detailing the current fee
 * schedule enforced by the node globally for each channel.
 */
- (void)feeReportWithRequest:(LNDFeeReportRequest *)request handler:(void(^)(LNDFeeReportResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `feereport`
 * FeeReport allows the caller to obtain a report detailing the current fee
 * schedule enforced by the node globally for each channel.
 */
- (GRPCProtoCall *)RPCToFeeReportWithRequest:(LNDFeeReportRequest *)request handler:(void(^)(LNDFeeReportResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark UpdateChannelPolicy(PolicyUpdateRequest) returns (PolicyUpdateResponse)

/**
 * * lncli: `updatechanpolicy`
 * UpdateChannelPolicy allows the caller to update the fee schedule and
 * channel policies for all channels globally, or a particular channel.
 */
- (void)updateChannelPolicyWithRequest:(LNDPolicyUpdateRequest *)request handler:(void(^)(LNDPolicyUpdateResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * * lncli: `updatechanpolicy`
 * UpdateChannelPolicy allows the caller to update the fee schedule and
 * channel policies for all channels globally, or a particular channel.
 */
- (GRPCProtoCall *)RPCToUpdateChannelPolicyWithRequest:(LNDPolicyUpdateRequest *)request handler:(void(^)(LNDPolicyUpdateResponse *_Nullable response, NSError *_Nullable error))handler;


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
- (void)forwardingHistoryWithRequest:(LNDForwardingHistoryRequest *)request handler:(void(^)(LNDForwardingHistoryResponse *_Nullable response, NSError *_Nullable error))handler;

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
- (GRPCProtoCall *)RPCToForwardingHistoryWithRequest:(LNDForwardingHistoryRequest *)request handler:(void(^)(LNDForwardingHistoryResponse *_Nullable response, NSError *_Nullable error))handler;


@end


#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface LNDWalletUnlocker : GRPCProtoService<LNDWalletUnlocker>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface LNDLightning : GRPCProtoService<LNDLightning>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end
#endif

NS_ASSUME_NONNULL_END

