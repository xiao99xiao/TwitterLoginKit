//
//  ViewController.swift
//  TwitterLoginKit
//
//  Created by xiao99xiao on 03/20/2019.
//  Copyright (c) 2019 xiao99xiao. All rights reserved.
//

import UIKit
import TwitterLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginTapped(_ sender: Any) {
        TwitterLoginKit.shared.login(withViewController: self) { (state) in
            switch state {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let session):
                print(session)
            }
        }
    }
}

