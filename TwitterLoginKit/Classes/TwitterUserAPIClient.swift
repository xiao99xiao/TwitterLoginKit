//
//  TWTRUserAPIClient.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/22.
//

import UIKit

class TwitterUserAPIClient: TwitterNetworking {

    private let authToken: String?
    private let authTokenSecret: String?

    init(withAuthConfig authConfig: TwitterAuthConfig, authToken: String?, authTokenSecret: String?) {
        self.authToken = authToken
        self.authTokenSecret = authTokenSecret
        super.init(withAuthConfig: authConfig)
    }

    override func urlRequest(withMethod method: String, urlString: String, parameters: [String : String]) -> URLRequest? {
        if method == "POST" {
            return self.post(urlString: urlString, parameters: parameters)
        } else {
            // TODO
            return nil
        }
    }

    func post(urlString: String, parameters: [String: String]) -> URLRequest? {
        guard let originalURL = URL(string: urlString) else {return nil}
        return TwitterGCOAuth.urlRequest(forPath: originalURL.path, httpMethod: "POST", parameters: parameters, scheme: "https", host: originalURL.host!, consumerKey: authConfig.consumerKey, consumerSecret: authConfig.consumerSecret, accessToken: authToken, tokenSecret: authTokenSecret)
    }
}

typealias TwitterRequestCompletion = ((Data?, URLResponse?, Error?) -> Void)

class TwitterNetworking: NSObject {
    var authConfig: TwitterAuthConfig

    init(withAuthConfig authConfig: TwitterAuthConfig) {
        self.authConfig = authConfig
        super.init()
    }

    static var defaultConfiguration: URLSessionConfiguration = {
        var configuration = URLSessionConfiguration.default
        configuration.httpShouldUsePipelining = true
        configuration.urlCredentialStorage = nil
        return configuration
    }()

    static var urlSession: URLSession = {
        let delegateQueue = OperationQueue()
        delegateQueue.maxConcurrentOperationCount = 1
        delegateQueue.name = "com.twittercore.sdk.url-session-queue"
        let sessionConfig = TwitterNetworking.defaultConfiguration
        return URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: delegateQueue)
    }()

    func urlRequest(withMethod method: String, urlString: String, parameters: [String: String]) -> URLRequest? {
        guard let url = URL(string: urlString) else {return nil}
        var request = URLRequest(url: url)
        let query = parameters.queryParameters
        var absoluteString = request.url!.absoluteString
        if method == "POST" {
            let data = query.data(using: .utf8)
            request.httpBody = data
        } else {
            if request.url!.query != nil {
                absoluteString.append(contentsOf: "&\(query)")
            } else {
                absoluteString.append(contentsOf: "?\(query)")
            }
            let modifiedUrl = URL(string: absoluteString)
            request.url = modifiedUrl
        }
        request.httpMethod = method
        return request
    }

    func sendAsynchronousRequest(_ request: URLRequest, completion: @escaping TwitterRequestCompletion) {
        let task = TwitterNetworking.urlSession.dataTask(with: request, completionHandler: completion)
        task.resume()
    }

}
