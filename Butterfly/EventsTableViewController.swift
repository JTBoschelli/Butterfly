//
//  EventsTableViewController.swift
//  Butterfly
//
//  Created by Julia Dickerman on 11/30/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class EventsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var eventsArray: [Event] = []
    @IBOutlet weak var eventsTable: UITableView!
    var uid: String!
    var displayName: String!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
        cell.textLabel!.text = eventsArray[indexPath.row].title
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            uid = user.uid
            displayName = user.displayName
        }
        else{
            uid = ""
            displayName = ""
        }
        DispatchQueue.main.async() {
            self.loadInitialData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Events (List)"
        eventsTable.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        eventsTable.dataSource = self
        eventsTable.delegate = self
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            uid = user.uid
            displayName = user.displayName
        }
        else{
            uid = ""
            displayName = ""
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         guard let index = sender as? IndexPath else { return }
        
        
        let destination = segue.destination as? EventDetailViewController
        destination?.name = eventsArray[index.row].title!
        destination?.date = eventsArray[index.row].date!
        destination?.long = eventsArray[index.row].coordinate.longitude
        destination?.lat = eventsArray[index.row].coordinate.latitude
        destination?.invites = eventsArray[index.row].inviteList!
        destination?.eventId = eventsArray[index.row].eventId!
        destination?.open = eventsArray[index.row].open!
    }
    
    
    
    
    
    
    func loadInitialData() {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        ref.child("events").observeSingleEvent(of: .value, with: {
            snapshot in
            let someData = snapshot.value! as! Dictionary<String, NSDictionary>
            self.eventsArray = []
            for (key,value) in someData {
                let lat:Double = value["Latitude"]! as! Double
                let long:Double = value["Longitude"]! as! Double
                let coordinate = CLLocationCoordinate2DMake(lat, long)
                let inviteList = value["invite-list"] as? [String:String] ?? ["No List":"true"]
                let newEvent = Event(title: value["Title"]! as! String, locationName: value["Title"]! as! String, eventId: key, date: value["Date"]! as! String, coordinate: coordinate, inviteList: inviteList, open: value["Open"]! as! String)
                let open:String = value["Open"]! as! String
                let creator = value["CreatorId"]! as! String
                if(open == "true" || creator == self.uid){
                    self.eventsArray.append(newEvent)
                }
                else{
                    let invite_list:[String:String] = value["invite-list"]! as! [String:String]
                    for invite in invite_list{
                        if(invite.key == self.uid){
                            self.eventsArray.append(newEvent)
                        }
                    }
                }
            }
            self.eventsTable.reloadData()
        })
        
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
