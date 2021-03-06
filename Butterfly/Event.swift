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
    let inviteList: [String:String]?
    let eventId: String?
    let open: String?
    
    init(title: String,locationName:String, eventId:String,  date:String, coordinate: CLLocationCoordinate2D,inviteList:[String:String]?, open:String) {
        self.title = title
        self.coordinate = coordinate
        self.date = date
        self.eventId = eventId
        self.locationName = title
        self.inviteList = inviteList
        self.open = open
        super.init()
    }
    

    var subtitle: String? {
        return title
    }
}

