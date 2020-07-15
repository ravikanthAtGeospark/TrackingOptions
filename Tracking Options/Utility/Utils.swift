//
//  Utils.swift
//  Tracking Options
//
//  Created by GeoSpark Mac 15 on 13/07/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


class Utils: NSObject {
    
    
    static func moveHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        
    }
    
    static func getDictionary(_ location:CLLocation,_ desc:String,_ radius: Int) -> Dictionary<String,Any>{
        var dict:Dictionary<String,Any> = ["type":"Feature"]
        let geometry:Dictionary<String,Any> = ["type":"Point","coordinates":[location.coordinate.longitude,location.coordinate.latitude]]
        let properties:Dictionary<String,Any> = ["timestamp":Date().iso8601,"altitude":location.altitude,"speed":location.speed,"horizontal_accuracy":location.horizontalAccuracy,"vertical_accuracy":location.verticalAccuracy,"source":desc,"dynamic_radius":radius]
        dict.updateValue(geometry, forKey: "geometry")
        dict.updateValue(properties, forKey: "properties")
        return dict
    }
    
    static func savePDFData(_ location:CLLocation,_ desc:String,_ radius: Int){
        let dataDictionary = getDictionary(location, desc, radius)
        var dataArray = UserDefaults.standard.array(forKey: "GeneratePDF")
        if let _ = dataArray {
            dataArray?.append(dataDictionary)
        }else{
            dataArray = [dataDictionary]
        }
        UserDefaults.standard.set(dataArray, forKey: "GeneratePDF")
        UserDefaults.standard.synchronize()
    }
    
    static func saveLastLcoation(_ location:CLLocation){
        UserDefaults.standard.set(location.coordinate.latitude, forKey: "latitude")
        UserDefaults.standard.set(location.coordinate.longitude, forKey: "longitude")
        UserDefaults.standard.set(location.speed, forKey: "speed")
        UserDefaults.standard.set(location.timestamp, forKey: "timestamp")
        UserDefaults.standard.synchronize()
    }
    
    static func getLastLocation() -> CLLocation{
        let lat = UserDefaults.standard.double(forKey: "latitude")
        let long = UserDefaults.standard.double(forKey: "longitude")
        let timeStamp = UserDefaults.standard.object(forKey: "timestamp")
        if lat == 0 && long == 0 && timeStamp == nil{
            return CLLocation()
        }
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: timeStamp as! Date)
    }
    

    
    
    static func getSpeed(_ locations:[CLLocation]) -> Int{
        var speed:Double = 0
        for location in locations.enumerated() {
            speed += abs(location.element.speed)
            print("speed",speed)
            print(location.element.speed)
        }
        speed = speed/Double(locations.count)
        speed = speed * 3.6
        speed = round(speed)
        print("getSpeed",round(speed))
        if speed >= 0 && speed <= 10{
            return 100
        }else if speed >= 10 && speed <= 20 {
            return 250
        }else if speed >= 20 && speed <= 30 {
            return 500
        }else if speed >= 30 && speed <= 50 {
            return 1000
        }else if speed >= 50 && speed <= 70 {
            return 2500
        }else if speed >= 70 && speed <= 100 {
            return 3000
        }else if speed >= 100{
            return 5000
        }
        else{
            return 100
        }
    }
}

extension TimeInterval {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
}

extension Date {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    static let iso8601Second: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        return formatter
    }()
    
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
}
