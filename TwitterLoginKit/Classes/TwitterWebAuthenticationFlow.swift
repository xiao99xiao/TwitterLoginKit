//
//  TwitterWebAuthenticationFlow.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/22.
//

import UIKit
import SafariServices

typealias TwitterAuthenticationFlowControllerPresentation = ((UIViewController) -> Void)
typealias TwitterAuthRedirectCompletion = ((URL) -> Void)

class TwitterWebAuthenticationFlow: NSObject {
    private var authConfig: TwitterAuthConfig
    private var urlParser: TwitterLoginURLParser
    private var apiClient: TwitterUserAPIClient?

    private var controllerPresentation: TwitterAuthenticationFlowControllerPresentation?
    private var completion: TwitterLoginCompletion?
    private var redirectCompletion: TwitterAuthRedirectCompletion?

    init(authConfig: TwitterAuthConfig, urlParser: TwitterLoginURLParser) {
        self.authConfig = authConfig
        self.urlParser = urlParser
    }

    func beginAuthenticationFlow(_ presentationBlock: @escaping TwitterAuthenticationFlowControllerPresentation, completion: @escaping TwitterLoginCompletion) {
        self.controllerPresentation = presentationBlock
        self.completion = completion
        requestAuthenticationToken { (token) in
            self.presentWebAuthenticationViewController(token)
        }
    }

    func resumeAuthentication(withRedirectURL url: URL) -> Bool {
        if urlParser.isTwitterKitRedirectURL(url) {
            redirectCompletion?(url)
            return true
        } else {
            return false
        }
    }


    func requestAuthenticationToken(_ completion: @escaping ((_ token: String) -> Void)) {
        let tokenRequestor = TwitterWebAuthenticationTokenRequestor(authConfig: authConfig, urlParser: urlParser)
        tokenRequestor.requestAuthenticationToken { (response) in
            switch response {
            case .success(let token):
                completion(token)
            case .failure(let error):
                self.fail(withError: error)
            }
        }
    }

    func presentWebAuthenticationViewController(_ token: String) {
        self.apiClient = TwitterUserAPIClient(withAuthConfig: authConfig, authToken: token, authTokenSecret: nil)
        let safariViewController = SFSafariViewController(url: URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=" + token)!)
        safariViewController.delegate = self
        redirectCompletion = { url in
            self.handleAuthResponse(withUrl: url)
        }
        DispatchQueue.main.async {
            self.controllerPresentation?(safariViewController)
        }
    }

    func handleAuthResponse(withUrl url: URL) {
        guard let query = url.query else {return}
        let authenticationResponse = parameters(fromQueryString: query)

        var localError: Error? = nil
        if authenticationResponse[TwitterAuthAppOAuthDeniedKey] != nil {
            localError = NSError(domain: TwitterLoginErrorDomain, code: TwitterLoginErrorCode.denied.rawValue, userInfo: authenticationResponse)
        } else if authenticationResponse[TwitterAuthAppOAuthVerifierKey] == nil {
            localError = NSError(domain: TwitterLoginErrorDomain, code: TwitterLoginErrorCode.unknown.rawValue, userInfo: authenticationResponse)
        }

        if let error = localError {
            fail(withError: error)
        } else {
            requestAccessToken(withVerifier: authenticationResponse[TwitterAuthAppOAuthVerifierKey]!)
        }
    }

    func requestAccessToken(withVerifier verifier: String) {
        let param = [TwitterAuthAppOAuthVerifierKey: verifier]
        guard let apiClient = self.apiClient, let request = apiClient.urlRequest(withMethod: "POST", urlString: "https://api.twitter.com/oauth/access_token", parameters: param) else {return}

        apiClient.sendAsynchronousRequest(request) { (data, response, error) in
            if let data = data, let queryString = String(data: data, encoding: .utf8) {
                let responseDictionary = parameters(fromQueryString: queryString)
                if TwitterLoginSession.isValidSessionDictionary(responseDictionary), let session = TwitterLoginSession(withSessionDictionary: responseDictionary) {
                    self.succeed(withSession: session)
                } else if let error = error {
                    self.fail(withError: error)
                } else {
                    let parseError = NSError(domain: TwitterLoginErrorDomain, code: TwitterErrorCode.webViewError.rawValue, userInfo: [NSLocalizedDescriptionKey: "There was an error retreiving the required tokens from the webview"])
                    self.fail(withError: parseError)
                }
            }
        }
    }

    func fail(withError error: Error) {
        if let completion = self.completion {
            completion(.failure(error))
        }
    }

    func succeed(withSession session: TwitterLoginSession) {
        if let completion = self.completion {
            completion(.success(session))
        }
    }

}

extension TwitterWebAuthenticationFlow: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        #if !targetEnvironment(macCatalyst)
        fail(withError: TwitterErrors.webCancelError)
        #endif
    }
}

func TwitterAPIURL(withPath path: String) -> URL? {
    let components = path.components(separatedBy: "?")
    guard components.count <= 2 else {return nil}
    var urlComponents = URLComponents()
    urlComponents.scheme = TwitterHTTPSScheme
    urlComponents.host = TwitterAPIHost
    urlComponents.path = components[0]
    if components.count > 1 {
        urlComponents.query = components[1]
    }
    return urlComponents.url
}
