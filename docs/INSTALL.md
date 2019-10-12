# Installation

### Preliminaries

Xcode 10.1 or above is required to run the app.

### Steps

1) Run `./setup.sh` to download the required frameworks.

2) Run `bundle exec pod install` to install dependencies located in the `Podfile`. This command guarantees that the version of CocoaPods specified in the `Gemfile.lock` is used to `pod install` the dependencies listed in the `Podfile.lock`.

3) That's it! Make sure to open `Zap.xcworkspace` rather than `Zap.xcodeproj` so you're using the Xcode file with the integrated Pods.

---

### Helpful Tools

The following tools are used to simplify working on the app:

#### Bundler

Bundler provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed. In Zap iOS it is used to pin cocoapod and fastlane versions.

If you would like to learn more take a look at https://www.mokacoding.com/blog/ruby-for-ios-developers-bundler/

#### CocoaPods

For managing dependencies (https://cocoapods.org). Zap iOS uses CocoaPods in order to install and managed Swift/Objective-C dependencies.

If you would to update a pod to a newer version, make the appropriate changes in the `Podfile` and then run the following command:

`pod update [PODNAME]`

**Note:** If you have any issues with CocoaPods, first run `bundle install` to install dependencies located in the `Gemfile`.

#### SwiftLint

Enforce Swift style and conventions (https://github.com/realm/SwiftLint)

#### SwiftGen

Code generator for your assets, storyboards, Localizable.strings (https://github.com/SwiftGen/SwiftGen)
Generates three files in the Library framework:

* Assets.swift
* StoryboardScenes.swift
* Strings.swift

#### Fastlane

For automating the development and release process (https://fastlane.tools)

---

### Build Configurations

We currently support two ways of connecting to `lnd`:

1. Running `lnd` on your local device.
2. Connecting to a remote `lnd` instance.

On-device `lnd` is the default, and in order to support this, you'll need to build the
`Lndmobile.framework` framework and place it into the `Frameworks` folder.

If you'd prefer connecting to a remote `lnd` instance without building `Lndmobile.framework`,
you can edit the `Zap` run scheme and switch the Build Configuration from `debug` to `debugRemote`.
