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
    
    var invites:[String] = ["Please Login to View Your Invites"]
    var inviteIds:[String] = []
    
    @IBOutlet var accountHeader: UILabel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == eventsCreatedTableView{
            return eventsCreated.count
        }
        else{
            return invites.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == eventsCreatedTableView{
            let myCell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
            myCell.textLabel!.text = eventsCreated[indexPath.row]
            
            return myCell
        }
        else{
            let myCell = UITableViewCell(style: .subtitle, reuseIdentifier: "inviteCell")
            myCell.textLabel!.text = invites[indexPath.row]
            if let _ = Auth.auth().currentUser{
                let buttonView = CGRect(x: myCell.frame.maxX-50, y: myCell.frame.minY, width: myCell.frame.width/6, height: myCell.frame.height)
                let button = UIButton(frame: buttonView)
                button.setTitleColor(UIColor.blue, for: .normal)
                button.setTitle("RSVP", for: UIControlState.normal)
                button.addTarget(self, action: #selector(rsvpToEvent), for: .touchUpInside)
                myCell.addSubview(button)
            }
            return myCell
        }
    }
    
    @objc func rsvpToEvent(_ sender: UIButton){
        print("Here")
        //Finding button that was pressed derived from example on https://forums.developer.apple.com/thread/67265
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell){
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("Button not contained in a table view cell")
            return
        }
        guard let indexPath = inviteTableView.indexPath(for: cell) else {
            print("Failed to get index path for cell containing the button")
            return
        }
        //End of Citation
        let eventTitle = invites[indexPath.row]
        let eventId = inviteIds[indexPath.row]
        invites.remove(at: indexPath.row)
        inviteIds.remove(at: indexPath.row)
        var ref: DatabaseReference!
        ref = Database.database().reference()
        if let user = Auth.auth().currentUser{
            let uid = user.uid
            let rsvpChild:[String : AnyObject] = ["/events/\(eventId)/rsvp-list/\(uid)": "true" as NSString]
            ref.updateChildValues(rsvpChild){
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                }
                ref.child("users").child(uid).child("invites").child(eventId).removeValue()
            }
        }
        inviteTableView.reloadData()
    }
    
    @IBOutlet var inviteTableView: UITableView!
    
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
                let userInviteChild:[String : NSString] = ["/users/\(uid)/name": name as! NSString]
                ref.updateChildValues(userInviteChild){
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                    }
                    self.loadTableData(isIn: true, userName: name!)
                    self.loadInviteData(isIn: true, userName: name!)
                    self.accountHeader.text = "Hello, \(name!)"
                }
                
            }
        }
        
        //eventsCreatedTableView.reloadData()
       
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
        accountHeader.text = "Account"
        loadInviteData(isIn: false, userName: "")
        eventsCreatedTableView.reloadData()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        eventsCreatedTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        eventsCreatedTableView.delegate = self
        eventsCreatedTableView.dataSource = self
        
        inviteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "inviteCell")
        inviteTableView.delegate = self
        inviteTableView.dataSource = self
        
        if let user = Auth.auth().currentUser{
            //loadTableData(isIn:true, userName: user.displayName!)
            accountHeader.text = "Welcome, \(user.displayName!)"
        }
        // Do any additional setup after loading the view, typically from a nib.
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.delegate = self
//        loginButton.center = view.center
        loginButton.frame.origin.y = 625
        loginButton.frame.origin.x = self.view.frame.width/2 - loginButton.frame.width
     //   loginButton.frame.origin.x = view.centerXAnchor.
        view.addSubview(loginButton)
        
//        if let accessToken = AccessToken.current{
//            print("Hello")
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser{
            loadTableData(isIn: true, userName: user.displayName!)
            loadInviteData(isIn: true, userName: user.displayName!)
            accountHeader.text = "Welcome, \(user.displayName!)"
        }
        else{
            loadTableData(isIn: false, userName: "")
            loadInviteData(isIn: false, userName: "")
            accountHeader.text = "Account"
        }
    }
    
    func loadInviteData(isIn:Bool, userName:String){
        invites = []
        inviteIds = []
        if(isIn){
            let userId = Auth.auth().currentUser!.uid
            var ref: DatabaseReference!
            
            ref = Database.database().reference()
            
            print ("firebase time")
            ref.child("users").child(userId).child("invites").observeSingleEvent(of: .value, with: {
                snapshot in
                print("\(snapshot.key) -> \(String(describing: snapshot.value))")
                if snapshot.hasChildren(){
                    let someData = snapshot.value! as! Dictionary<String, NSDictionary>
                    
                    for (key, value) in someData {
                        print("key is \(key)")
                        print("value is \(value)")
                        print("Test: \(value.allKeys[0])")
                        self.inviteIds.append(key)
                        self.invites.append(value.allKeys[0] as! String)
                        
                        self.inviteTableView.reloadData()
                    }
                }
            })
            print("done fire")        }
        else{
            invites = ["Please Login to View Your Invites"]
            inviteIds = ["Please Login"]
        }
        inviteTableView.reloadData()
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
                  //  print("value is \(value["Creator"]!)")
                    
                    if let eventCreator = value["CreatorId"]{
                        let creatorId = eventCreator as! String
                        if(userId == creatorId){
                            print("Hit")
                            self.eventsCreated.append(value["Title"] as! String)
                        }
                    }
                    print("value is \(value["Title"]!)")
                    print("key is \(key)")
                    //self.myArray.append(value)
                    self.eventsCreatedTableView.reloadData()
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

