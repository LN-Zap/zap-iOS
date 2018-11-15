# Zap connect URL

Zap-iOS can open URLs with the scheme `zap:` to directly connect to remote nodes.

### Syntax

```
zap:<URL encoded base64 DER certifcate>?macaroon=<URL encoded base64 macaroon>&ip=<ip>:<port>
```

### Javascript reference implementation

```javascript
// open tls.cert file
var certFile = fs.readFileSync(os.homedir() + '/.lnd/tls.cert', 'utf8');

// remove '-----BEGIN CERTIFICATE-----', '-----END CERTIFICATE-----' and line breaks
var lines = certFile.split(/\n/);
lines = lines.filter(line => line != "");
lines.pop();
lines.shift();
var cert = lines.join('');

// open macaroon file in base64 encoding
var macaroonPath = os.homedir() + '/.lnd/data/chain/bitcoin/testnet/admin.macaroon'
var macaroonData = fs.readFileSync(macaroonPath);
var macaroon = new Buffer(macaroonData).toString('base64');

var url = 'zap:' + encodeURIComponent(cert) + '?macaroon=' + encodeURIComponent(macaroon) + '&ip=' + ip.address() + ':10009'
```

## Example:

### Certificate

```
-----BEGIN CERTIFICATE-----
MIICiDCCAi+gAwIBAgIQdo5v0QBXHnji4hRaeeMjNDAKBggqhkjOPQQDAjBHMR8w
HQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MSQwIgYDVQQDExtKdXN0dXNz
LU1hY0Jvb2stUHJvLTMubG9jYWwwHhcNMTgwODIzMDU1ODEwWhcNMTkxMDE4MDU1
ODEwWjBHMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MSQwIgYDVQQD
ExtKdXN0dXNzLU1hY0Jvb2stUHJvLTMubG9jYWwwWTATBgcqhkjOPQIBBggqhkiO
PQMBBwNCAASFhRm+w/T10PoKtg4lm9hBNJjJD473fkzHwPUFwy91vTrQSf7543j2
JrgFo8mbTV0VtpgqkfK1IMVKMLrF21xio4H8MIH5MA4GA1UdDwEB/wQEAwICpDAP
BgNVHRMBAf8EBTADAQH/MIHVBgNVHREEgc0wgcqCG0p1c3R1c3MtTWFjQm9vay1Q
cm8tMy5sb2NhbIIJbG9jYWxob3N0ggR1bml4ggp1bml4cGFja2V0hwR/AAABhxAA
AAAAAAAAAAAAAAAAAAABhxD+gAAAAAAAAAAAAAAAAAABhxD+gAAAAAAAAAwlc9Zc
k7bDhwTAqAEEhxD+gAAAAAAAABiNp//+GxXGhxD+gAAAAAAAAKWJ5tliDORjhwQK
DwAChxD+gAAAAAAAAG6Wz//+3atFhxD92tDQyv4TAQAAAAAAABAAMAoGCCqGSM49
BAMCA0cAMEQCIA9O9xtazmdxCKj0MfbFHVBq5I7JMnOFPpwRPJXQfrYaAiBd5NyJ
QCwlSx5ECnPOH5sRpv26T8aUcXbmynx9CoDufA==
-----END CERTIFICATE-----
```

### Macaroon (base64)

```
AgEDbG5kArsBAwoQ3/I9f6kgSE6aUPd85lWpOBIBMBoWCgdhZGRyZXNzEgRyZWFk
EgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV32ml0ZRoXCghpbnZvaWNlcxIEcmVhZBIF
d3JpdGUaFgoHbWVzc2FnZRIEcmVhZBIFd3JpdGUaFwoIb2ZmY2hhaW4SBHJlYWQS
BXdyaXRlGhYKB29uY2hhaW4SBHJlYWQSBXdyaXRlGhQKBXBlZXJzEgRyZWFkEgV3
cml0ZQAABiAiUTBv3Eh6iDbdjmXCfNxp4HBEcOYNzXhrm+ncLHf5jA==
```

### Node URL

```
192.168.1.4:10009
```

### Zap connect URL

```
zap:MIICiDCCAi%2BgAwIBAgIQdo5v0QBXHnji4hRaeeMjNDAKBggqhkjOPQQDAjBHMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MSQwIgYDVQQDExtKdXN0dXNzLU1hY0Jvb2stUHJvLTMubG9jYWwwHhcNMTgwODIzMDU1ODEwWhcNMTkxMDE4MDU1ODEwWjBHMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MSQwIgYDVQQDExtKdXN0dXNzLU1hY0Jvb2stUHJvLTMubG9jYWwwWTATBgcqhkjOPQIBBggqhkiOPQMBBwNCAASFhRm%2Bw%2FT10PoKtg4lm9hBNJjJD473fkzHwPUFwy91vTrQSf7543j2JrgFo8mbTV0VtpgqkfK1IMVKMLrF21xio4H8MIH5MA4GA1UdDwEB%2FwQEAwICpDAPBgNVHRMBAf8EBTADAQH%2FMIHVBgNVHREEgc0wgcqCG0p1c3R1c3MtTWFjQm9vay1Qcm8tMy5sb2NhbIIJbG9jYWxob3N0ggR1bml4ggp1bml4cGFja2V0hwR%2FAAABhxAAAAAAAAAAAAAAAAAAAAABhxD%2BgAAAAAAAAAAAAAAAAAABhxD%2BgAAAAAAAAAwlc9Zck7bDhwTAqAEEhxD%2BgAAAAAAAABiNp%2F%2F%2BGxXGhxD%2BgAAAAAAAAKWJ5tliDORjhwQKDwAChxD%2BgAAAAAAAAG6Wz%2F%2F%2B3atFhxD92tDQyv4TAQAAAAAAABAAMAoGCCqGSM49BAMCA0cAMEQCIA9O9xtazmdxCKj0MfbFHVBq5I7JMnOFPpwRPJXQfrYaAiBd5NyJQCwlSx5ECnPOH5sRpv26T8aUcXbmynx9CoDufA%3D%3D?macaroon=AgEDbG5kArsBAwoQ3%2FI9f6kgSE6aUPd85lWpOBIBMBoWCgdhZGRyZXNzEgRyZWFkEgV32ml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaFgoHbWVzc2FnZRIEcmVhZBIFd3JpdGUaFwoIb2ZmY2hhaW4SBHJlYWQSBXdyaXRlGhYKB29uY2hhaW4SBHJlYWQSBXdyaXRlGhQKBXBlZXJzEgRyZWFkEgV3cml0ZQAABiAiUTBv3Eh6iDbdjmXCfNxp4HBEcOYNzXhrm%2BncLHf5jA%3D%3D&ip=192.168.1.4:10009
```
