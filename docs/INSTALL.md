# Installation

run `./setup.sh` to download the required frameworks.

### Preliminaries

You need Xcode 10.1 to run the app. There are also a few tools that are used to simplify working on the app:

#### Bundler

Bundler provides a consistent environment for Ruby projects by tracking and installing the exact gems and versions that are needed. In Zap iOS it is used to pin cocoapod and fastlane versions.

To install the dependencies run:

```
bundle install
```

If you want to use a dependency that is pinned by bundler just run something like:

```
bundle exec pod install
```

If you want to learn more take a look at https://www.mokacoding.com/blog/ruby-for-ios-developers-bundler/

#### SwiftLint

Enforce Swift style and conventions (https://github.com/realm/SwiftLint)

#### SwiftGen

Code generator for your assets, storyboards, Localizable.strings (https://github.com/SwiftGen/SwiftGen)
Generates three files in the Library framework:

* Assets.swift
* StoryboardScenes.swift
* Strings.swift

#### Cocoapods

For managing dependencies.

#### Fastlane

For automating the development and release process.

### Build Configurations

We currently support two ways of connecting to `lnd`:

1. Running `lnd` on your local device.
2. Connecting to a remote `lnd` instance.

On-device `lnd` is the default, and in order to support this, you'll need to build the
`Lndmobile.framework` framework and place it into the `Frameworks` folder.

If you'd prefer connecting to a remote `lnd` instance without building `Lndmobile.framework`,
you can edit the `Zap` run scheme and switch the Build Configuration from `debug` to `debugRemote`.
