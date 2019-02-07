read -r -d '' VAR << EOM
[1] lndconnect:
[2] testnet lightning:
[3] testnet lightning://
[4] mainnet lightning:
[5] mainnet lightning:
[6] testnet bitcoin:
[7] testnet bitcoin:?amount
[8] testnet bitcoin:?amount&message&label&extra
[9] mainnet bitcoin:
[9] broken bitcoin:
[-] broken lightning
?: 
EOM

read -n1 -p "$VAR" doit
echo ""
case $doit in
	1) xcrun simctl openurl booted "lndconnect://192.168.1.3:10009?cert=MIIB4TCCAYegAwIBAgIQHqrjLih4yUh9O3JEQP9yMDAKBggqhkjOPQQDAjAvMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MQwwCgYDVQQDEwNidGMwHhcNMTgwNTIwMDc0NTM2WhcNMTkwNzE1MDc0NTM2WjAvMR8wHQYDVQQKExZsbmQgYXV0b2dlbmVyYXRlZCBjZXJ0MQwwCgYDVQQDEwNidGMwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQuAr_fxRrAiHAs7DglavwBxOn9fq6rVc4cDTVX5ePYg3asbCUqxHhOY4NYjBwbAVZYvHgacVw4orCE1K1-F2qio4GEMIGBMA4GA1UdDwEB_wQEAwICpDAPBgNVHRMBAf8EBTADAQH_MF4GA1UdEQRXMFWCA2J0Y4IJbG9jYWxob3N0gg1sbmQzLmRkbnMubmV0hwR_AAABhxAAAAAAAAAAAAAAAAAAAAABhwTAqAEDhwSsEQABhxD-gAAAAAAAAJbGkf_-EwtIMAoGCCqGSM49BAMCA0gAMEUCIQDVIciJeyQR6DZRiSM0P5E2L7fPAvmgE-b2g0TLHP1GlQIgYISBx2KjGb2jNMEWYPnDPv141s1QY86Jyrxyi4jG1ik&macaroon=AgEDbG5kArsBAwoQzvTBLW9FqXNXwEGGRUTvAhIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaFgoHbWVzc2FnZRIEcmVhZBIFd3JpdGUaFwoIb2ZmY2hhaW4SBHJlYWQSBXdyaXRlGhYKB29uY2hhaW4SBHJlYWQSBXdyaXRlGhQKBXBlZXJzEgRyZWFkEgV3cml0ZQAABiCbmI8o9ai7DRbPV9fC57I-lOjYop5ZZrZhalxCMuujrA" ;;
	2) xcrun simctl openurl booted "lightning:lntb1500n1pd39k9vpp5ej3fcze4s03gx27wm9n4wyxeewcz95lhv2h9ffry56h9wpx9pfsqdqdg9jxgg8sn7vtzcqzysylsxanlu23sp59xh045w6dmlc3j7wyug9ksex6anwwyvj3q6atr4hevl9a4kv720v26er8ejvakcqexrj4wel08yws7twr2ea306h6sq8gm2vz" ;;
	3) xcrun simctl openurl booted "lightning://lntb1500n1pd39k9vpp5ej3fcze4s03gx27wm9n4wyxeewcz95lhv2h9ffry56h9wpx9pfsqdqdg9jxgg8sn7vtzcqzysylsxanlu23sp59xh045w6dmlc3j7wyug9ksex6anwwyvj3q6atr4hevl9a4kv720v26er8ejvakcqexrj4wel08yws7twr2ea306h6sq8gm2vz" ;;
	4) xcrun simctl openurl booted "lightning:lnbc1pvjluezpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqdpl2pkx2ctnv5sxxmmwwd5kgetjypeh2ursdae8g6twvus8g6rfwvs8qun0dfjkxaq8rkx3yf5tcsyz3d73gafnh3cax9rn449d9p5uxz9ezhhypd0elx87sjle52x86fux2ypatgddc6k63n7erqz25le42c4u4ecky03ylcqca784w" ;;
	5) xcrun simctl openurl booted "lightning:lnbc10u1pdn7e0dpp5s3u20axy93zqmjwe6dgtgcvhkvqf82h9ys7cf2f5zrkvgcm06u6sdqlf35kw6r5de5kueeq2dcxjm3q95sry7qcqzys256juhvwdusyeyn2pp7f0vr5f5x2snw72uu3kyjhe2yy2ddcg9gp8et2nnte3670dr9hn59f9fs3uezjztcj9gzvawws4j0hp8sw46gpc6jawk" ;;
	6) xcrun simctl openurl booted "bitcoin:2N8hwP1WmJrFF5QWABn38y63uYLhnJYJYTF" ;;
	7) xcrun simctl openurl booted "bitcoin://2N8hwP1WmJrFF5QWABn38y63uYLhnJYJYTF?amount=1.2" ;;
	8) xcrun simctl openurl booted "bitcoin:2N8hwP1WmJrFF5QWABn38y63uYLhnJYJYTF?amount=1.2&message=Payment&label=Satoshi&extra=other-param" ;;
	9) xcrun simctl openurl booted "bitcoin:1JPPQtrRwW84uNpWN5xWgAP6NneRyumRjS" ;;
	0) xcrun simctl openurl booted "bitcoin:abc" ;;
	-) xcrun simctl openurl booted "lightning:lntb1500n1pd39k96atr4hevl9a4kv720v26er8ejvakcqexrj4wel08yws7twr2ea306h6sq8gm2vz" ;;
	*) echo invalid input ;;
esac
