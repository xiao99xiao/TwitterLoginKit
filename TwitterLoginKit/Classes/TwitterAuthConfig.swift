//
//  TwitterAuthConfig.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/20.
//

import UIKit

class TwitterAuthConfig: NSObject {
    var consumerKey: String
    var consumerSecret: String
    var twitterKitURLScheme: String {
        get {
            return "twitterkit-" + consumerKey
        }
    }
    var twitterAuthorizeURL: URL {
        get {
            return URL(string: "twitterauth://authorize?consumer_key=\(consumerKey)&consumer_secret=\(consumerSecret)&oauth_callback=\(twitterKitURLScheme)")!
        }
    }

    init(withConsumerKey consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
}
