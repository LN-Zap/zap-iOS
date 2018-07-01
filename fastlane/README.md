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
### s3_beta
```
fastlane s3_beta
```
Builds new Beta Build and uploads it to S3.
### beta
```
fastlane beta
```

### udid
```
fastlane udid
```
Add a new UDID to developer portal and update adhoc provisioning profile.
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

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
