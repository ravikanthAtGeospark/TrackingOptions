//
//  LocationPoint.swift
//  Tracking Options
//
//  Created by GeoSpark Mac 15 on 13/07/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import Foundation
import CoreLocation

//class LocationPoint: NSObject, NSCoding {
//    var latitude: Double
//    var longitude: Double
//    var speed: Double
//    var timestamp: Date
//
//   var age: Int
//    
//    init(_ location:CLLocation) {
//        self.latitude = location.coordinate.latitude
//        self.longitude = location.coordinate.longitude
//        self.speed = location.speed
//        self.timestamp = location.timestamp
//
//   }
//   required convenience init(coder aCoder: NSCoder) {
//    let lat = aCoder.decodeDouble(forKey: "latitude")
//    let lng = aCoder.decodeDouble(forKey: "longitude")
//    let speedVal = aCoder.decodeDouble(forKey: "speed")
//    let timestamp = aCoder.decodeObject(forKey: "timestamp") as! Date
//    
//    self.init(CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: speedVal, timestamp: timestamp))
//   }
//    
//   func encode(with acoder: NSCoder) {
//    acoder.encode(latitude, forKey: "latitude")
//    acoder.encode(longitude, forKey: "longitude")
//    acoder.encode(speed, forKey: "speed")
//    acoder.encode(timestamp, forKey: "timestamp")
//   }
//}
