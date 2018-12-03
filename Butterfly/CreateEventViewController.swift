//
//  CreateEventViewController.swift
//  
//
//  Created by Jennifer Stevens on 11/23/18.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MapKit


class CreateEventViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var eventTitle: UITextField!
    @IBOutlet var eventDatePicker: UIDatePicker!
    @IBOutlet var eventLat: UITextField!
    @IBOutlet var eventLong: UITextField!
    @IBOutlet var eventOpen: UISwitch!
    
    var location: CLLocation? = nil
    var locationManager:CLLocationManager!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        determineCurrentLocation()
        
    }
    
    
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        //manager.stopUpdatingLocation()
        
        location = userLocation
        eventLat.text = String(format: "%f", (location?.coordinate.latitude)!)
        eventLong.text = String(format:"%f", (location?.coordinate.longitude)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Event"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func createEvent(_ sender: Any) {
        var eventName:NSString
        var eventDate:NSString
        var eventLongitude:NSNumber
        var eventLatitude:NSNumber
        
        let title = eventTitle.text
        if title != ""{
            eventName = String(title!) as NSString
        }
        else{
            //Syntax to create an alert controller derived from example on https://www.appcoda.com/uialertcontroller-swift-closures-enum/
            let alertController = UIAlertController(title: "ERROR", message: "Must enter a title for your event", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            //End of Citation
            return
        }
        var date = eventDatePicker.date
        date.addTimeInterval(-6*60*60)
        print(date)
        eventDate = date.description as NSString

        let lat = eventLat.text
        if let latitude = Double(lat!){
            eventLatitude = latitude as NSNumber
        }
        else{
            //Syntax to create an alert controller derived from example on https://www.appcoda.com/uialertcontroller-swift-closures-enum/

            let alertController = UIAlertController(title: "ERROR", message: "Must enter a proper coordinate value", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            //End of Citation
            return
        }
        let long = eventLong.text
        if let longitude = Double(long!){
            eventLongitude = longitude as NSNumber
        }
        else{
            //Syntax to create an alert controller derived from example on https://www.appcoda.com/uialertcontroller-swift-closures-enum/

            let alertController = UIAlertController(title: "ERROR", message: "Must enter a proper coordinate value", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            //End of Citation
            return
        }
        
        if (eventOpen.isOn){
            let user = Auth.auth().currentUser
            if let eventCreator = user{
                let uid = eventCreator.uid
                let creator = eventCreator.displayName! as NSString
                var ref: DatabaseReference!
                ref = Database.database().reference()
                
                //Code to update child values taken from firebase docs on https://firebase.google.com/docs/database/ios/read-and-write
                let key = ref.child("events").childByAutoId().key
                let eventDetails:[String : AnyObject] = ["Title": eventName, "Date": eventDate, "Creator": creator, "CreatorId": uid as AnyObject, "Latitude": eventLatitude, "Longitude": eventLongitude, "Open": "true" as NSString]
                
                let childUpdates:[String: AnyObject] = ["/events/\(key!)": eventDetails as AnyObject,
                                    "/users/\(uid)/events-created/\(key!)/": "true" as NSString]
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
                        self.eventTitle.text = ""
                        self.eventLat.text = ""
                        self.eventLong.text = ""
                        self.eventDatePicker.date = NSDate() as Date
                        //End of Citation
                    }
                }
                
                
            }
            else{
                //Syntax to create an alert controller derived from example on https://www.appcoda.com/uialertcontroller-swift-closures-enum/
                
                let alertController = UIAlertController(title: "ERROR", message: "Must be logged in to create event", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                //End of Citation
                return
            }
            
        }
        else{
            let user = Auth.auth().currentUser
            if let eventCreator = user{
                let uid = eventCreator.uid
                let creator = eventCreator.displayName! as NSString
                var ref: DatabaseReference!
                ref = Database.database().reference()
                print(creator)
                let eventDetails:[String : AnyObject] = ["Title": eventName, "Date": eventDate, "Creator": creator, "CreatorId": uid as AnyObject, "Latitude": eventLatitude, "Longitude": eventLongitude, "Open": "false" as NSString]
                let detailedVC = EventInviteViewController()
                detailedVC.event = eventDetails
                navigationController?.pushViewController(detailedVC, animated: true)
            }
            else{
                //Syntax to create an alert controller derived from example on https://www.appcoda.com/uialertcontroller-swift-closures-enum/
                
                let alertController = UIAlertController(title: "ERROR", message: "Must be logged in to create event", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                //End of Citation
                return
            }
        }
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
