// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable trailing_newline

// MARK: Channel CustomDebugStringConvertible
extension Channel: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		Channel:
		\tblockHeight: \(String(describing: blockHeight))
		\tstate: \(state)
		\tlocalBalance: \(localBalance)
		\tremoteBalance: \(remoteBalance)
		\tremotePubKey: \(remotePubKey)
		\tcapacity: \(capacity)
		\tupdateCount: \(String(describing: updateCount))
		\tchannelPoint: \(channelPoint)
		\tcsvDelay: \(csvDelay)\n
		"""
	}
}

// MARK: ChannelCloseSummary CustomDebugStringConvertible
extension ChannelCloseSummary: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		ChannelCloseSummary:
		\tclosingTxHash: \(closingTxHash)
		\tchannelPoint: \(channelPoint)
		\tremotePubKey: \(remotePubKey)
		\tcloseType: \(closeType)
		\tcloseHeight: \(closeHeight)
		\topenHeight: \(openHeight)\n
		"""
	}
}

// MARK: ChannelPoint CustomDebugStringConvertible
extension ChannelPoint: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		ChannelPoint:
		\tfundingTxid: \(fundingTxid)
		\toutputIndex: \(outputIndex)\n
		"""
	}
}

// MARK: GraphTopologyUpdate CustomDebugStringConvertible
extension GraphTopologyUpdate: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		GraphTopologyUpdate:
		\tnodeUpdates: \(nodeUpdates)
		\tchannelUpdates: \(channelUpdates)
		\tclosedChannelUpdates: \(closedChannelUpdates)\n
		"""
	}
}

// MARK: Info CustomDebugStringConvertible
extension Info: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		Info:
		\talias: \(alias)
		\tblockHeight: \(blockHeight)
		\tisSyncedToChain: \(isSyncedToChain)
		\tnetwork: \(network)
		\tpubKey: \(pubKey)
		\tactiveChannelCount: \(activeChannelCount)
		\tbestHeaderDate: \(bestHeaderDate)
		\turis: \(uris)
		\tversion: \(version)\n
		"""
	}
}

// MARK: Invoice CustomDebugStringConvertible
extension Invoice: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		Invoice:
		\tid: \(id)
		\tmemo: \(memo)
		\tamount: \(amount)
		\tstate: \(state)
		\tdate: \(date)
		\tsettleDate: \(String(describing: settleDate))
		\texpiry: \(expiry)
		\tpaymentRequest: \(paymentRequest)\n
		"""
	}
}

// MARK: LightningNode CustomDebugStringConvertible
extension LightningNode: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		LightningNode:
		\tlastUpdate: \(String(describing: lastUpdate))
		\tpubKey: \(pubKey)
		\talias: \(String(describing: alias))
		\tcolor: \(String(describing: color))\n
		"""
	}
}

// MARK: NodeInfo CustomDebugStringConvertible
extension NodeInfo: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		NodeInfo:
		\tnode: \(node)
		\tnumChannels: \(numChannels)
		\ttotalCapacity: \(totalCapacity)\n
		"""
	}
}

// MARK: Payment CustomDebugStringConvertible
extension Payment: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		Payment:
		\tid: \(id)
		\tamount: \(amount)
		\tdate: \(date)
		\tfees: \(fees)
		\tpaymentHash: \(paymentHash)
		\tdestination: \(destination)\n
		"""
	}
}

// MARK: PaymentRequest CustomDebugStringConvertible
extension PaymentRequest: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		PaymentRequest:
		\tpaymentHash: \(paymentHash)
		\tdestination: \(destination)
		\tamount: \(amount)
		\tmemo: \(String(describing: memo))
		\tdate: \(date)
		\texpiryDate: \(expiryDate)
		\traw: \(raw)
		\tfallbackAddress: \(String(describing: fallbackAddress))
		\tnetwork: \(network)\n
		"""
	}
}

// MARK: Peer CustomDebugStringConvertible
extension Peer: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		Peer:
		\tpubKey: \(pubKey)
		\thost: \(host)\n
		"""
	}
}

// MARK: Route CustomDebugStringConvertible
extension Route: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		Route:
		\ttotalFees: \(totalFees)
		\ttotalAmount: \(totalAmount)\n
		"""
	}
}

// MARK: Success CustomDebugStringConvertible
extension Success: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		Success:
		\n
		"""
	}
}

// MARK: Transaction CustomDebugStringConvertible
extension Transaction: CustomDebugStringConvertible {
	public var debugDescription: String {
		return """
		Transaction:
		\tid: \(id)
		\tamount: \(amount)
		\tdate: \(date)
		\tfees: \(String(describing: fees))
		\tdestinationAddresses: \(destinationAddresses)
		\tblockHeight: \(String(describing: blockHeight))\n
		"""
	}
}

