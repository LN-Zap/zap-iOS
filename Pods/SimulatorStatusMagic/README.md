## Simulator Status Magic

Modify the iOS Simulator so that it has a perfect status bar, then run your app and take perfect screenshots every time. The modifications made are designed to match the images you see on the Apple site and are as follows:

* 9:41 AM is displayed for the time.
* The battery is full and shows 100%.
* 5 bars of cellular signal and full WiFi bars are displayed.
* Tue Jan 9 is displayed for the date (iPad only)

### How do I use it?

* Clone this repository.
* Open SimulatorStatusMagic.xcodeproj with Xcode 6 (or above).
* Run the app target `SimulatorStatusMagic` (not `SimulatorStatusMagiciOS`) on whichever simulator type you would like to modify (it works with every device).
* Once the app launches, press the only button on the screen :)
* That's it, you're done! Now just run your app and take screenshots.

### How do I remove the customisations?

Run the app again and click "Restore Default Status Bar". Resetting the iOS Simulator using the normal menu option also works.

### I have a script to take my screenshots, can I automate this?

Yes! SimulatorStatusMagic is available via [CocoaPods](http://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage) and as a standalone source release. [Installation instructions](https://github.com/shinydevelopment/SimulatorStatusMagic/blob/master/INSTALLATION.md) are available.

It is recommended to **only** include `SDStatusBarManager` in your debug configuration so that the code is **never** included in release builds. When you want to apply a perfect status bar, call `[[SDStatusBarManager sharedInstance] enableOverrides]`. To restore the standard status bar, call `[[SDStatusBarManager sharedInstance] disableOverrides]`.

### What about automation of the sample app?

If you'd prefer to automate the app itself to automatically enable or disable the overrides, this can be done with environment variables.

Run with:

````
SIMULATOR_STATUS_MAGIC_OVERRIDES = enable
````

or

````
SIMULATOR_STATUS_MAGIC_OVERRIDES = disable
````

The overrides will be automatically enabled or disabled on launch.

### Does this work on device?

No. The status bar server is blocked on devices. However, macOS includes the facility to include a perfect status bar when recording your device screen with QuickTime ([Read more](https://appadvice.com/appnn/2014/08/quicktime-in-os-x-yosemite-reveals-that-apple-cares-about-status-bars)).

### How does this work?

The best idea is to check [the source code](https://github.com/shinydevelopment/SimulatorStatusMagic/blob/master/SDStatusBarManager/SDStatusBarManager.m) which should get you started with how it works :)

## Contributing

We'd love contributions and even have some suggestions for things that might need working on:

* Found a bug? If you report it with a pull request attached then you get a gold star :)
* ~~Non-English language support. We'd love it to work with more languages.~~ Now works with every language!

However, the scope of this project is intentionally limited. We're not planning to add options to this to allow ultimate customisation of the status bar. It's intended to do just one job really well, change the status bar to match [Apple's marketing materials](http://www.apple.com/ios/).
