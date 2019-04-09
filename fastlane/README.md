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
### build_number
```
fastlane build_number
```
Update build number.
### change_version
```
fastlane change_version
```
Update app version.
### alpha
```
fastlane alpha
```
Builds new Alpha Build and uploads it to Testflight.
### local_lnd_alpha
```
fastlane local_lnd_alpha
```
Builds new Alpha Build with local lnd enabled and uploads it to Testflight.
### release
```
fastlane release
```
Release
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


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
