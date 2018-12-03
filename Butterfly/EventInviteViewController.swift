//
//  EventInviteViewController.swift
//  Butterfly
//
//  Created by Jennifer Stevens on 11/24/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class EventInviteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var event:[String:AnyObject]!
    
    var theTableView:UITableView!
    
    var userArray:[String:String] = [:]
    
    var selectedUsers:[String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Invite Guests"
        loadUserData()
        theTableView = UITableView(frame: view.frame)
        theTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        theTableView.delegate = self
        theTableView.dataSource = self
        theTableView.allowsMultipleSelection = true
        view.addSubview(theTableView)
        
        //Code for programatically adding button derived from example on https://stackoverflow.com/questions/24030348/how-to-create-a-button-programmatically
        let button = UIButton()
        button.frame = CGRect(x: 0, y: view.frame.height - 70, width: view.frame.width, height: 30)
        button.backgroundColor = UIColor.blue
        button.setTitle("Submit Event with Guest List", for: .normal)
        button.addTarget(self, action: #selector(submitEvent), for: .touchUpInside)
        view.addSubview(button)
        //End of Citation

        // Do any additional setup after loading the view.
    }
    
    func loadUserData(){
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        print ("firebase time")
        ref.child("users").observeSingleEvent(of: .value, with: {
            snapshot in
            print("\(snapshot.key) -> \(String(describing: snapshot.value))")
            let someData = snapshot.value! as! Dictionary<String, NSDictionary>
            
            for (key,value) in someData {
                print("value is \(value["name"]!)")
                print("key is \(key)")
                self.userArray[key] = (value["name"]! as! String)
                //self.myArray.append(value)
                
            }
            print("UserArray: \(self.userArray)")
            self.theTableView.reloadData()
            //self.theTableView.reloadData()
        })
        print("done fire")
    }
    
    @objc func submitEvent(sender: UIButton!){
        var ref: DatabaseReference!
        ref = Database.database().reference()
                
        let eventCreatorId = Auth.auth().currentUser!.uid
        
        var inviteList:[String:String] = [:]
        
        for i in 0 ..< selectedUsers.count{
            inviteList[selectedUsers[i]] = "true"
            
        }
        
        event["invite-list"] = inviteList as AnyObject
        
        
        
        
        //Code to update child values taken from firebase docs on https://firebase.google.com/docs/database/ios/read-and-write
        let key = ref.child("events").childByAutoId().key
        
        let childUpdates:[String: AnyObject] = ["/events/\(key!)": event as AnyObject,
                                                "/users/\(eventCreatorId)/events-created/\(key!)/": "true" as NSString]
        ref.updateChildValues(childUpdates){
            //End of Citation
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                //Syntax to create an alert controller derived from example on https://www.appcoda.com/uialertcontroller-swift-closures-enum/
                
                let alertController = UIAlertController(title: "Success!", message: "Event Added Successfully", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                //End of Citation
            }
        }
        
        for i in 0 ..< selectedUsers.count{
            let uid = selectedUsers[i]
            let userInviteChild:[String : AnyObject] = ["/users/\(uid)/invites//\(key!)/\(event["Title"]!)": "true" as NSString]
            ref.updateChildValues(userInviteChild){
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } 
            }
        }

    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
        let values = Array(userArray.values)
        myCell.textLabel!.text = values[indexPath.row]
        
        return myCell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userIDs = Array(userArray.keys)
        selectedUsers.append(userIDs[indexPath.row])
        print(selectedUsers)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let userIDs = Array(userArray.keys)
        for i in 0 ... selectedUsers.count{
            if(selectedUsers[i] == userIDs[indexPath.row]){
                selectedUsers.remove(at: i)
                break
            }
        }
        print(selectedUsers)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
