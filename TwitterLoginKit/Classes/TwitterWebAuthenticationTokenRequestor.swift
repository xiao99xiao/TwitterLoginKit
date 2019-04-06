//
//  TwitterWebAuthenticationTokenRequestor.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/22.
//

import UIKit

public enum TwitterTokenRequestState {
    case success(String)
    case failure(Error)
}

public typealias TwitterAuthenticationTokenRequestCompletion = ((TwitterTokenRequestState) -> Void)

class TwitterWebAuthenticationTokenRequestor: NSObject {
    private let authConfig: TwitterAuthConfig
    private let urlParser: TwitterLoginURLParser

    private let apiClient: TwitterUserAPIClient

    init(authConfig: TwitterAuthConfig, urlParser: TwitterLoginURLParser) {
        self.authConfig = authConfig
        self.urlParser = urlParser
        self.apiClient = TwitterUserAPIClient(withAuthConfig: authConfig, authToken: nil, authTokenSecret: nil)
    }

    func requestAuthenticationToken(_ completion: @escaping TwitterAuthenticationTokenRequestCompletion) {
        let redirectScheme = urlParser.authRedirectScheme()
        let callbackParams = [TwitterAuthAppOAuthAppKey: authConfig.consumerKey]
        let redirectURL = "\(redirectScheme)://\(TwitterSDKRedirectHost)?\(callbackParams.queryParameters)"
        let params = [TwitterAuthAppOAuthCallbackKey: redirectURL]
        guard let postURL = TwitterAPIURL(withPath: TwitterRequestTokenPath), let request = apiClient.urlRequest(withMethod: "POST", urlString: postURL.absoluteString, parameters: params) else {return}

        apiClient.sendAsynchronousRequest(request) { (data, _, connectionError) in
            self.handleRequest(TokenResponse: data, error: connectionError, completion: completion)
        }
    }

    func handleRequest(TokenResponse tokenData: Data?, error: Error?, completion: TwitterAuthenticationTokenRequestCompletion) {
        let tok = token(fromTokenData: tokenData)
        if let tok = tok {
            completion(.success(tok))
        } else {
            didFail(toReceiveOAuthToken: tokenData)
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(unknownLoginError(withMessage: "Could not retrieve auth token")))
            }
        }
    }

    func token(fromTokenData tokenData: Data?) -> String? {
        return dictionary(fromTokenResponseData: tokenData)?[TwitterAuthOAuthTokenKey]
    }

    func dictionary(fromTokenResponseData tokenData: Data?) -> [String : String]? {
        guard let tokenData = tokenData, let queryString = String(data: tokenData, encoding: .utf8) else {return nil}
        return parameters(fromQueryString: queryString)
    }

    func didFail(toReceiveOAuthToken responseData: Data?) {
        var errorDescription = ""

        if let responseData = responseData {
            errorDescription = String(data: responseData, encoding: .utf8) ?? ""
        }

        print("Error obtaining user auth token. \(errorDescription)")
    }

    func unknownLoginError(withMessage message: String?) -> Error {
        return NSError(domain: TwitterLogInErrorDomain, code: TwitterLoginErrorCode.unknown.rawValue, userInfo: [
            NSLocalizedDescriptionKey: message ?? 0
            ])
    }

}
