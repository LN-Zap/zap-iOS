[![Build Status](https://travis-ci.org/LN-Zap/zap-iOS.svg?branch=master)](https://travis-ci.org/LN-Zap/zap-iOS)
[![GitHub license](https://img.shields.io/github/license/LN-Zap/zap-iOS.svg)](LICENSE)
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/zap-ios/localized.svg)](https://crowdin.com/project/zap-ios)
[![codecov](https://codecov.io/gh/LN-Zap/zap-iOS/branch/master/graph/badge.svg)](https://codecov.io/gh/LN-Zap/zap-iOS)

# Zap iOS

<p align='center'>
  <a href='https://zap.jackmallers.com'>
    <img src='https://raw.githubusercontent.com/LN-Zap/zap-iOS/master/docs/screenshot.png' height='450' alt='screenshot' />
  </a>
</p>

### [Download the alpha 🔥](https://testflight.apple.com/join/P32C380R)

Zap is a free Lightning Network wallet focused on user experience and ease of use, with the overall goal of helping the cryptocurrency community scale Bitcoin and other cryptocurrencies.

We have an active [slack][slack] channel where you can join the discussion on development, design and product.

## Features

**Wallet**
- [x] Fiat currency prices
- [x] Support for Bech32 and P2SH addresses
- [x] BTC, mBTC, bit & Satoshi units
- [x] Open `lightning:` & `bitcoin:` urls
- [x] Available in many languages
- [x] Resend failed lightning transactions
- [x] Transaction filter
- [x] BIP39 passphrase

**Security**
- [x] PIN protected access
- [x] Certificate pinning

**Lightning**
- [x] Channel Management
- [x] Connect to remote Lnd node
- [x] Connect to BTCPay Server
- [x] Connect to Zapconnect QR code
- [ ] Run lnd on your iPhone

## Security

If you discover or learn about a potential error, weakness, or threat that can compromise the security of Zap, we ask you to keep it confidential and [submit your concern directly to the Zap security team](mailto:jimmymowschess@gmail.com?subject=[GitHub]%20Zap%20Security).

## Get Help

If you are having problems with Zap, please report the issue in [GitHub][issues] or on [slack][slack] with screenshots and/or how to reproduce the bug/error.

A good product not only has good software tests but also checks the quality of the UX/UI. Putting ourselves in the shoes of a user is a very important design principle of Zap.

## Contribute

Hey! Do you like Zap? Awesome! We could actually really use your help!

Open source isn't just writing code. Zap could use your help with any of the following:

- Finding (and reporting!) bugs
- [Help translating the app](https://crowdin.com/project/zap-ios)
- New feature suggestions
- Answering questions on issues
- Documentation improvements
- Reviewing pull requests
- Helping to manage issue priorities
- Fixing bugs/new features

If any of that sounds cool to you, feel free to dive in! [Open an issue][issues] or submit a pull request.

If you would like to help contribute to the project, please see the [Contributing Guide](docs/CONTRIBUTING.md)

## Maintainers

- [Otto Suess (@ottosuess)](https://github.com/ottosuess)

## License

This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. See [LICENSE](LICENSE) for more information.

[MIT](LICENSE) © Jack Mallers

[issues]: https://github.com/LN-Zap/zap-iOS/issues
[slack]: https://join.slack.com/t/zaphq/shared_invite/enQtMzgyNDA2NDI2Nzg0LTQwZWQ2ZWEzOWFhMjRiNWZkZWMwYTA4MzA5NzhjMDNhNTM5YzliNDA4MmZkZWZkZTFmODM4ODJkYzU3YmI3ZmI
