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


class ViewController: UIViewController, LoginButtonDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var eventsCreated:[String] = ["Please Login to View Your Events"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsCreated.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
        myCell.textLabel!.text = eventsCreated[indexPath.row]
        
        return myCell
    }
    
    
    @IBOutlet var eventsCreatedTableView: UITableView!
    
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
                self.loadTableData(isIn: true, userName: name!)

            }
        }
        
        eventsCreatedTableView.reloadData()
       
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("----LOGOUT COMPLETE---")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        loadTableData(isIn: false, userName: "")
        eventsCreatedTableView.reloadData()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        eventsCreatedTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        eventsCreatedTableView.delegate = self
        eventsCreatedTableView.dataSource = self
        
        if let user = Auth.auth().currentUser{
            loadTableData(isIn:true, userName: user.displayName!)
        }
        // Do any additional setup after loading the view, typically from a nib.
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.delegate = self
//        loginButton.center = view.center
        loginButton.frame.origin.y = 20
        loginButton.frame.origin.x = self.view.frame.width/2 - loginButton.frame.width
     //   loginButton.frame.origin.x = view.centerXAnchor.
        view.addSubview(loginButton)
        
//        if let accessToken = AccessToken.current{
//            print("Hello")
//        }
    }
    
    func loadTableData(isIn:Bool, userName:String){
        eventsCreated = []
        if(isIn){
            let userId = Auth.auth().currentUser!.uid
            var ref: DatabaseReference!
            
            ref = Database.database().reference()
            
            print ("firebase time")
            ref.child("events").observeSingleEvent(of: .value, with: {
                snapshot in
                print("\(snapshot.key) -> \(String(describing: snapshot.value))")
                let someData = snapshot.value! as! Dictionary<String, NSDictionary>
                
                for (key,value) in someData {
                    print("value is \(value["Creator"]!)")
                    
                    if let eventCreator = value["CreatorId"]{
                        let creatorId = eventCreator as! String
                        if(userId == creatorId){
                            self.eventsCreated.append(value["Title"] as! String)
                        }
                    }
                    print("value is \(value["Title"]!)")
                    print("key is \(key)")
                    //self.myArray.append(value)
                    
                }
            })
            print("done fire")
        }
        else{
            eventsCreated = ["Please Login to View Your Events"]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

