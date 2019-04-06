//
//  TwitterConstants.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/20.
//

import Foundation

let TwitterLogInErrorDomain = "TwitterLogInErrorDomain"

enum TwitterErrorCode: Int {
    case unknown = -1
    case noAuthentication = 0
    case notInitialized = 1
    case userDeclinedPermission = 2
    case userHasNoEmailAddress = 3
    case invalidResourceID = 4
    case invalidURL = 5
    case mismatchedJSONType = 6
    case keychainSerializationFailure = 7
    case diskSerializationError = 8
    case webViewError = 9
    case missingParameter = 10
}

enum TwitterLoginErrorCode: Int {
    case unknown = -1
    case denied = 0
    case cancelled = 1
    case noAccounts = 2
    case reverseAuthFailed = 3
    case cannotRefreshSession = 4
    case sessionNotFound = 5
    case failed = 6
    case systemAccountCredentialsInvalid = 7
    case noTwitterApp = 8
}

let TwitterAuthOAuthTokenKey = "oauth_token"
let TwitterAuthOAuthSecretKey = "oauth_token_secret"
let TwitterAuthAppOAuthScreenNameKey = "screen_name"
let TwitterAuthAppOAuthUserIDKey = "user_id"
let TwitterAuthAppOAuthVerifierKey = "oauth_verifier"
let TwitterAuthAppOAuthDeniedKey = "denied"
let TwitterAuthTokenKey = "token"
let TwitterAuthSecretKey = "secret"
let TwitterAuthUsernameKey = "username"
let TwitterAuthTokenSeparator = "-"
let TwitterAuthAppOAuthAppKey = "app"
let TwitterAuthAppOAuthCallbackKey = "oauth_callback"


let TwitterSDKScheme = "twittersdk"
let TwitterSDKRedirectHost = "callback"

let TwitterAPIHost = "api.twitter.com"
let TwitterHTTPSScheme = "https"
let TwitterRequestTokenPath = "/oauth/request_token"

