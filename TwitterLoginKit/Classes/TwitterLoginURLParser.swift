//
//  TwitterLoginURLParser.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/20.
//

import UIKit

class TwitterLoginURLParser: NSObject {
    private var authConfig: TwitterAuthConfig

    init(authConfig: TwitterAuthConfig) {
        self.authConfig = authConfig
    }

    func isMobileSSOSuccessURL(_ url: URL) -> Bool {
        guard let keys = url.host?.components(separatedBy: "&").compactMap({$0.components(separatedBy: "=").first?.removingPercentEncoding}) else {return false}
        return keys.contains("secret") && keys.contains("token") && keys.contains("username") && isTwitterKitRedirectURL(url)
    }

    func isMobileSSOCancelURL(_ url: URL) -> Bool {
        return isTwitterKitRedirectURL(url) && (url.host == nil)
    }

    func isOauthTokenVerified(from url: URL?) -> Bool {
        guard let url = url else {return false}
        let param = parameters(fromQueryString: url.absoluteString)
        var token = param[TwitterAuthOAuthTokenKey]
        if token == nil {
            token = param[TwitterAuthAppOAuthDeniedKey]
        }

        return true
    }

    func isTwitterKitRedirectURL(_ url: URL) -> Bool {
        return url.scheme?.caseInsensitiveCompare(authConfig.twitterKitURLScheme) == ComparisonResult.orderedSame
    }

    func hasValidURLScheme() -> Bool {
        guard let schemas = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String:Any]] else {return false}
        for schema in schemas {
            if let urlTypes = schema["CFBundleURLSchemes"] as? [String], urlTypes.contains(self.authConfig.twitterKitURLScheme) {
                return true
            }
        }
        return false
    }

    func authRedirectScheme() -> String {
        if hasValidURLScheme() {
            return authConfig.twitterKitURLScheme
        } else {
            return TwitterSDKScheme
        }
    }
}

func parameters(fromQueryString queryString: String) -> [String: String] {
    return queryString.components(separatedBy: "&").reduce(into: [:], { (result, string) in
        let s = string.components(separatedBy: "=")
        if s.count == 2, let key = s[0].removingPercentEncoding, let value = s[1].removingPercentEncoding {
            result[key] = value
        }
    })
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }

    var bodyParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: CharactersToBeEscapedInQueryString)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
}
