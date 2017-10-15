#  Contribution guidelines for cocoadialog

## Prerequisites

- [Xcode 9.0+](https://developer.apple.com/xcode/) and general knowledge about how to use it.
- [CocoaPods](https://cocoapods.org/) - `sudo gem install cocoapods`

## Getting Started

1. Clone this repository.
2. Run `pod install` _(this make take a while if you just installed CocoaPods as it has to download its repository)_
3. Open `cocoadialog.xcworkspace` in Xcode.
4. Verify that you have the bundled `Debug` and `Release` schemas.
5. Successfully build the `Debug` and `Release` schemas to ensure everything is working properly.
6. Start improving cocoadialog!

## Testing

cocoadialog includes a suite of unit tests within the `Tests` subdirectory. These tests can be executed two ways:

1. Using the `Test` action in the `Debug` scheme.
2. Running the following in your terminal from the root directory of this project:

```bash
$ xcodebuild -workspace cocoadialog.xcworkspace -scheme Debug test | tee xcode-debug-test.log | xcpretty -f `xcpretty-travis-formatter`
```
