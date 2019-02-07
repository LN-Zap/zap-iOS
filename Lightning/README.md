# Lightning

Everything needed to communicate with the lightning network goes here.

- Certificates - The app uses certificate pinning for security reasons. Related code and certificates are here.
- Invoices - Bolt11 & Lightning Invoice URI
- QRCodes - All lightning related QRCodes (zapconnect, BTCPay)
- Services - A service layer on top of the lnd APIs to simplify communication.
- SQLite - lnd's data is persisted inside of the app. You can find everything related here.
- Tests
