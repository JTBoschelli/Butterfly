//
//  ViewController.swift
//  Butterfly
//
//  Created by Justin Boschelli on 11/12/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FacebookLogin
import FacebookCore
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit


class ViewController: UIViewController, LoginButtonDelegate {
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("---LOGIN COMPLETE---")
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        print("CREDENTIAL: \(credential)")
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                return
            }
            var ref: DatabaseReference!
            
            ref = Database.database().reference()
            let user = Auth.auth().currentUser
            if let user = user {
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                let uid = user.uid
                let name = user.displayName
                ref.child("users").child(uid).setValue(["name": name!])
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("----LOGOUT COMPLETE---")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

