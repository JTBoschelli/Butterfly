//
//  EventDetailViewController.swift
//  Butterfly
//
//  Created by Jarryd Nissenbaum on 11/23/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import UIKit
import MapKit


class EventDetailViewController: UIViewController {

    @IBOutlet weak var TheMap: MKMapView!
    
    func focusMapView() {
        let mapCenter = CLLocationCoordinate2DMake(38.6488, -90.3108)
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegionMake(mapCenter, span)
        TheMap.region = region
    }
    
    func displayLocation() {
        let pin = MKPointAnnotation()
        pin.title = "EVENT"
        let latitude: CLLocationDegrees = 38.6488
        let longitude: CLLocationDegrees = -90.3108
        
        let location = CLLocationCoordinate2DMake(latitude, longitude)

       // let theLocation = CLLocation(latitude: 38.6488, longitude: 90.3108)
        pin.coordinate = location
        TheMap.addAnnotation(pin)
        print("loaded")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLocation()
        focusMapView()
        // Do any additional setup after loading the view.
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
