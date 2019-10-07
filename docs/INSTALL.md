# Installation

### Preliminaries

Xcode 10.1 or above is required to run the app.

#### First Step
Run `./setup.sh` to download the required frameworks.

#### Helpful Tools and Next Steps

The following tools are used to simplify working on the app:

##### Bundler

Bundler provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed. In Zap iOS it is used to pin cocoapod and fastlane versions.

Install the dependencies located in the `Gemfile` by running:

```
bundle install
```

If you would like to learn more take a look at https://www.mokacoding.com/blog/ruby-for-ios-developers-bundler/

##### SwiftLint

Enforce Swift style and conventions (https://github.com/realm/SwiftLint)

##### SwiftGen

Code generator for your assets, storyboards, Localizable.strings (https://github.com/SwiftGen/SwiftGen)
Generates three files in the Library framework:

* Assets.swift
* StoryboardScenes.swift
* Strings.swift

##### CocoaPods

For managing dependencies (https://cocoapods.org)

Zap iOS uses CocoaPods in order to install and managed the swift/Objective-C dependencies. To install the CocoaPods managed dependencies, run the following command:

```
bundle exec pod install
```

This command guarantees that the version of CocoaPods specified in the `Gemfile.lock` is used to `pod install` the dependencies listed in the `Podfile.lock`.

If you would to update a pod to a newer version, make the appropriate changes in the `Podfile` and then run the following command:

```
pod update [PODNAME]
```

##### Fastlane

For automating the development and release process (https://fastlane.tools)

### Build Configurations

We currently support two ways of connecting to `lnd`:

1. Running `lnd` on your local device.
2. Connecting to a remote `lnd` instance.

On-device `lnd` is the default, and in order to support this, you'll need to build the
`Lndmobile.framework` framework and place it into the `Frameworks` folder.

If you'd prefer connecting to a remote `lnd` instance without building `Lndmobile.framework`,
you can edit the `Zap` run scheme and switch the Build Configuration from `debug` to `debugRemote`.
