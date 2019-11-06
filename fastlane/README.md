fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### switch_mainnet
```
fastlane switch_mainnet
```

### update_app_icon
```
fastlane update_app_icon
```
Generate new app icon assets.
### tests
```
fastlane tests
```
Run all tests.
### screenshots
```
fastlane screenshots
```

### upload_screenshots
```
fastlane upload_screenshots
```

### upload_metadata
```
fastlane upload_metadata
```

### clean
```
fastlane clean
```

### mainnet
```
fastlane mainnet
```

### testnet
```
fastlane testnet
```
Builds new Alpha Build with local lnd enabled and uploads it to Testflight.
### release
```
fastlane release
```
Release

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
