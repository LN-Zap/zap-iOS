//
//  SwiftLnd
//
//  Created by Otto Suess on 15.11.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import LndRpc
import Logger

public struct Macaroon: Equatable, Codable {
    private let data: Data
    public let permissions: Permissions
    
    public init(from decoder: Decoder) throws {
        data = try Data(from: decoder)
        permissions = Macaroon.decodePermissions(from: data)
    }
    
    public func encode(to encoder: Encoder) throws {
        try data.encode(to: encoder)
    }

    public init?(base64String: String) {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        self.init(data: data)
    }
    
    public init?(hexadecimalString: String) {
        guard let data = Data(hexadecimalString: hexadecimalString) else { return nil }
        self.init(data: data)
    }

    public init(data: Data) {
        self.data = data
        permissions = Macaroon.decodePermissions(from: data)
    }
    
    // The v2 binary format of a macaroon is as follows. All entries other than the
    // version are packets as parsed by parsePacketV2.
    //
    // version [1 byte]
    // location?
    // identifier
    // eos
    // (
    //    location?
    //    identifier
    //    verificationId?
    //    eos
    // )*
    // eos
    // signature
    //
    // See also https://github.com/rescrv/libmacaroons/blob/master/doc/format.txt
    //
    // Proto file for the MacaroonId: https://github.com/go-macaroon-bakery/macaroon-bakery/blob/v2.1.0/bakery/internal/macaroonpb/id.proto
    private static func decodePermissions(from data: Data) -> Permissions {
        var data = data.dropFirst()
        guard let (firstSection, remainingData) = Macaroon.parseSection(data: data) else { return Permissions(permissions: [:]) }
        var section = firstSection
        data = remainingData
        
        if !section.isEmpty && section[0].type == .location,
            section[0].data != nil {
            section = Array(section.dropFirst())
        }
        
        guard
            section.count == 1 && section[0].type == .identifier, // valid macaroon header
            let id = section[0].data,
            let decoded = try? MacaroonId(data: id.dropFirst())
            else { return Permissions(permissions: [:]) }
        
        var permissions = [Permissions.Domain: Permissions.AccessMode]()
        
        for operation in decoded.opsArray {
            guard let operation = operation as? Op else { continue }
            guard let domain = Permissions.Domain(rawValue: operation.entity) else {
                Logger.warn("⚠️ unknown macaroon id entity: \(operation)")
                continue
            }
            
            let accessMode = Permissions.AccessMode(operation.actionsArray.compactMap {
                guard let action = $0 as? String else { return nil }
                return Permissions.AccessMode.fromString(action)
            })
            permissions[domain] = accessMode
        }
        
        return Permissions(permissions: permissions)
    }
    
    // parseSectionV2 parses a sequence of packets in data. The sequence is
    // terminated by a packet with a field type of fieldEOS.
    private static func parseSection(data: Data) -> ([Packet], Data)? {
        var prevFieldType = -1
        var data = data
        var packets = [Packet]()
        
        while true {
            guard
                !data.isEmpty, // section extends past end of buffer
                let (packet, rest) = Packet.parse(data: data)
                else { return nil }
            
            if packet.type == .eos {
                return (packets, rest)
            }
            
            guard packet.type.rawValue > prevFieldType else { return nil } // fields out of order
            
            packets.append(packet)
            
            prevFieldType = packet.type.rawValue
            data = rest
        }
    }
    
    public static func == (lhs: Macaroon, rhs: Macaroon) -> Bool {
        return lhs.data == rhs.data
    }
    
    public var hexadecimalString: String {
        return data.hexadecimalString
    }

}

private struct Packet {
    fileprivate enum FieldType: Int {
        case eos = 0
        case location = 1
        case identifier = 2
        case verificationId = 4
        case signature = 6
    }
    
    var type: FieldType
    var data: Data?
    
    // parsePacketV2 parses a V2 data package at the start of the given data.
    // The format of a packet is as follows:
    //    fieldType(varint) payloadLen(varint) data[payloadLen bytes]
    // apart from fieldEOS which has no payloadLen or data (it's  a single zero
    // byte).
    static func parse(data: Data) -> (Packet, Data)? {
        guard
            let (data, rawType) = parseVarInt(data: data),
            let type = Packet.FieldType(rawValue: Int(rawType))
            else { return nil }
        
        if type == .eos {
            let packet = Packet(type: type, data: nil)
            return (packet, data)
        }
        
        guard let (remainingData, payloadLen) = parseVarInt(data: data) else { return nil }
        
        guard payloadLen <= remainingData.count else { return nil } // field data extends past end of buffer
        
        let packetEndIndex = remainingData.startIndex.advanced(by: Int(payloadLen))
        let packetData = remainingData[remainingData.startIndex..<packetEndIndex]
        let packet = Packet(type: type, data: packetData)
        
        return (packet, remainingData[packetEndIndex...])
    }
}

// parseVarint parses the variable-length integer at the start of the given
// data and returns rest of the buffer and the number.
private func parseVarInt(data: Data) -> (Data, UInt)? {
    let (value, count) = uVarInt(data: data)
    guard count > 0, value < 0x7fffffff else { return nil } // swiftlint:disable:this empty_count
    
    let dataSlice = data[data.startIndex.advanced(by: count)...]
    return (dataSlice, value)
}

// Uvarint decodes a uint64 from buf and returns that value and the
// number of bytes read (> 0). If an error occurred, the value is 0
// and the number of bytes n is <= 0 meaning:
//
//     n == 0: buf too small
//     n  < 0: value larger than 64 bits (overflow)
//             and -n is the number of bytes read
//
private func uVarInt(data: Data) -> (UInt, Int) {
    var result = UInt(0)
    var bitCount = 0
    
    for (index, byte) in data.enumerated() {
        if byte < 0x80 {
            if index > 9 || index == 9 && byte > 1 {
                return (0, -(index + 1)) // overflow
            }
            return (result | UInt(byte) << bitCount, index + 1)
        }
        result |= UInt(byte & 0x7f) << bitCount
        bitCount += 7
    }
    return (0, 0)
}
