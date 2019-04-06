//
//  TwitterErrors.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/20.
//

import UIKit

let TwitterLoginErrorDomain = "TwitterLoginErrorDomain"

class TwitterErrors {
    static let mobileSSOCancelError = NSError(domain: TwitterLoginErrorDomain, code: TwitterLoginErrorCode.cancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "User cancelled login from Twitter App"])

    static let invalidSourceApplicationError = NSError(domain: TwitterLoginErrorDomain, code: TwitterLoginErrorCode.failed.rawValue, userInfo: [NSLocalizedDescriptionKey: "Authentication was made from an invalid application."])

    static let noTwitterAppError = NSError(domain: TwitterLoginErrorDomain, code: TwitterLoginErrorCode.noTwitterApp.rawValue, userInfo: [NSLocalizedDescriptionKey: "No Twitter App installed. Unable to perform Mobile SSO login flow."])

    static let mobileSSOInvalidError = NSError(domain: TwitterLoginErrorDomain, code: TwitterLoginErrorCode.noTwitterApp.rawValue, userInfo: [NSLocalizedDescriptionKey: "Twitter App returns invalid session."])

    static let webCancelError = NSError(domain: TwitterLoginErrorDomain, code: TwitterLoginErrorCode.cancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "User cancelled login flow."])
    
}


