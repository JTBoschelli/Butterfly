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
    
    @IBOutlet weak var theDate: UILabel!
    
    
    
    
    //let invite_list:[String:String]? = nil
    var name:String
    var date:String
    var lat:Double
    var long:Double
   // let coordinate = CLLocationCoordinate2DMake(lat, long)
    
    required init?(coder aDecoder: NSCoder) {
        name = ""
        date = ""
        lat = 0.0
        long = 0.0
        
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
//        let latitude: CLLocationDegrees = 38.6488
//        let longitude: CLLocationDegrees = -90.3108
        
        let latitude: CLLocationDegrees = lat1
        let longitude: CLLocationDegrees = long1
        let location = CLLocationCoordinate2DMake(latitude, longitude)

       // let theLocation = CLLocation(latitude: 38.6488, longitude: 90.3108)
        pin.coordinate = location
        TheMap.addAnnotation(pin)
        print("loaded")
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLocation(title1:name, lat1:lat, long1:long)
        focusMapView(lat2:lat, long2:long)
        
        self.title = name
        theDate.text = date
        
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
