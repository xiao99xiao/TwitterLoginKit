//
//  TwitterGCOAuth.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/22.
//

import UIKit
import CommonCrypto

let CharactersToBeEscapedInQueryString = CharacterSet(charactersIn: "%:/?&=;+!@#$(){}',*[] \"\n|^<>`").inverted

class TwitterGCOAuth: NSObject {
    private let signatureSecret: String
    private let oAuthParameters: [String: String]
    var requestParameters: [String: String]?
    var httpMethod: String?
    var url: URL?

    init(withConsumerKey consumerKey: String, consumerSecret: String, accessToken: String?, tokenSecret: String?) {
        var oAuthParameters = ["oauth_consumer_key": consumerKey, "oauth_nonce": TwitterGCOAuth.nonce(), "oauth_timestamp": TwitterGCOAuth.timeStamp(), "oauth_version": "1.0", "oauth_signature_method": "HMAC-SHA1"]
        if let accessToken = accessToken {
            oAuthParameters["oauth_token"] = accessToken
        }
        self.oAuthParameters = oAuthParameters
        signatureSecret = "\(consumerSecret.addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString) ?? "")&\(tokenSecret?.addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString) ?? "")"
        super.init()
    }

    func request() -> URLRequest? {
        guard let url = url else {return nil}
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.addValue(authorizationHeader(), forHTTPHeaderField: "Authorization")
        request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.httpMethod = httpMethod
        request.httpShouldHandleCookies = true
        return request
    }

    func authorizationHeader() -> String {
        var dictionary = oAuthParameters
        dictionary["oauth_signature"] = signature()
        return "OAuth " + (dictionary.compactMap { (key, value) -> String? in
            guard let k = key.addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString), let v = value.addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString) else {return nil }
            return "\(k)=\"\(v)\""
        }.joined(separator: ","))

    }

    func signature() -> String {
        let data = HmacSHA1(key: signatureSecret, input: signatureBase()!)
        return data.base64EncodedString()
    }

    func signatureBase() -> String? {
        guard let url = url else {return nil}
        var parameters = [String: String]()
        parameters.merge(oAuthParameters, uniquingKeysWith: {$1})
        parameters.merge(requestParameters ?? [:], uniquingKeysWith: {$1})
        let keys = parameters.keys.sorted()
        let normalizedParameters = keys.compactMap { (key) -> String? in
            guard let value = parameters[key], let k = key.addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString), let v = value.addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString) else {return nil }
            return k + "=" + v
        }.joined(separator: "&")
        let pathWithPrevervedTrailingSlash = url.path.removingPercentEncoding!
        let urlString = url.scheme!.lowercased() + "://" + url.host!.lowercased() + pathWithPrevervedTrailingSlash
        return [httpMethod!, urlString.addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString)!, normalizedParameters.addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString)!].joined(separator: "&")
    }

    private func HmacSHA1(key: String, input: String) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), key, key.count, input, input.count, &digest)
        return Data(digest)
    }

    static func nonce() -> String {
        return UUID().uuidString
    }

    static func timeStamp() -> String {
        return String(Int(Date().timeIntervalSince1970))
    }

    static func urlRequest(forPath path: String, httpMethod: String, parameters: [String: String], scheme: String, host: String, consumerKey: String, consumerSecret: String, accessToken: String?, tokenSecret: String?) -> URLRequest? {
        let oauth = TwitterGCOAuth(withConsumerKey: consumerKey, consumerSecret: consumerSecret, accessToken: accessToken, tokenSecret: tokenSecret)
        oauth.httpMethod = httpMethod
        oauth.requestParameters = parameters

        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
        var urlString = "\(scheme)://\(host)\(encodedPath)"
        if httpMethod.uppercased() == "GET" {
            if let requestParameters = oauth.requestParameters, !requestParameters.isEmpty {
                let query = requestParameters.queryParameters
                urlString = "\(urlString)?\(query)"
            }
        }
        oauth.url = URL(string: urlString)!
        guard var request = oauth.request() else {return nil}
        if httpMethod.uppercased() != "GET", let requestParameters = oauth.requestParameters, !requestParameters.isEmpty {
            let data = requestParameters.bodyParameters.data(using: .utf8)!
            request.httpBody = data
            request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
