//
//  TwitterMobileSSO.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/20.
//

import UIKit

enum SourceApplicationType {
    case sso, web, invalid
}

class TwitterMobileSSO: NSObject {
    private var authConfig: TwitterAuthConfig
    private var urlParser: TwitterLoginURLParser
    private var completion: TwitterLoginCompletion?

    init(authConfig: TwitterAuthConfig, urlParser: TwitterLoginURLParser) {
        self.authConfig = authConfig
        self.urlParser = urlParser
    }

    func attemptAppLogin(withCompletion completion: @escaping TwitterLoginCompletion) {
        self.completion = completion
        UIApplication.shared.open(authConfig.twitterAuthorizeURL, options: [:]) { (success) in
            if !success {
                completion(TwitterLoginState.failure(TwitterErrors.noTwitterAppError))
            }
        }
    }

    func typeOf(sourceApplication: String) -> SourceApplicationType {
        if sourceApplication.contains("com.twitter") || sourceApplication.contains("com.atebits") {
            return .sso
        } else if let bundleId = Bundle.main.bundleIdentifier, sourceApplication.contains("com.apple") || sourceApplication.contains(bundleId) {
            return .web
        } else {
            return .invalid
        }
    }

    func triggerInvalidSourceError() {
        DispatchQueue.main.async {
            self.completion?(.failure(TwitterErrors.invalidSourceApplicationError))
        }
    }


    func verifyOauthTokenResponse(fromURL url: URL?) -> Bool {
        return urlParser.isOauthTokenVerified(from: url)
    }


    func process(redirectURL url: URL) -> Bool {
        if urlParser.isMobileSSOCancelURL(url) {
            DispatchQueue.main.async {
                self.completion?(.failure(TwitterErrors.mobileSSOCancelError))
            }
            return true
        } else if urlParser.isMobileSSOSuccessURL(url), let host = url.host {
            let params = parameters(fromQueryString: host)
            if let session = TwitterLoginSession(withSSOResponse: params) {
                self.completion?(.success(session))
            } else {
                self.completion?(.failure(TwitterErrors.mobileSSOInvalidError))
            }
            return true
        } else {
            self.completion?(.failure(TwitterErrors.invalidSourceApplicationError))
        }

        return false
    }
}
