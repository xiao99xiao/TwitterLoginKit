# TwitterLoginKit

[![CI Status](https://img.shields.io/travis/xiao99xiao/TwitterLoginKit.svg?style=flat)](https://travis-ci.org/xiao99xiao/TwitterLoginKit)
[![Version](https://img.shields.io/cocoapods/v/TwitterLoginKit.svg?style=flat)](https://cocoapods.org/pods/TwitterLoginKit)
[![License](https://img.shields.io/cocoapods/l/TwitterLoginKit.svg?style=flat)](https://cocoapods.org/pods/TwitterLoginKit)
[![Platform](https://img.shields.io/cocoapods/p/TwitterLoginKit.svg?style=flat)](https://cocoapods.org/pods/TwitterLoginKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* A valid Twitter App with  Consumer API keys and Access token & access token secret issued.

## Usage

1. Call `TwitterLoginKit.shared.start(withConsumerKey:, consumerSecret:)` at `func application(_ application:, didFinishLaunchingWithOptions:) -> Bool`
2. Add URL Scheme `twitterkit-<Consumer Key>`
3. Call `func login(withViewController:, completion:)` to start login process

## Installation

TwitterLoginKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TwitterLoginKit'
```

## Author

xiao99xiao, xx2004xiamen@gmail.com

## License

TwitterLoginKit is available under the MIT license. See the LICENSE file for more info.
