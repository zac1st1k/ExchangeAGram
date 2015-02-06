//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Zac on 6/02/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    override func viewDidLoad() {
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
        imageView.hidden = true
//        label.hidden = true
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        imageView.hidden = false
        label.hidden = false
    }
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        println(user)
        label.text = user.name
        let userImageURL = "https://graph.facebook.com/\(user.objectID)/picture?type=large"
        let url = NSURL(string: userImageURL)
        let imageData = NSData(contentsOfURL: url!)
        let image = UIImage(data: imageData!)
        imageView.image = image
    }
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        imageView.hidden = true
        label.hidden = true
    }
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        println("Error: \(error.localizedDescription)")
    }
}
