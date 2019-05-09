# TwitterLoginKit

TwitterLoginKit aims to replicate the login feature of the official TwitterKit, including login via Twitter App and via SFSafariViewController. Currently the library behaves the same as the official one, while lacking a bit security protection as below:

* Verify tokens received from URL scheme call (normally called by Twitter app) via Twitter API `account/verify_credentials`. Without this verification, someone could create a fake Twitter app to intercept the login process and return invalid tokens.
* SSL Pinning, necessary to avoid MITM between your app and Twitter API.


## Requirements

* Register a valid Twitter App in Twitter Developers with Consumer API keys and Access token & access token secret issued.

## Installation

TwitterLoginKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TwitterLoginKit'
```

## Usage

1. Call `TwitterLoginKit.shared.start(withConsumerKey:, consumerSecret:)` at `func application(_ application:, didFinishLaunchingWithOptions:) -> Bool`
2. Add URL Scheme `twitterkit-<Consumer Key>`
3. Call `func login(withViewController:, completion:)` to start login process

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

xiao99xiao, xx2004xiamen@gmail.com

## License

TwitterLoginKit is available under the MIT license. See the LICENSE file for more info.
