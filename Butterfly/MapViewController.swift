//
//  MapViewController.swift
//  Butterfly
//
//  Created by Justin Boschelli on 11/23/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import FirebaseDatabase
import FirebaseAuth


class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var eventsArray: [Event] = []
    var location: CLLocation? = nil
    var locationManager:CLLocationManager!
    var uid: String!
    var displayName: String!
    
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
        mapView.showsUserLocation = true
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        //manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Events (Map)"
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            uid = user.uid
            displayName = user.displayName
        }

        loadInitialData()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            uid = user.uid
            displayName = user.displayName
        }
        
        loadInitialData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    @IBOutlet weak var mapView: MKMapView!
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "events", sender: view)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as? EventDetailViewController
        destination?.name = (sender as! MKAnnotationView).annotation!.title as! String
        //destination?.date = (sender as! MKAnnotationView).annotation!.
        
        let temp = (sender as! MKAnnotationView).annotation!
        for event in eventsArray{
            if(temp.title == event.title && temp.coordinate.latitude == event.coordinate.latitude && temp.coordinate.longitude == temp.coordinate.longitude ){
                destination?.date = event.date!
                destination?.lat = event.coordinate.latitude
                destination?.long = event.coordinate.longitude
                destination?.invites = event.inviteList!
                destination?.eventId = event.eventId!
                destination?.open = event.open!
            }
        }
        
    }
    
    
    func loadInitialData() {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        ref.child("events").observeSingleEvent(of: .value, with: {
            snapshot in
            let someData = snapshot.value! as! Dictionary<String, NSDictionary>
            
            for (key,value) in someData {
                let lat:Double = value["Latitude"]! as! Double
                let long:Double = value["Longitude"]! as! Double
                let coordinate = CLLocationCoordinate2DMake(lat, long)
                let inviteList = value["invite-list"] as? [String:String] ?? ["No List":"true"]
                let newEvent = Event(title: value["Title"]! as! String, locationName: value["Title"]! as! String, eventId: key, date: value["Date"]! as! String, coordinate: coordinate, inviteList: inviteList, open: value["Open"]! as! String)
                let open:String = value["Open"]! as! String
                if(open == "true"){
                    self.mapView.addAnnotation(newEvent)
                    self.eventsArray.append(newEvent)
                }
                else{
                    let invite_list:[String:String] = value["invite-list"]! as! [String:String]
                    for invite in invite_list{
                        if(invite.key == self.uid){
                            self.mapView.addAnnotation(newEvent)
                            self.eventsArray.append(newEvent)
                        }
                    }
                    
                    
                }
                

            }
            
        })
        
    }
    

}



extension MapViewController: MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Event else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
