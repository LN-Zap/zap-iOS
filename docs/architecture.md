# Architecture

The app is using a MVVM-C architecture.

[Classic MVVM](https://artsy.github.io/blog/2015/09/24/mvvm-in-swift/) plus a [Coordinator Pattern](http://khanlou.com/2015/01/the-coordinator/).

To learn more about coordinators checkout this:
* [Swift Talk #17 - Ledger Mac App: Architecture](https://talk.objc.io/episodes/S01E17-architecture)
* [Coordinators Redux](http://khanlou.com/2015/10/coordinators-redux/)

For binding view model state to the view layer we use [Bond](https://github.com/DeclarativeHub/Bond) - a lightweight Swift binding framework.
