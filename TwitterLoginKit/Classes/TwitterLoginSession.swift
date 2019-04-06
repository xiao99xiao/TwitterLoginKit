//
//  TwitterLoginSession.swift
//  TwitterLogin
//
//  Created by Xiao Xiao on 2019/03/20.
//

import Foundation

public enum TwitterLoginState {
    case success(TwitterLoginSession)
    case failure(Error)
}

public struct TwitterLoginSession {
    let authToken: String
    let authTokenSecret: String
    let userName: String
    let userID: String
}

extension TwitterLoginSession {
    init?(withSSOResponse response: [String: String]) {
        guard let authToken = response[TwitterAuthTokenKey],
        let authTokenSecret = response[TwitterAuthSecretKey],
        let userName = response[TwitterAuthUsernameKey],
        let userID = authToken.components(separatedBy: TwitterAuthTokenSeparator).first
        else {return nil}
        self.authToken = authToken
        self.authTokenSecret = authTokenSecret
        self.userName = userName
        self.userID = userID
    }

    init?(withSessionDictionary authDictionary: [String: String]) {

        guard let authToken = authDictionary[TwitterAuthOAuthTokenKey],
        let authTokenSecret = authDictionary[TwitterAuthOAuthSecretKey],
        let userName = authDictionary[TwitterAuthAppOAuthScreenNameKey],
        let userID = authDictionary[TwitterAuthAppOAuthUserIDKey]
        else {return nil}
        self.authToken = authToken
        self.authTokenSecret = authTokenSecret
        self.userName = userName
        self.userID = userID
    }

    static func isValidSessionDictionary(_ sessionDictionary: [String: String]) -> Bool  {
        let keys = [TwitterAuthOAuthTokenKey, TwitterAuthOAuthSecretKey, TwitterAuthAppOAuthScreenNameKey, TwitterAuthAppOAuthUserIDKey]
        if Set(sessionDictionary.keys).isSuperset(of: keys) {
            return true
        } else {
            return false
        }
    }
}
