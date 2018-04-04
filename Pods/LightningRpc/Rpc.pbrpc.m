#import "Rpc.pbrpc.h"
#import "Rpc.pbobjc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>
//#import "google/api/Annotations.pbobjc.h"

@implementation WalletUnlocker

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  return (self = [super initWithHost:host packageName:@"lnrpc" serviceName:@"WalletUnlocker"]);
}

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}


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
- (void)genSeedWithRequest:(GenSeedRequest *)request handler:(void(^)(GenSeedResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGenSeedWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
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
- (GRPCProtoCall *)RPCToGenSeedWithRequest:(GenSeedRequest *)request handler:(void(^)(GenSeedResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GenSeed"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GenSeedResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
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
- (void)initWalletWithRequest:(InitWalletRequest *)request handler:(void(^)(InitWalletResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToInitWalletWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
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
- (GRPCProtoCall *)RPCToInitWalletWithRequest:(InitWalletRequest *)request handler:(void(^)(InitWalletResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"InitWallet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[InitWalletResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UnlockWallet(UnlockWalletRequest) returns (UnlockWalletResponse)

/**
 * * lncli: `unlock`
 * UnlockWallet is used at startup of lnd to provide a password to unlock
 * the wallet database.
 */
- (void)unlockWalletWithRequest:(UnlockWalletRequest *)request handler:(void(^)(UnlockWalletResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToUnlockWalletWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `unlock`
 * UnlockWallet is used at startup of lnd to provide a password to unlock
 * the wallet database.
 */
- (GRPCProtoCall *)RPCToUnlockWalletWithRequest:(UnlockWalletRequest *)request handler:(void(^)(UnlockWalletResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"UnlockWallet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[UnlockWalletResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
@implementation Lightning

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  return (self = [super initWithHost:host packageName:@"lnrpc" serviceName:@"Lightning"]);
}

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}


#pragma mark WalletBalance(WalletBalanceRequest) returns (WalletBalanceResponse)

/**
 * * lncli: `walletbalance`
 * WalletBalance returns total unspent outputs(confirmed and unconfirmed), all
 * confirmed unspent outputs and all unconfirmed unspent outputs under control
 * of the wallet. 
 */
- (void)walletBalanceWithRequest:(WalletBalanceRequest *)request handler:(void(^)(WalletBalanceResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToWalletBalanceWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `walletbalance`
 * WalletBalance returns total unspent outputs(confirmed and unconfirmed), all
 * confirmed unspent outputs and all unconfirmed unspent outputs under control
 * of the wallet. 
 */
- (GRPCProtoCall *)RPCToWalletBalanceWithRequest:(WalletBalanceRequest *)request handler:(void(^)(WalletBalanceResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"WalletBalance"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[WalletBalanceResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ChannelBalance(ChannelBalanceRequest) returns (ChannelBalanceResponse)

/**
 * * lncli: `channelbalance`
 * ChannelBalance returns the total funds available across all open channels
 * in satoshis.
 */
- (void)channelBalanceWithRequest:(ChannelBalanceRequest *)request handler:(void(^)(ChannelBalanceResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToChannelBalanceWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `channelbalance`
 * ChannelBalance returns the total funds available across all open channels
 * in satoshis.
 */
- (GRPCProtoCall *)RPCToChannelBalanceWithRequest:(ChannelBalanceRequest *)request handler:(void(^)(ChannelBalanceResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ChannelBalance"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ChannelBalanceResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetTransactions(GetTransactionsRequest) returns (TransactionDetails)

/**
 * * lncli: `listchaintxns`
 * GetTransactions returns a list describing all the known transactions
 * relevant to the wallet.
 */
- (void)getTransactionsWithRequest:(GetTransactionsRequest *)request handler:(void(^)(TransactionDetails *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetTransactionsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listchaintxns`
 * GetTransactions returns a list describing all the known transactions
 * relevant to the wallet.
 */
- (GRPCProtoCall *)RPCToGetTransactionsWithRequest:(GetTransactionsRequest *)request handler:(void(^)(TransactionDetails *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetTransactions"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[TransactionDetails class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SendCoins(SendCoinsRequest) returns (SendCoinsResponse)

/**
 * * lncli: `sendcoins`
 * SendCoins executes a request to send coins to a particular address. Unlike
 * SendMany, this RPC call only allows creating a single output at a time. If
 * neither target_conf, or sat_per_byte are set, then the internal wallet will
 * consult its fee model to determine a fee for the default confirmation
 * target.
 */
- (void)sendCoinsWithRequest:(SendCoinsRequest *)request handler:(void(^)(SendCoinsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSendCoinsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `sendcoins`
 * SendCoins executes a request to send coins to a particular address. Unlike
 * SendMany, this RPC call only allows creating a single output at a time. If
 * neither target_conf, or sat_per_byte are set, then the internal wallet will
 * consult its fee model to determine a fee for the default confirmation
 * target.
 */
- (GRPCProtoCall *)RPCToSendCoinsWithRequest:(SendCoinsRequest *)request handler:(void(^)(SendCoinsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SendCoins"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SendCoinsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SubscribeTransactions(GetTransactionsRequest) returns (stream Transaction)

/**
 * *
 * SubscribeTransactions creates a uni-directional stream from the server to
 * the client in which any newly discovered transactions relevant to the
 * wallet are sent over.
 */
- (void)subscribeTransactionsWithRequest:(GetTransactionsRequest *)request eventHandler:(void(^)(BOOL done, Transaction *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToSubscribeTransactionsWithRequest:request eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * SubscribeTransactions creates a uni-directional stream from the server to
 * the client in which any newly discovered transactions relevant to the
 * wallet are sent over.
 */
- (GRPCProtoCall *)RPCToSubscribeTransactionsWithRequest:(GetTransactionsRequest *)request eventHandler:(void(^)(BOOL done, Transaction *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"SubscribeTransactions"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Transaction class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
#pragma mark SendMany(SendManyRequest) returns (SendManyResponse)

/**
 * * lncli: `sendmany`
 * SendMany handles a request for a transaction that creates multiple specified
 * outputs in parallel. If neither target_conf, or sat_per_byte are set, then
 * the internal wallet will consult its fee model to determine a fee for the
 * default confirmation target.
 */
- (void)sendManyWithRequest:(SendManyRequest *)request handler:(void(^)(SendManyResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSendManyWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `sendmany`
 * SendMany handles a request for a transaction that creates multiple specified
 * outputs in parallel. If neither target_conf, or sat_per_byte are set, then
 * the internal wallet will consult its fee model to determine a fee for the
 * default confirmation target.
 */
- (GRPCProtoCall *)RPCToSendManyWithRequest:(SendManyRequest *)request handler:(void(^)(SendManyResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SendMany"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SendManyResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark NewAddress(NewAddressRequest) returns (NewAddressResponse)

/**
 * * lncli: `newaddress`
 * NewAddress creates a new address under control of the local wallet.
 */
- (void)newAddressWithRequest:(NewAddressRequest *)request handler:(void(^)(NewAddressResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToNewAddressWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `newaddress`
 * NewAddress creates a new address under control of the local wallet.
 */
- (GRPCProtoCall *)RPCToNewAddressWithRequest:(NewAddressRequest *)request handler:(void(^)(NewAddressResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"NewAddress"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[NewAddressResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark NewWitnessAddress(NewWitnessAddressRequest) returns (NewAddressResponse)

/**
 * *
 * NewWitnessAddress creates a new witness address under control of the local wallet.
 */
- (void)newWitnessAddressWithRequest:(NewWitnessAddressRequest *)request handler:(void(^)(NewAddressResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToNewWitnessAddressWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * NewWitnessAddress creates a new witness address under control of the local wallet.
 */
- (GRPCProtoCall *)RPCToNewWitnessAddressWithRequest:(NewWitnessAddressRequest *)request handler:(void(^)(NewAddressResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"NewWitnessAddress"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[NewAddressResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SignMessage(SignMessageRequest) returns (SignMessageResponse)

/**
 * * lncli: `signmessage`
 * SignMessage signs a message with this node's private key. The returned
 * signature string is `zbase32` encoded and pubkey recoverable, meaning that
 * only the message digest and signature are needed for verification.
 */
- (void)signMessageWithRequest:(SignMessageRequest *)request handler:(void(^)(SignMessageResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSignMessageWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `signmessage`
 * SignMessage signs a message with this node's private key. The returned
 * signature string is `zbase32` encoded and pubkey recoverable, meaning that
 * only the message digest and signature are needed for verification.
 */
- (GRPCProtoCall *)RPCToSignMessageWithRequest:(SignMessageRequest *)request handler:(void(^)(SignMessageResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SignMessage"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SignMessageResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark VerifyMessage(VerifyMessageRequest) returns (VerifyMessageResponse)

/**
 * * lncli: `verifymessage`
 * VerifyMessage verifies a signature over a msg. The signature must be
 * zbase32 encoded and signed by an active node in the resident node's
 * channel database. In addition to returning the validity of the signature,
 * VerifyMessage also returns the recovered pubkey from the signature.
 */
- (void)verifyMessageWithRequest:(VerifyMessageRequest *)request handler:(void(^)(VerifyMessageResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToVerifyMessageWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `verifymessage`
 * VerifyMessage verifies a signature over a msg. The signature must be
 * zbase32 encoded and signed by an active node in the resident node's
 * channel database. In addition to returning the validity of the signature,
 * VerifyMessage also returns the recovered pubkey from the signature.
 */
- (GRPCProtoCall *)RPCToVerifyMessageWithRequest:(VerifyMessageRequest *)request handler:(void(^)(VerifyMessageResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"VerifyMessage"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[VerifyMessageResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ConnectPeer(ConnectPeerRequest) returns (ConnectPeerResponse)

/**
 * * lncli: `connect`
 * ConnectPeer attempts to establish a connection to a remote peer. This is at
 * the networking level, and is used for communication between nodes. This is
 * distinct from establishing a channel with a peer.
 */
- (void)connectPeerWithRequest:(ConnectPeerRequest *)request handler:(void(^)(ConnectPeerResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToConnectPeerWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `connect`
 * ConnectPeer attempts to establish a connection to a remote peer. This is at
 * the networking level, and is used for communication between nodes. This is
 * distinct from establishing a channel with a peer.
 */
- (GRPCProtoCall *)RPCToConnectPeerWithRequest:(ConnectPeerRequest *)request handler:(void(^)(ConnectPeerResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ConnectPeer"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ConnectPeerResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DisconnectPeer(DisconnectPeerRequest) returns (DisconnectPeerResponse)

/**
 * * lncli: `disconnect`
 * DisconnectPeer attempts to disconnect one peer from another identified by a
 * given pubKey. In the case that we currently have a pending or active channel
 * with the target peer, then this action will be not be allowed.
 */
- (void)disconnectPeerWithRequest:(DisconnectPeerRequest *)request handler:(void(^)(DisconnectPeerResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDisconnectPeerWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `disconnect`
 * DisconnectPeer attempts to disconnect one peer from another identified by a
 * given pubKey. In the case that we currently have a pending or active channel
 * with the target peer, then this action will be not be allowed.
 */
- (GRPCProtoCall *)RPCToDisconnectPeerWithRequest:(DisconnectPeerRequest *)request handler:(void(^)(DisconnectPeerResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DisconnectPeer"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[DisconnectPeerResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListPeers(ListPeersRequest) returns (ListPeersResponse)

/**
 * * lncli: `listpeers`
 * ListPeers returns a verbose listing of all currently active peers.
 */
- (void)listPeersWithRequest:(ListPeersRequest *)request handler:(void(^)(ListPeersResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListPeersWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listpeers`
 * ListPeers returns a verbose listing of all currently active peers.
 */
- (GRPCProtoCall *)RPCToListPeersWithRequest:(ListPeersRequest *)request handler:(void(^)(ListPeersResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListPeers"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListPeersResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetInfo(GetInfoRequest) returns (GetInfoResponse)

/**
 * * lncli: `getinfo`
 * GetInfo returns general information concerning the lightning node including
 * it's identity pubkey, alias, the chains it is connected to, and information
 * concerning the number of open+pending channels.
 */
- (void)getInfoWithRequest:(GetInfoRequest *)request handler:(void(^)(GetInfoResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetInfoWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `getinfo`
 * GetInfo returns general information concerning the lightning node including
 * it's identity pubkey, alias, the chains it is connected to, and information
 * concerning the number of open+pending channels.
 */
- (GRPCProtoCall *)RPCToGetInfoWithRequest:(GetInfoRequest *)request handler:(void(^)(GetInfoResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GetInfoResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
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
- (void)pendingChannelsWithRequest:(PendingChannelsRequest *)request handler:(void(^)(PendingChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToPendingChannelsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * TODO(roasbeef): merge with below with bool?
 * 
 * * lncli: `pendingchannels`
 * PendingChannels returns a list of all the channels that are currently
 * considered "pending". A channel is pending if it has finished the funding
 * workflow and is waiting for confirmations for the funding txn, or is in the
 * process of closure, either initiated cooperatively or non-cooperatively.
 */
- (GRPCProtoCall *)RPCToPendingChannelsWithRequest:(PendingChannelsRequest *)request handler:(void(^)(PendingChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"PendingChannels"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[PendingChannelsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListChannels(ListChannelsRequest) returns (ListChannelsResponse)

/**
 * * lncli: `listchannels`
 * ListChannels returns a description of all the open channels that this node
 * is a participant in.
 */
- (void)listChannelsWithRequest:(ListChannelsRequest *)request handler:(void(^)(ListChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListChannelsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listchannels`
 * ListChannels returns a description of all the open channels that this node
 * is a participant in.
 */
- (GRPCProtoCall *)RPCToListChannelsWithRequest:(ListChannelsRequest *)request handler:(void(^)(ListChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListChannels"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListChannelsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark OpenChannelSync(OpenChannelRequest) returns (ChannelPoint)

/**
 * *
 * OpenChannelSync is a synchronous version of the OpenChannel RPC call. This
 * call is meant to be consumed by clients to the REST proxy. As with all
 * other sync calls, all byte slices are intended to be populated as hex
 * encoded strings.
 */
- (void)openChannelSyncWithRequest:(OpenChannelRequest *)request handler:(void(^)(ChannelPoint *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToOpenChannelSyncWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * OpenChannelSync is a synchronous version of the OpenChannel RPC call. This
 * call is meant to be consumed by clients to the REST proxy. As with all
 * other sync calls, all byte slices are intended to be populated as hex
 * encoded strings.
 */
- (GRPCProtoCall *)RPCToOpenChannelSyncWithRequest:(OpenChannelRequest *)request handler:(void(^)(ChannelPoint *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"OpenChannelSync"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ChannelPoint class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark OpenChannel(OpenChannelRequest) returns (stream OpenStatusUpdate)

/**
 * * lncli: `openchannel`
 * OpenChannel attempts to open a singly funded channel specified in the
 * request to a remote peer. Users are able to specify a target number of
 * blocks that the funding transaction should be confirmed in, or a manual fee
 * rate to us for the funding transaction. If neither are specified, then a
 * lax block confirmation target is used.
 */
- (void)openChannelWithRequest:(OpenChannelRequest *)request eventHandler:(void(^)(BOOL done, OpenStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToOpenChannelWithRequest:request eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `openchannel`
 * OpenChannel attempts to open a singly funded channel specified in the
 * request to a remote peer. Users are able to specify a target number of
 * blocks that the funding transaction should be confirmed in, or a manual fee
 * rate to us for the funding transaction. If neither are specified, then a
 * lax block confirmation target is used.
 */
- (GRPCProtoCall *)RPCToOpenChannelWithRequest:(OpenChannelRequest *)request eventHandler:(void(^)(BOOL done, OpenStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"OpenChannel"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[OpenStatusUpdate class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
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
- (void)closeChannelWithRequest:(CloseChannelRequest *)request eventHandler:(void(^)(BOOL done, CloseStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToCloseChannelWithRequest:request eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
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
- (GRPCProtoCall *)RPCToCloseChannelWithRequest:(CloseChannelRequest *)request eventHandler:(void(^)(BOOL done, CloseStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"CloseChannel"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[CloseStatusUpdate class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
#pragma mark SendPayment(stream SendRequest) returns (stream SendResponse)

/**
 * * lncli: `sendpayment`
 * SendPayment dispatches a bi-directional streaming RPC for sending payments
 * through the Lightning Network. A single RPC invocation creates a persistent
 * bi-directional stream allowing clients to rapidly send payments through the
 * Lightning Network with a single persistent connection.
 */
- (void)sendPaymentWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, SendResponse *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToSendPaymentWithRequestsWriter:requestWriter eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `sendpayment`
 * SendPayment dispatches a bi-directional streaming RPC for sending payments
 * through the Lightning Network. A single RPC invocation creates a persistent
 * bi-directional stream allowing clients to rapidly send payments through the
 * Lightning Network with a single persistent connection.
 */
- (GRPCProtoCall *)RPCToSendPaymentWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, SendResponse *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"SendPayment"
            requestsWriter:requestWriter
             responseClass:[SendResponse class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
#pragma mark SendPaymentSync(SendRequest) returns (SendResponse)

/**
 * *
 * SendPaymentSync is the synchronous non-streaming version of SendPayment.
 * This RPC is intended to be consumed by clients of the REST proxy.
 * Additionally, this RPC expects the destination's public key and the payment
 * hash (if any) to be encoded as hex strings.
 */
- (void)sendPaymentSyncWithRequest:(SendRequest *)request handler:(void(^)(SendResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSendPaymentSyncWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * SendPaymentSync is the synchronous non-streaming version of SendPayment.
 * This RPC is intended to be consumed by clients of the REST proxy.
 * Additionally, this RPC expects the destination's public key and the payment
 * hash (if any) to be encoded as hex strings.
 */
- (GRPCProtoCall *)RPCToSendPaymentSyncWithRequest:(SendRequest *)request handler:(void(^)(SendResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SendPaymentSync"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SendResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark AddInvoice(Invoice) returns (AddInvoiceResponse)

/**
 * * lncli: `addinvoice`
 * AddInvoice attempts to add a new invoice to the invoice database. Any
 * duplicated invoices are rejected, therefore all invoices *must* have a
 * unique payment preimage.
 */
- (void)addInvoiceWithRequest:(Invoice *)request handler:(void(^)(AddInvoiceResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToAddInvoiceWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `addinvoice`
 * AddInvoice attempts to add a new invoice to the invoice database. Any
 * duplicated invoices are rejected, therefore all invoices *must* have a
 * unique payment preimage.
 */
- (GRPCProtoCall *)RPCToAddInvoiceWithRequest:(Invoice *)request handler:(void(^)(AddInvoiceResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"AddInvoice"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[AddInvoiceResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListInvoices(ListInvoiceRequest) returns (ListInvoiceResponse)

/**
 * * lncli: `listinvoices`
 * ListInvoices returns a list of all the invoices currently stored within the
 * database. Any active debug invoices are ignored.
 */
- (void)listInvoicesWithRequest:(ListInvoiceRequest *)request handler:(void(^)(ListInvoiceResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListInvoicesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listinvoices`
 * ListInvoices returns a list of all the invoices currently stored within the
 * database. Any active debug invoices are ignored.
 */
- (GRPCProtoCall *)RPCToListInvoicesWithRequest:(ListInvoiceRequest *)request handler:(void(^)(ListInvoiceResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListInvoices"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListInvoiceResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark LookupInvoice(PaymentHash) returns (Invoice)

/**
 * * lncli: `lookupinvoice`
 * LookupInvoice attempts to look up an invoice according to its payment hash.
 * The passed payment hash *must* be exactly 32 bytes, if not, an error is
 * returned.
 */
- (void)lookupInvoiceWithRequest:(PaymentHash *)request handler:(void(^)(Invoice *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToLookupInvoiceWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `lookupinvoice`
 * LookupInvoice attempts to look up an invoice according to its payment hash.
 * The passed payment hash *must* be exactly 32 bytes, if not, an error is
 * returned.
 */
- (GRPCProtoCall *)RPCToLookupInvoiceWithRequest:(PaymentHash *)request handler:(void(^)(Invoice *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"LookupInvoice"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Invoice class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SubscribeInvoices(InvoiceSubscription) returns (stream Invoice)

/**
 * *
 * SubscribeInvoices returns a uni-directional stream (sever -> client) for
 * notifying the client of newly added/settled invoices.
 */
- (void)subscribeInvoicesWithRequest:(InvoiceSubscription *)request eventHandler:(void(^)(BOOL done, Invoice *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToSubscribeInvoicesWithRequest:request eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * SubscribeInvoices returns a uni-directional stream (sever -> client) for
 * notifying the client of newly added/settled invoices.
 */
- (GRPCProtoCall *)RPCToSubscribeInvoicesWithRequest:(InvoiceSubscription *)request eventHandler:(void(^)(BOOL done, Invoice *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"SubscribeInvoices"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Invoice class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
#pragma mark DecodePayReq(PayReqString) returns (PayReq)

/**
 * * lncli: `decodepayreq`
 * DecodePayReq takes an encoded payment request string and attempts to decode
 * it, returning a full description of the conditions encoded within the
 * payment request.
 */
- (void)decodePayReqWithRequest:(PayReqString *)request handler:(void(^)(PayReq *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDecodePayReqWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `decodepayreq`
 * DecodePayReq takes an encoded payment request string and attempts to decode
 * it, returning a full description of the conditions encoded within the
 * payment request.
 */
- (GRPCProtoCall *)RPCToDecodePayReqWithRequest:(PayReqString *)request handler:(void(^)(PayReq *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DecodePayReq"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[PayReq class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListPayments(ListPaymentsRequest) returns (ListPaymentsResponse)

/**
 * * lncli: `listpayments`
 * ListPayments returns a list of all outgoing payments.
 */
- (void)listPaymentsWithRequest:(ListPaymentsRequest *)request handler:(void(^)(ListPaymentsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListPaymentsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listpayments`
 * ListPayments returns a list of all outgoing payments.
 */
- (GRPCProtoCall *)RPCToListPaymentsWithRequest:(ListPaymentsRequest *)request handler:(void(^)(ListPaymentsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListPayments"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListPaymentsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DeleteAllPayments(DeleteAllPaymentsRequest) returns (DeleteAllPaymentsResponse)

/**
 * *
 * DeleteAllPayments deletes all outgoing payments from DB.
 */
- (void)deleteAllPaymentsWithRequest:(DeleteAllPaymentsRequest *)request handler:(void(^)(DeleteAllPaymentsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDeleteAllPaymentsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * DeleteAllPayments deletes all outgoing payments from DB.
 */
- (GRPCProtoCall *)RPCToDeleteAllPaymentsWithRequest:(DeleteAllPaymentsRequest *)request handler:(void(^)(DeleteAllPaymentsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DeleteAllPayments"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[DeleteAllPaymentsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
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
- (void)describeGraphWithRequest:(ChannelGraphRequest *)request handler:(void(^)(ChannelGraph *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDescribeGraphWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `describegraph`
 * DescribeGraph returns a description of the latest graph state from the
 * point of view of the node. The graph information is partitioned into two
 * components: all the nodes/vertexes, and all the edges that connect the
 * vertexes themselves.  As this is a directed graph, the edges also contain
 * the node directional specific routing policy which includes: the time lock
 * delta, fee information, etc.
 */
- (GRPCProtoCall *)RPCToDescribeGraphWithRequest:(ChannelGraphRequest *)request handler:(void(^)(ChannelGraph *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DescribeGraph"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ChannelGraph class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetChanInfo(ChanInfoRequest) returns (ChannelEdge)

/**
 * * lncli: `getchaninfo`
 * GetChanInfo returns the latest authenticated network announcement for the
 * given channel identified by its channel ID: an 8-byte integer which
 * uniquely identifies the location of transaction's funding output within the
 * blockchain.
 */
- (void)getChanInfoWithRequest:(ChanInfoRequest *)request handler:(void(^)(ChannelEdge *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetChanInfoWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `getchaninfo`
 * GetChanInfo returns the latest authenticated network announcement for the
 * given channel identified by its channel ID: an 8-byte integer which
 * uniquely identifies the location of transaction's funding output within the
 * blockchain.
 */
- (GRPCProtoCall *)RPCToGetChanInfoWithRequest:(ChanInfoRequest *)request handler:(void(^)(ChannelEdge *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetChanInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ChannelEdge class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetNodeInfo(NodeInfoRequest) returns (NodeInfo)

/**
 * * lncli: `getnodeinfo`
 * GetNodeInfo returns the latest advertised, aggregated, and authenticated
 * channel information for the specified node identified by its public key.
 */
- (void)getNodeInfoWithRequest:(NodeInfoRequest *)request handler:(void(^)(NodeInfo *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetNodeInfoWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `getnodeinfo`
 * GetNodeInfo returns the latest advertised, aggregated, and authenticated
 * channel information for the specified node identified by its public key.
 */
- (GRPCProtoCall *)RPCToGetNodeInfoWithRequest:(NodeInfoRequest *)request handler:(void(^)(NodeInfo *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetNodeInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[NodeInfo class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark QueryRoutes(QueryRoutesRequest) returns (QueryRoutesResponse)

/**
 * * lncli: `queryroutes`
 * QueryRoutes attempts to query the daemon's Channel Router for a possible
 * route to a target destination capable of carrying a specific amount of
 * satoshis. The retuned route contains the full details required to craft and
 * send an HTLC, also including the necessary information that should be
 * present within the Sphinx packet encapsulated within the HTLC.
 */
- (void)queryRoutesWithRequest:(QueryRoutesRequest *)request handler:(void(^)(QueryRoutesResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToQueryRoutesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `queryroutes`
 * QueryRoutes attempts to query the daemon's Channel Router for a possible
 * route to a target destination capable of carrying a specific amount of
 * satoshis. The retuned route contains the full details required to craft and
 * send an HTLC, also including the necessary information that should be
 * present within the Sphinx packet encapsulated within the HTLC.
 */
- (GRPCProtoCall *)RPCToQueryRoutesWithRequest:(QueryRoutesRequest *)request handler:(void(^)(QueryRoutesResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"QueryRoutes"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[QueryRoutesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetNetworkInfo(NetworkInfoRequest) returns (NetworkInfo)

/**
 * * lncli: `getnetworkinfo`
 * GetNetworkInfo returns some basic stats about the known channel graph from
 * the point of view of the node.
 */
- (void)getNetworkInfoWithRequest:(NetworkInfoRequest *)request handler:(void(^)(NetworkInfo *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetNetworkInfoWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `getnetworkinfo`
 * GetNetworkInfo returns some basic stats about the known channel graph from
 * the point of view of the node.
 */
- (GRPCProtoCall *)RPCToGetNetworkInfoWithRequest:(NetworkInfoRequest *)request handler:(void(^)(NetworkInfo *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetNetworkInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[NetworkInfo class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark StopDaemon(StopRequest) returns (StopResponse)

/**
 * * lncli: `stop`
 * StopDaemon will send a shutdown request to the interrupt handler, triggering
 * a graceful shutdown of the daemon.
 */
- (void)stopDaemonWithRequest:(StopRequest *)request handler:(void(^)(StopResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToStopDaemonWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `stop`
 * StopDaemon will send a shutdown request to the interrupt handler, triggering
 * a graceful shutdown of the daemon.
 */
- (GRPCProtoCall *)RPCToStopDaemonWithRequest:(StopRequest *)request handler:(void(^)(StopResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"StopDaemon"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[StopResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
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
- (void)subscribeChannelGraphWithRequest:(GraphTopologySubscription *)request eventHandler:(void(^)(BOOL done, GraphTopologyUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToSubscribeChannelGraphWithRequest:request eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * SubscribeChannelGraph launches a streaming RPC that allows the caller to
 * receive notifications upon any changes to the channel graph topology from
 * the point of view of the responding node. Events notified include: new
 * nodes coming online, nodes updating their authenticated attributes, new
 * channels being advertised, updates in the routing policy for a directional
 * channel edge, and when channels are closed on-chain.
 */
- (GRPCProtoCall *)RPCToSubscribeChannelGraphWithRequest:(GraphTopologySubscription *)request eventHandler:(void(^)(BOOL done, GraphTopologyUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"SubscribeChannelGraph"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GraphTopologyUpdate class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
#pragma mark DebugLevel(DebugLevelRequest) returns (DebugLevelResponse)

/**
 * * lncli: `debuglevel`
 * DebugLevel allows a caller to programmatically set the logging verbosity of
 * lnd. The logging can be targeted according to a coarse daemon-wide logging
 * level, or in a granular fashion to specify the logging for a target
 * sub-system.
 */
- (void)debugLevelWithRequest:(DebugLevelRequest *)request handler:(void(^)(DebugLevelResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDebugLevelWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `debuglevel`
 * DebugLevel allows a caller to programmatically set the logging verbosity of
 * lnd. The logging can be targeted according to a coarse daemon-wide logging
 * level, or in a granular fashion to specify the logging for a target
 * sub-system.
 */
- (GRPCProtoCall *)RPCToDebugLevelWithRequest:(DebugLevelRequest *)request handler:(void(^)(DebugLevelResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DebugLevel"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[DebugLevelResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark FeeReport(FeeReportRequest) returns (FeeReportResponse)

/**
 * * lncli: `feereport`
 * FeeReport allows the caller to obtain a report detailing the current fee
 * schedule enforced by the node globally for each channel.
 */
- (void)feeReportWithRequest:(FeeReportRequest *)request handler:(void(^)(FeeReportResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToFeeReportWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `feereport`
 * FeeReport allows the caller to obtain a report detailing the current fee
 * schedule enforced by the node globally for each channel.
 */
- (GRPCProtoCall *)RPCToFeeReportWithRequest:(FeeReportRequest *)request handler:(void(^)(FeeReportResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"FeeReport"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[FeeReportResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UpdateChannelPolicy(PolicyUpdateRequest) returns (PolicyUpdateResponse)

/**
 * * lncli: `updatechanpolicy`
 * UpdateChannelPolicy allows the caller to update the fee schedule and
 * channel policies for all channels globally, or a particular channel.
 */
- (void)updateChannelPolicyWithRequest:(PolicyUpdateRequest *)request handler:(void(^)(PolicyUpdateResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToUpdateChannelPolicyWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `updatechanpolicy`
 * UpdateChannelPolicy allows the caller to update the fee schedule and
 * channel policies for all channels globally, or a particular channel.
 */
- (GRPCProtoCall *)RPCToUpdateChannelPolicyWithRequest:(PolicyUpdateRequest *)request handler:(void(^)(PolicyUpdateResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"UpdateChannelPolicy"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[PolicyUpdateResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
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
- (void)forwardingHistoryWithRequest:(ForwardingHistoryRequest *)request handler:(void(^)(ForwardingHistoryResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToForwardingHistoryWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
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
- (GRPCProtoCall *)RPCToForwardingHistoryWithRequest:(ForwardingHistoryRequest *)request handler:(void(^)(ForwardingHistoryResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ForwardingHistory"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ForwardingHistoryResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
