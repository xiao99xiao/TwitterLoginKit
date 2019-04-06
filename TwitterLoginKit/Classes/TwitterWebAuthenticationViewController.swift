//
//  TwitterWebAuthenticationViewController.swift
//  TwitterLoginKit
//
//  Created by Xiao Xiao on 2019/03/27.
//

import UIKit

class TwitterWebAuthenticationViewController: UIViewController {
    private let authenticationToken: String
    private let apiClient: TwitterUserAPIClient
    private let authURL: URL
    private let urlParser: TwitterLoginURLParser

    init(WithAuthenticationToken authenticationToken: String, authConfig: TwitterAuthConfig, urlParser: TwitterLoginURLParser) {
        self.authenticationToken = authenticationToken
        self.apiClient = TwitterUserAPIClient(withAuthConfig: authConfig, authToken: nil, authTokenSecret: nil)
        self.urlParser = urlParser
        self.authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=" + authenticationToken)!
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
