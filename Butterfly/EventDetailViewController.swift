//
//  EventDetailViewController.swift
//  Butterfly
//
//  Created by Jarryd Nissenbaum on 11/23/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth



class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TheMap: MKMapView!
    
    @IBOutlet weak var theDate: UILabel!
    
    
    var uid: String!
    var displayName: String!
    var invitedPeople:[String] = []
    let group = DispatchGroup()
    //let invite_list:[String:String]? = nil
    var name:String
    var date:String
    var lat:Double
    var long:Double
    var invites:[String:String]
    var open:String
   // let coordinate = CLLocationCoordinate2DMake(lat, long)
    
    required init?(coder aDecoder: NSCoder) {
        name = ""
        date = ""
        lat = 0.0
        long = 0.0
        invites = ["":""]
        open = ""
        super.init(coder: aDecoder)
    }
    
    func focusMapView(lat2:Double, long2:Double) {
        let mapCenter = CLLocationCoordinate2DMake(lat2, long2)
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegionMake(mapCenter, span)
        TheMap.region = region
    }
    
    func displayLocation(title1:String, lat1:Double, long1:Double) {
        let pin = MKPointAnnotation()
        pin.title = title1
        
        let latitude: CLLocationDegrees = lat1
        let longitude: CLLocationDegrees = long1
        let location = CLLocationCoordinate2DMake(latitude, longitude)

        pin.coordinate = location
        TheMap.addAnnotation(pin)
        print("loaded")
    }
    

    @IBOutlet weak var theTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLocation(title1:name, lat1:lat, long1:long)
        focusMapView(lat2:lat, long2:long)
        
        let userKeyArray = Array(invites.keys)
        
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            uid = user.uid
            displayName = user.displayName
        }
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        if (self.open == "false"){
            for key in userKeyArray{
                group.enter()
                ref.child("users").child(key).child("name").observeSingleEvent(of: .value, with: {
                    snapshot in
                    if let unwrapped = snapshot.value{
                        self.invitedPeople.append(unwrapped as! String)
                        self.group.leave()
                    }
                    
                })
            }
        }

        group.notify(queue: .main){
            self.theTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
            self.theTableView.dataSource = self
            self.theTableView.delegate = self
            self.theTableView.reloadData()
        }

        self.title = name
        theDate.text = date
        
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invitedPeople.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
        cell.textLabel!.text = invitedPeople[indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
