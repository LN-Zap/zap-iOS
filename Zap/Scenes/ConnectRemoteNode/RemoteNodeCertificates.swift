//
//  Zap
//
//  Created by Otto Suess on 19.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

struct RemoteNodeCertificates: Codable {
    let certificate: String
    let macaron: Data
    
    // TODO: remove
    static let debug = RemoteNodeCertificates(json: "{\"c\":\"-----BEGIN CERTIFICATE-----\\nMIICtjCCAlygAwIBAgIRAIMgQ2JA+sz7SwXIzg8W4Y0wCgYIKoZIzj0EAwIwRzEf\\nMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEkMCIGA1UEAxMbSnVzdHVz\\ncy1NYWNCb29rLVByby0zLmxvY2FsMB4XDTE4MDQwMzEzMDYzM1oXDTE5MDUyOTEz\\nMDYzM1owRzEfMB0GA1UEChMWbG5kIGF1dG9nZW5lcmF0ZWQgY2VydDEkMCIGA1UE\\nAxMbSnVzdHVzcy1NYWNCb29rLVByby0zLmxvY2FsMFkwEwYHKoZIzj0CAQYIKoZI\\nzj0DAQcDQgAESaP24plHtqLH8NeHJ+Y2fnddFsUo9RjzxBrmXsYp2nEO0+WQhkpZ\\nQo+eyFjwfjLjQHKeRyMV4Clq6HKVXZThkKOCAScwggEjMA4GA1UdDwEB/wQEAwIC\\npDAPBgNVHRMBAf8EBTADAQH/MIH/BgNVHREEgfcwgfSCG0p1c3R1c3MtTWFjQm9v\\nay1Qcm8tMy5sb2NhbIIJbG9jYWxob3N0hwR/AAABhxAAAAAAAAAAAAAAAAAAAAAB\\nhxD+gAAAAAAAAAAAAAAAAAABhxD+gAAAAAAAAASqO3gABjMBhwTAqAEHhxD+gAAA\\nAAAAADQ4s//+Kr58hxD+gAAAAAAAAPDyZvVGoLMJhxD+gAAAAAAAABjWUXq+hnbV\\nhxD+gAAAAAAAAApCb0MKLuWghwQKCwAEhxD+gAAAAAAAAG6Wz//+3atFhxD92tDQ\\nyv4RlwAAAAAAABAChxD+gAAAAAAAABx1+uuryOcKhwSp/rqpMAoGCCqGSM49BAMC\\nA0gAMEUCIQCnjoUE09Mdj6pxBIgpkFvD9pn3FJP5ekXzDlsnxXmZUgIgURUuQ2R8\\nV+Kn2IRcnBIHRjphdDcmnx1CWnlpgF4rFtc=\\n-----END CERTIFICATE-----\\n\",\"m\":\"AgEDbG5kArsBAwoQVIs+mZybye1Az0iBLy7eUxIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaFgoHbWVzc2FnZRIEcmVhZBIFd3JpdGUaFwoIb2ZmY2hhaW4SBHJlYWQSBXdyaXRlGhYKB29uY2hhaW4SBHJlYWQSBXdyaXRlGhQKBXBlZXJzEgRyZWFkEgV3cml0ZQAABiAxBdYHCdnkc+l09M/YGegFskYBZzDVO351dgxw6JjnAA==\"}")
    
    enum CodingKeys: String, CodingKey {
        case certificate = "c"
        case macaron = "m"
    }
    
    init?(json: String) {
        guard
            let data = json.data(using: .utf8),
            let remoteNodeCertificates = try? JSONDecoder().decode(RemoteNodeCertificates.self, from: data)
            else { return nil }
        self = remoteNodeCertificates
    }
}
