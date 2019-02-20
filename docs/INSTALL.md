# Installation

The app uses git submodules. So in order to clone it and also clone the submodules you need
to run something like:

```
git clone --recurse-submodules https://github.com/LN-Zap/zap-iOS.git
```

### Preliminaries

* Xcode 10.1
* Gomobile https://github.com/golang/go/wiki/Mobile

### Build Configurations

The app supports both connecting to remote *lnd* instances as well as running *lnd* on the
device. By default running *lnd* on the device is disabled. If you want to turn it on you have to
switch the Build Configuration from *debugRemote* to *debug*, build the
*Lndmobile.framework* framework and place it into the *Frameworks* folder.
