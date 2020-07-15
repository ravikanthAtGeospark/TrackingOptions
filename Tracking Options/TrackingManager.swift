//
//  TrackingManager.swift
//  Tracking Options
//
//  Created by GeoSpark Mac 15 on 13/07/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


@objc public protocol TrackingManagerDelegate {
    @objc func didUpdateLocation(_ location: CLLocation, _ desc:String,_ radius:Int)
}

class TrackingManager: NSObject {
    static let shareInstance = TrackingManager()
    fileprivate var locationManager:CLLocationManager?
    fileprivate var locationHandler: locationStatus?
    var delegate: TrackingManagerDelegate?
    let uuidString = UIDevice.current.identifierForVendor!.uuidString
    var locations:[CLLocation] = []
    
    func setDelegate(){
        if locationManager == nil{
            locationManager = CLLocationManager()
        }
        
        if locationManager?.delegate == nil {
            locationManager?.delegate = self
        }
    }
    
    func requestLocationPermission(_ handler:locationStatus){
        setDelegate()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        self.locationHandler = handler
    }
    
    func startTracking(){
        setDelegate()
        locationManager!.delegate = self
        locationManager!.allowsBackgroundLocationUpdates = true
        locationManager!.pausesLocationUpdatesAutomatically = false
        locationManager!.startMonitoringVisits()
        locationManager!.startMonitoringSignificantLocationChanges()
        
    }
    
    func stopTracking(){
        locationManager?.stopMonitoringVisits()
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.stopUpdatingLocation()
    }
    
    func updateLocationData(_ location:CLLocation, _ desc:String){
        print("updateLocationData",desc)
        let radius = getGeofenceRadius(location)
        createGeofence(location, radius)
        Utils.saveLastLcoation(location)
        delegate?.didUpdateLocation(location, desc, radius)
    }
    
    func createGeofence(_ location:CLLocation, _ radius:Int){
        print("CreateGeofence \(radius)")
        cleareGeofence()
        let region = CLCircularRegion(center: location.coordinate, radius: CLLocationDistance(radius), identifier:uuidString)
        region.notifyOnExit = true
        locationManager?.startMonitoring(for: region)
    }
    
    func cleareGeofence(){
        locationManager!.monitoredRegions.forEach { region in
            locationManager!.stopMonitoring(for: region)
        }
    }
    
    func getGeofenceRadius(_ location:CLLocation) -> Int{
        let lastLocation = Utils.getLastLocation()
        if lastLocation.coordinate.latitude == 0 && lastLocation.coordinate.longitude == 0{
            return 100
        }else{
            let timeDifference = location.timestamp.timeIntervalSince(lastLocation.timestamp)
            print("Time difference \(timeDifference.minutes) \("      ") \(timeDifference.minutes <= 1)")
            print("Lcoation Count \(locations.count) \("      location count") \(locations.count >= 5)")
            if timeDifference.minutes <= 1 {
                locations.insert(location, at: 0)
                if locations.count >= 5{
                    let speed = Utils.getSpeed(locations)
                    locations.removeLast()
                    return speed
                }
                return 100
            } else if timeDifference.minutes  > 1 || location.speed >= 0{
                if locations.count != 0{
                    locations.removeLast()
                }
                
                locations.insert(location, at: 0)
                return 100
            } else{
                if locations.count >= 5{
                    let speed = Utils.getSpeed(locations)
                    locations.removeLast()
                    return speed
                }else{
                    locations.insert(location, at: 0)
                    return 100
                }
            }
        }
    }
    
}

extension TrackingManager:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            self.locationHandler!!(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.max(by: { (location1, location2) -> Bool in
            return location1.timestamp.timeIntervalSince1970 < location2.timestamp.timeIntervalSince1970}) else { return }
        self.updateLocationData(location,"SignificantLocation")
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        self.updateLocationData(manager.location!,"Visit")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion",manager.location!)
        self.updateLocationData(manager.location!,"didExitRegion")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
}
