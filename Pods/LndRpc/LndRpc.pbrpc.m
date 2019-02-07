#if !defined(GPB_GRPC_PROTOCOL_ONLY) || !GPB_GRPC_PROTOCOL_ONLY
#import "LndRpc.pbrpc.h"
#import "LndRpc.pbobjc.h"
#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

//#import "google/api/Annotations.pbobjc.h"

@implementation LNDWalletUnlocker

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  self = [super initWithHost:host
                 packageName:@"lnrpc"
                 serviceName:@"WalletUnlocker"];
  return self;
}

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

#pragma mark - Class Methods

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}

#pragma mark - Method Implementations

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
- (void)genSeedWithRequest:(LNDGenSeedRequest *)request handler:(void(^)(LNDGenSeedResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToGenSeedWithRequest:(LNDGenSeedRequest *)request handler:(void(^)(LNDGenSeedResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GenSeed"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDGenSeedResponse class]
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
- (void)initWalletWithRequest:(LNDInitWalletRequest *)request handler:(void(^)(LNDInitWalletResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToInitWalletWithRequest:(LNDInitWalletRequest *)request handler:(void(^)(LNDInitWalletResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"InitWallet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDInitWalletResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UnlockWallet(UnlockWalletRequest) returns (UnlockWalletResponse)

/**
 * * lncli: `unlock`
 * UnlockWallet is used at startup of lnd to provide a password to unlock
 * the wallet database.
 */
- (void)unlockWalletWithRequest:(LNDUnlockWalletRequest *)request handler:(void(^)(LNDUnlockWalletResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToUnlockWalletWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `unlock`
 * UnlockWallet is used at startup of lnd to provide a password to unlock
 * the wallet database.
 */
- (GRPCProtoCall *)RPCToUnlockWalletWithRequest:(LNDUnlockWalletRequest *)request handler:(void(^)(LNDUnlockWalletResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"UnlockWallet"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDUnlockWalletResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ChangePassword(ChangePasswordRequest) returns (ChangePasswordResponse)

/**
 * * lncli: `changepassword`
 * ChangePassword changes the password of the encrypted wallet. This will
 * automatically unlock the wallet database if successful.
 */
- (void)changePasswordWithRequest:(LNDChangePasswordRequest *)request handler:(void(^)(LNDChangePasswordResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToChangePasswordWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `changepassword`
 * ChangePassword changes the password of the encrypted wallet. This will
 * automatically unlock the wallet database if successful.
 */
- (GRPCProtoCall *)RPCToChangePasswordWithRequest:(LNDChangePasswordRequest *)request handler:(void(^)(LNDChangePasswordResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ChangePassword"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDChangePasswordResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
@implementation LNDLightning

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  self = [super initWithHost:host
                 packageName:@"lnrpc"
                 serviceName:@"Lightning"];
  return self;
}

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

#pragma mark - Class Methods

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}

#pragma mark - Method Implementations

#pragma mark WalletBalance(WalletBalanceRequest) returns (WalletBalanceResponse)

/**
 * * lncli: `walletbalance`
 * WalletBalance returns total unspent outputs(confirmed and unconfirmed), all
 * confirmed unspent outputs and all unconfirmed unspent outputs under control
 * of the wallet. 
 */
- (void)walletBalanceWithRequest:(LNDWalletBalanceRequest *)request handler:(void(^)(LNDWalletBalanceResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToWalletBalanceWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `walletbalance`
 * WalletBalance returns total unspent outputs(confirmed and unconfirmed), all
 * confirmed unspent outputs and all unconfirmed unspent outputs under control
 * of the wallet. 
 */
- (GRPCProtoCall *)RPCToWalletBalanceWithRequest:(LNDWalletBalanceRequest *)request handler:(void(^)(LNDWalletBalanceResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"WalletBalance"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDWalletBalanceResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ChannelBalance(ChannelBalanceRequest) returns (ChannelBalanceResponse)

/**
 * * lncli: `channelbalance`
 * ChannelBalance returns the total funds available across all open channels
 * in satoshis.
 */
- (void)channelBalanceWithRequest:(LNDChannelBalanceRequest *)request handler:(void(^)(LNDChannelBalanceResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToChannelBalanceWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `channelbalance`
 * ChannelBalance returns the total funds available across all open channels
 * in satoshis.
 */
- (GRPCProtoCall *)RPCToChannelBalanceWithRequest:(LNDChannelBalanceRequest *)request handler:(void(^)(LNDChannelBalanceResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ChannelBalance"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDChannelBalanceResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetTransactions(GetTransactionsRequest) returns (TransactionDetails)

/**
 * * lncli: `listchaintxns`
 * GetTransactions returns a list describing all the known transactions
 * relevant to the wallet.
 */
- (void)getTransactionsWithRequest:(LNDGetTransactionsRequest *)request handler:(void(^)(LNDTransactionDetails *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetTransactionsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listchaintxns`
 * GetTransactions returns a list describing all the known transactions
 * relevant to the wallet.
 */
- (GRPCProtoCall *)RPCToGetTransactionsWithRequest:(LNDGetTransactionsRequest *)request handler:(void(^)(LNDTransactionDetails *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetTransactions"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDTransactionDetails class]
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
- (void)sendCoinsWithRequest:(LNDSendCoinsRequest *)request handler:(void(^)(LNDSendCoinsResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToSendCoinsWithRequest:(LNDSendCoinsRequest *)request handler:(void(^)(LNDSendCoinsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SendCoins"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDSendCoinsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListUnspent(ListUnspentRequest) returns (ListUnspentResponse)

/**
 * * lncli: `listunspent`
 * ListUnspent returns a list of all utxos spendable by the wallet with a
 * number of confirmations between the specified minimum and maximum.
 */
- (void)listUnspentWithRequest:(LNDListUnspentRequest *)request handler:(void(^)(LNDListUnspentResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListUnspentWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listunspent`
 * ListUnspent returns a list of all utxos spendable by the wallet with a
 * number of confirmations between the specified minimum and maximum.
 */
- (GRPCProtoCall *)RPCToListUnspentWithRequest:(LNDListUnspentRequest *)request handler:(void(^)(LNDListUnspentResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListUnspent"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDListUnspentResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SubscribeTransactions(GetTransactionsRequest) returns (stream Transaction)

/**
 * *
 * SubscribeTransactions creates a uni-directional stream from the server to
 * the client in which any newly discovered transactions relevant to the
 * wallet are sent over.
 */
- (void)subscribeTransactionsWithRequest:(LNDGetTransactionsRequest *)request eventHandler:(void(^)(BOOL done, LNDTransaction *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToSubscribeTransactionsWithRequest:request eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * SubscribeTransactions creates a uni-directional stream from the server to
 * the client in which any newly discovered transactions relevant to the
 * wallet are sent over.
 */
- (GRPCProtoCall *)RPCToSubscribeTransactionsWithRequest:(LNDGetTransactionsRequest *)request eventHandler:(void(^)(BOOL done, LNDTransaction *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"SubscribeTransactions"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDTransaction class]
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
- (void)sendManyWithRequest:(LNDSendManyRequest *)request handler:(void(^)(LNDSendManyResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToSendManyWithRequest:(LNDSendManyRequest *)request handler:(void(^)(LNDSendManyResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SendMany"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDSendManyResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark NewAddress(NewAddressRequest) returns (NewAddressResponse)

/**
 * * lncli: `newaddress`
 * NewAddress creates a new address under control of the local wallet.
 */
- (void)newAddressWithRequest:(LNDNewAddressRequest *)request handler:(void(^)(LNDNewAddressResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToNewAddressWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `newaddress`
 * NewAddress creates a new address under control of the local wallet.
 */
- (GRPCProtoCall *)RPCToNewAddressWithRequest:(LNDNewAddressRequest *)request handler:(void(^)(LNDNewAddressResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"NewAddress"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDNewAddressResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SignMessage(SignMessageRequest) returns (SignMessageResponse)

/**
 * * lncli: `signmessage`
 * SignMessage signs a message with this node's private key. The returned
 * signature string is `zbase32` encoded and pubkey recoverable, meaning that
 * only the message digest and signature are needed for verification.
 */
- (void)signMessageWithRequest:(LNDSignMessageRequest *)request handler:(void(^)(LNDSignMessageResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSignMessageWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `signmessage`
 * SignMessage signs a message with this node's private key. The returned
 * signature string is `zbase32` encoded and pubkey recoverable, meaning that
 * only the message digest and signature are needed for verification.
 */
- (GRPCProtoCall *)RPCToSignMessageWithRequest:(LNDSignMessageRequest *)request handler:(void(^)(LNDSignMessageResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SignMessage"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDSignMessageResponse class]
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
- (void)verifyMessageWithRequest:(LNDVerifyMessageRequest *)request handler:(void(^)(LNDVerifyMessageResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToVerifyMessageWithRequest:(LNDVerifyMessageRequest *)request handler:(void(^)(LNDVerifyMessageResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"VerifyMessage"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDVerifyMessageResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ConnectPeer(ConnectPeerRequest) returns (ConnectPeerResponse)

/**
 * * lncli: `connect`
 * ConnectPeer attempts to establish a connection to a remote peer. This is at
 * the networking level, and is used for communication between nodes. This is
 * distinct from establishing a channel with a peer.
 */
- (void)connectPeerWithRequest:(LNDConnectPeerRequest *)request handler:(void(^)(LNDConnectPeerResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToConnectPeerWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `connect`
 * ConnectPeer attempts to establish a connection to a remote peer. This is at
 * the networking level, and is used for communication between nodes. This is
 * distinct from establishing a channel with a peer.
 */
- (GRPCProtoCall *)RPCToConnectPeerWithRequest:(LNDConnectPeerRequest *)request handler:(void(^)(LNDConnectPeerResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ConnectPeer"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDConnectPeerResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DisconnectPeer(DisconnectPeerRequest) returns (DisconnectPeerResponse)

/**
 * * lncli: `disconnect`
 * DisconnectPeer attempts to disconnect one peer from another identified by a
 * given pubKey. In the case that we currently have a pending or active channel
 * with the target peer, then this action will be not be allowed.
 */
- (void)disconnectPeerWithRequest:(LNDDisconnectPeerRequest *)request handler:(void(^)(LNDDisconnectPeerResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDisconnectPeerWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `disconnect`
 * DisconnectPeer attempts to disconnect one peer from another identified by a
 * given pubKey. In the case that we currently have a pending or active channel
 * with the target peer, then this action will be not be allowed.
 */
- (GRPCProtoCall *)RPCToDisconnectPeerWithRequest:(LNDDisconnectPeerRequest *)request handler:(void(^)(LNDDisconnectPeerResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DisconnectPeer"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDDisconnectPeerResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListPeers(ListPeersRequest) returns (ListPeersResponse)

/**
 * * lncli: `listpeers`
 * ListPeers returns a verbose listing of all currently active peers.
 */
- (void)listPeersWithRequest:(LNDListPeersRequest *)request handler:(void(^)(LNDListPeersResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListPeersWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listpeers`
 * ListPeers returns a verbose listing of all currently active peers.
 */
- (GRPCProtoCall *)RPCToListPeersWithRequest:(LNDListPeersRequest *)request handler:(void(^)(LNDListPeersResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListPeers"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDListPeersResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetInfo(GetInfoRequest) returns (GetInfoResponse)

/**
 * * lncli: `getinfo`
 * GetInfo returns general information concerning the lightning node including
 * it's identity pubkey, alias, the chains it is connected to, and information
 * concerning the number of open+pending channels.
 */
- (void)getInfoWithRequest:(LNDGetInfoRequest *)request handler:(void(^)(LNDGetInfoResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetInfoWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `getinfo`
 * GetInfo returns general information concerning the lightning node including
 * it's identity pubkey, alias, the chains it is connected to, and information
 * concerning the number of open+pending channels.
 */
- (GRPCProtoCall *)RPCToGetInfoWithRequest:(LNDGetInfoRequest *)request handler:(void(^)(LNDGetInfoResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDGetInfoResponse class]
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
- (void)pendingChannelsWithRequest:(LNDPendingChannelsRequest *)request handler:(void(^)(LNDPendingChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToPendingChannelsWithRequest:(LNDPendingChannelsRequest *)request handler:(void(^)(LNDPendingChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"PendingChannels"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDPendingChannelsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListChannels(ListChannelsRequest) returns (ListChannelsResponse)

/**
 * * lncli: `listchannels`
 * ListChannels returns a description of all the open channels that this node
 * is a participant in.
 */
- (void)listChannelsWithRequest:(LNDListChannelsRequest *)request handler:(void(^)(LNDListChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListChannelsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listchannels`
 * ListChannels returns a description of all the open channels that this node
 * is a participant in.
 */
- (GRPCProtoCall *)RPCToListChannelsWithRequest:(LNDListChannelsRequest *)request handler:(void(^)(LNDListChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListChannels"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDListChannelsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ClosedChannels(ClosedChannelsRequest) returns (ClosedChannelsResponse)

/**
 * * lncli: `closedchannels`
 * ClosedChannels returns a description of all the closed channels that 
 * this node was a participant in.
 */
- (void)closedChannelsWithRequest:(LNDClosedChannelsRequest *)request handler:(void(^)(LNDClosedChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToClosedChannelsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `closedchannels`
 * ClosedChannels returns a description of all the closed channels that 
 * this node was a participant in.
 */
- (GRPCProtoCall *)RPCToClosedChannelsWithRequest:(LNDClosedChannelsRequest *)request handler:(void(^)(LNDClosedChannelsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ClosedChannels"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDClosedChannelsResponse class]
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
- (void)openChannelSyncWithRequest:(LNDOpenChannelRequest *)request handler:(void(^)(LNDChannelPoint *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToOpenChannelSyncWithRequest:(LNDOpenChannelRequest *)request handler:(void(^)(LNDChannelPoint *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"OpenChannelSync"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDChannelPoint class]
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
- (void)openChannelWithRequest:(LNDOpenChannelRequest *)request eventHandler:(void(^)(BOOL done, LNDOpenStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
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
- (GRPCProtoCall *)RPCToOpenChannelWithRequest:(LNDOpenChannelRequest *)request eventHandler:(void(^)(BOOL done, LNDOpenStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"OpenChannel"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDOpenStatusUpdate class]
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
- (void)closeChannelWithRequest:(LNDCloseChannelRequest *)request eventHandler:(void(^)(BOOL done, LNDCloseStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
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
- (GRPCProtoCall *)RPCToCloseChannelWithRequest:(LNDCloseChannelRequest *)request eventHandler:(void(^)(BOOL done, LNDCloseStatusUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"CloseChannel"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDCloseStatusUpdate class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
#pragma mark AbandonChannel(AbandonChannelRequest) returns (AbandonChannelResponse)

/**
 * * lncli: `abandonchannel`
 * AbandonChannel removes all channel state from the database except for a
 * close summary. This method can be used to get rid of permanently unusable
 * channels due to bugs fixed in newer versions of lnd. Only available
 * when in debug builds of lnd.
 */
- (void)abandonChannelWithRequest:(LNDAbandonChannelRequest *)request handler:(void(^)(LNDAbandonChannelResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToAbandonChannelWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `abandonchannel`
 * AbandonChannel removes all channel state from the database except for a
 * close summary. This method can be used to get rid of permanently unusable
 * channels due to bugs fixed in newer versions of lnd. Only available
 * when in debug builds of lnd.
 */
- (GRPCProtoCall *)RPCToAbandonChannelWithRequest:(LNDAbandonChannelRequest *)request handler:(void(^)(LNDAbandonChannelResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"AbandonChannel"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDAbandonChannelResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SendPayment(stream SendRequest) returns (stream SendResponse)

/**
 * * lncli: `sendpayment`
 * SendPayment dispatches a bi-directional streaming RPC for sending payments
 * through the Lightning Network. A single RPC invocation creates a persistent
 * bi-directional stream allowing clients to rapidly send payments through the
 * Lightning Network with a single persistent connection.
 */
- (void)sendPaymentWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, LNDSendResponse *_Nullable response, NSError *_Nullable error))eventHandler{
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
- (GRPCProtoCall *)RPCToSendPaymentWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, LNDSendResponse *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"SendPayment"
            requestsWriter:requestWriter
             responseClass:[LNDSendResponse class]
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
- (void)sendPaymentSyncWithRequest:(LNDSendRequest *)request handler:(void(^)(LNDSendResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToSendPaymentSyncWithRequest:(LNDSendRequest *)request handler:(void(^)(LNDSendResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SendPaymentSync"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDSendResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark SendToRoute(stream SendToRouteRequest) returns (stream SendResponse)

/**
 * * lncli: `sendtoroute`
 * SendToRoute is a bi-directional streaming RPC for sending payment through
 * the Lightning Network. This method differs from SendPayment in that it
 * allows users to specify a full route manually. This can be used for things
 * like rebalancing, and atomic swaps.
 */
- (void)sendToRouteWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, LNDSendResponse *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToSendToRouteWithRequestsWriter:requestWriter eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `sendtoroute`
 * SendToRoute is a bi-directional streaming RPC for sending payment through
 * the Lightning Network. This method differs from SendPayment in that it
 * allows users to specify a full route manually. This can be used for things
 * like rebalancing, and atomic swaps.
 */
- (GRPCProtoCall *)RPCToSendToRouteWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, LNDSendResponse *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"SendToRoute"
            requestsWriter:requestWriter
             responseClass:[LNDSendResponse class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
#pragma mark SendToRouteSync(SendToRouteRequest) returns (SendResponse)

/**
 * *
 * SendToRouteSync is a synchronous version of SendToRoute. It Will block
 * until the payment either fails or succeeds.
 */
- (void)sendToRouteSyncWithRequest:(LNDSendToRouteRequest *)request handler:(void(^)(LNDSendResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSendToRouteSyncWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * SendToRouteSync is a synchronous version of SendToRoute. It Will block
 * until the payment either fails or succeeds.
 */
- (GRPCProtoCall *)RPCToSendToRouteSyncWithRequest:(LNDSendToRouteRequest *)request handler:(void(^)(LNDSendResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SendToRouteSync"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDSendResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark AddInvoice(Invoice) returns (AddInvoiceResponse)

/**
 * * lncli: `addinvoice`
 * AddInvoice attempts to add a new invoice to the invoice database. Any
 * duplicated invoices are rejected, therefore all invoices *must* have a
 * unique payment preimage.
 */
- (void)addInvoiceWithRequest:(LNDInvoice *)request handler:(void(^)(LNDAddInvoiceResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToAddInvoiceWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `addinvoice`
 * AddInvoice attempts to add a new invoice to the invoice database. Any
 * duplicated invoices are rejected, therefore all invoices *must* have a
 * unique payment preimage.
 */
- (GRPCProtoCall *)RPCToAddInvoiceWithRequest:(LNDInvoice *)request handler:(void(^)(LNDAddInvoiceResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"AddInvoice"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDAddInvoiceResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
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
- (void)listInvoicesWithRequest:(LNDListInvoiceRequest *)request handler:(void(^)(LNDListInvoiceResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListInvoicesWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
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
- (GRPCProtoCall *)RPCToListInvoicesWithRequest:(LNDListInvoiceRequest *)request handler:(void(^)(LNDListInvoiceResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListInvoices"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDListInvoiceResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark LookupInvoice(PaymentHash) returns (Invoice)

/**
 * * lncli: `lookupinvoice`
 * LookupInvoice attempts to look up an invoice according to its payment hash.
 * The passed payment hash *must* be exactly 32 bytes, if not, an error is
 * returned.
 */
- (void)lookupInvoiceWithRequest:(LNDPaymentHash *)request handler:(void(^)(LNDInvoice *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToLookupInvoiceWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `lookupinvoice`
 * LookupInvoice attempts to look up an invoice according to its payment hash.
 * The passed payment hash *must* be exactly 32 bytes, if not, an error is
 * returned.
 */
- (GRPCProtoCall *)RPCToLookupInvoiceWithRequest:(LNDPaymentHash *)request handler:(void(^)(LNDInvoice *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"LookupInvoice"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDInvoice class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
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
- (void)subscribeInvoicesWithRequest:(LNDInvoiceSubscription *)request eventHandler:(void(^)(BOOL done, LNDInvoice *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToSubscribeInvoicesWithRequest:request eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
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
- (GRPCProtoCall *)RPCToSubscribeInvoicesWithRequest:(LNDInvoiceSubscription *)request eventHandler:(void(^)(BOOL done, LNDInvoice *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"SubscribeInvoices"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDInvoice class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
#pragma mark DecodePayReq(PayReqString) returns (PayReq)

/**
 * * lncli: `decodepayreq`
 * DecodePayReq takes an encoded payment request string and attempts to decode
 * it, returning a full description of the conditions encoded within the
 * payment request.
 */
- (void)decodePayReqWithRequest:(LNDPayReqString *)request handler:(void(^)(LNDPayReq *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDecodePayReqWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `decodepayreq`
 * DecodePayReq takes an encoded payment request string and attempts to decode
 * it, returning a full description of the conditions encoded within the
 * payment request.
 */
- (GRPCProtoCall *)RPCToDecodePayReqWithRequest:(LNDPayReqString *)request handler:(void(^)(LNDPayReq *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DecodePayReq"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDPayReq class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListPayments(ListPaymentsRequest) returns (ListPaymentsResponse)

/**
 * * lncli: `listpayments`
 * ListPayments returns a list of all outgoing payments.
 */
- (void)listPaymentsWithRequest:(LNDListPaymentsRequest *)request handler:(void(^)(LNDListPaymentsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListPaymentsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `listpayments`
 * ListPayments returns a list of all outgoing payments.
 */
- (GRPCProtoCall *)RPCToListPaymentsWithRequest:(LNDListPaymentsRequest *)request handler:(void(^)(LNDListPaymentsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListPayments"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDListPaymentsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DeleteAllPayments(DeleteAllPaymentsRequest) returns (DeleteAllPaymentsResponse)

/**
 * *
 * DeleteAllPayments deletes all outgoing payments from DB.
 */
- (void)deleteAllPaymentsWithRequest:(LNDDeleteAllPaymentsRequest *)request handler:(void(^)(LNDDeleteAllPaymentsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDeleteAllPaymentsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * *
 * DeleteAllPayments deletes all outgoing payments from DB.
 */
- (GRPCProtoCall *)RPCToDeleteAllPaymentsWithRequest:(LNDDeleteAllPaymentsRequest *)request handler:(void(^)(LNDDeleteAllPaymentsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DeleteAllPayments"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDDeleteAllPaymentsResponse class]
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
- (void)describeGraphWithRequest:(LNDChannelGraphRequest *)request handler:(void(^)(LNDChannelGraph *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToDescribeGraphWithRequest:(LNDChannelGraphRequest *)request handler:(void(^)(LNDChannelGraph *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DescribeGraph"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDChannelGraph class]
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
- (void)getChanInfoWithRequest:(LNDChanInfoRequest *)request handler:(void(^)(LNDChannelEdge *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToGetChanInfoWithRequest:(LNDChanInfoRequest *)request handler:(void(^)(LNDChannelEdge *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetChanInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDChannelEdge class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetNodeInfo(NodeInfoRequest) returns (NodeInfo)

/**
 * * lncli: `getnodeinfo`
 * GetNodeInfo returns the latest advertised, aggregated, and authenticated
 * channel information for the specified node identified by its public key.
 */
- (void)getNodeInfoWithRequest:(LNDNodeInfoRequest *)request handler:(void(^)(LNDNodeInfo *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetNodeInfoWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `getnodeinfo`
 * GetNodeInfo returns the latest advertised, aggregated, and authenticated
 * channel information for the specified node identified by its public key.
 */
- (GRPCProtoCall *)RPCToGetNodeInfoWithRequest:(LNDNodeInfoRequest *)request handler:(void(^)(LNDNodeInfo *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetNodeInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDNodeInfo class]
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
- (void)queryRoutesWithRequest:(LNDQueryRoutesRequest *)request handler:(void(^)(LNDQueryRoutesResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToQueryRoutesWithRequest:(LNDQueryRoutesRequest *)request handler:(void(^)(LNDQueryRoutesResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"QueryRoutes"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDQueryRoutesResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark GetNetworkInfo(NetworkInfoRequest) returns (NetworkInfo)

/**
 * * lncli: `getnetworkinfo`
 * GetNetworkInfo returns some basic stats about the known channel graph from
 * the point of view of the node.
 */
- (void)getNetworkInfoWithRequest:(LNDNetworkInfoRequest *)request handler:(void(^)(LNDNetworkInfo *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetNetworkInfoWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `getnetworkinfo`
 * GetNetworkInfo returns some basic stats about the known channel graph from
 * the point of view of the node.
 */
- (GRPCProtoCall *)RPCToGetNetworkInfoWithRequest:(LNDNetworkInfoRequest *)request handler:(void(^)(LNDNetworkInfo *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetNetworkInfo"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDNetworkInfo class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark StopDaemon(StopRequest) returns (StopResponse)

/**
 * * lncli: `stop`
 * StopDaemon will send a shutdown request to the interrupt handler, triggering
 * a graceful shutdown of the daemon.
 */
- (void)stopDaemonWithRequest:(LNDStopRequest *)request handler:(void(^)(LNDStopResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToStopDaemonWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `stop`
 * StopDaemon will send a shutdown request to the interrupt handler, triggering
 * a graceful shutdown of the daemon.
 */
- (GRPCProtoCall *)RPCToStopDaemonWithRequest:(LNDStopRequest *)request handler:(void(^)(LNDStopResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"StopDaemon"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDStopResponse class]
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
- (void)subscribeChannelGraphWithRequest:(LNDGraphTopologySubscription *)request eventHandler:(void(^)(BOOL done, LNDGraphTopologyUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
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
- (GRPCProtoCall *)RPCToSubscribeChannelGraphWithRequest:(LNDGraphTopologySubscription *)request eventHandler:(void(^)(BOOL done, LNDGraphTopologyUpdate *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"SubscribeChannelGraph"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDGraphTopologyUpdate class]
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
- (void)debugLevelWithRequest:(LNDDebugLevelRequest *)request handler:(void(^)(LNDDebugLevelResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToDebugLevelWithRequest:(LNDDebugLevelRequest *)request handler:(void(^)(LNDDebugLevelResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DebugLevel"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDDebugLevelResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark FeeReport(FeeReportRequest) returns (FeeReportResponse)

/**
 * * lncli: `feereport`
 * FeeReport allows the caller to obtain a report detailing the current fee
 * schedule enforced by the node globally for each channel.
 */
- (void)feeReportWithRequest:(LNDFeeReportRequest *)request handler:(void(^)(LNDFeeReportResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToFeeReportWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `feereport`
 * FeeReport allows the caller to obtain a report detailing the current fee
 * schedule enforced by the node globally for each channel.
 */
- (GRPCProtoCall *)RPCToFeeReportWithRequest:(LNDFeeReportRequest *)request handler:(void(^)(LNDFeeReportResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"FeeReport"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDFeeReportResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark UpdateChannelPolicy(PolicyUpdateRequest) returns (PolicyUpdateResponse)

/**
 * * lncli: `updatechanpolicy`
 * UpdateChannelPolicy allows the caller to update the fee schedule and
 * channel policies for all channels globally, or a particular channel.
 */
- (void)updateChannelPolicyWithRequest:(LNDPolicyUpdateRequest *)request handler:(void(^)(LNDPolicyUpdateResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToUpdateChannelPolicyWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * * lncli: `updatechanpolicy`
 * UpdateChannelPolicy allows the caller to update the fee schedule and
 * channel policies for all channels globally, or a particular channel.
 */
- (GRPCProtoCall *)RPCToUpdateChannelPolicyWithRequest:(LNDPolicyUpdateRequest *)request handler:(void(^)(LNDPolicyUpdateResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"UpdateChannelPolicy"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDPolicyUpdateResponse class]
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
- (void)forwardingHistoryWithRequest:(LNDForwardingHistoryRequest *)request handler:(void(^)(LNDForwardingHistoryResponse *_Nullable response, NSError *_Nullable error))handler{
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
- (GRPCProtoCall *)RPCToForwardingHistoryWithRequest:(LNDForwardingHistoryRequest *)request handler:(void(^)(LNDForwardingHistoryResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ForwardingHistory"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[LNDForwardingHistoryResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
#endif
