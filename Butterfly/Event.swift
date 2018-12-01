//
//  Event.swift
//  Butterfly
//
//  Created by Justin Boschelli on 11/23/18.
//  Copyright © 2018 Justin Boschelli. All rights reserved.
//

import Foundation
import MapKit

class Event: NSObject, MKAnnotation {
    let title: String?
    let date: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String,locationName:String,  date:String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        self.date = date
        self.locationName = title
        super.init()
    }
    

    var subtitle: String? {
        return title
    }
}

