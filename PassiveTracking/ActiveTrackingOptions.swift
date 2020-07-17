//
//  PassiveTrackingOptions.swift
//  PassiveTracking
//
//  Created by GeoSpark Mac 15 on 16/07/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import CoreLocation


class ActiveTrackingOptions: NSObject{
    
    static let shareInstance = ActiveTrackingOptions()
    fileprivate var locationManager:CLLocationManager?
    fileprivate var locationHandler: locationStatus?
    
    fileprivate func setDelegate(){
        if locationManager == nil{
            locationManager = CLLocationManager()
        }
        if locationManager?.delegate == nil {
            locationManager?.delegate = self
        }
    }
    
    func requestLocationPermission(_ handler:locationStatus){
        setDelegate()
        locationManager!.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationHandler = handler
    }
    
    func startTracking(){
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.distanceFilter = 30
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = true
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.startMonitoringVisits()
        locationManager?.startUpdatingLocation()
        
    }
    
    func stopTracking(){
        locationManager?.stopUpdatingLocation()
        locationManager?.stopMonitoringVisits()
        locationManager?.stopMonitoringSignificantLocationChanges()
    }
    
    func updateLocation(_ location:CLLocation,_ type:String){
        
        let radius = getRadius(location)
        Utils.savePDFData(location, type, radius)
        LoggerManager.sharedInstance.writeLocationToFile("\(type) \("    ") \(location.description)")
        Utils.saveLocationToLocal(location, type)
        AppDelegate().showNotification(location, type)
        updateLocationManager(radius)
        createGeofence(location, radius)
        
        
        NotificationCenter.default.post(name: .newLocationSaved, object: nil)
    }
    
    func getRadius(_ location:CLLocation) -> Int{
        let radius = Utils.getLastLocation()
        if radius.coordinate.latitude == 0 && radius.coordinate.longitude == 0{
            return 100
        }else{
            let timeDifference = location.timestamp.timeIntervalSince(radius.timestamp)
            if timeDifference <= 59{
                Utils.saveSpeed(location)
                let countValue = Utils.getAllSpeed()
                if countValue.count >= 5{
                    let rad = Utils.getSpeed(countValue)
                    Utils.deleteSpeed()
                    return rad
                }
                return 100
            }
            else if timeDifference >= 60 {
                Utils.resetSpeed()
                Utils.saveSpeed(location)
                return 100
                
            }
            else if location.speed >= 0{
                Utils.resetSpeed()
                Utils.saveSpeed(location)
                return 100
            }
            else{
                Utils.saveSpeed(location)
                let countValue = Utils.getAllSpeed()
                if countValue.count >= 5{
                    let rad = Utils.getSpeed(countValue)
                    Utils.deleteSpeed()
                    return rad
                }
                
                return 100
            }
        }
    }
    
    func createGeofence(_ location:CLLocation,_ speed:Int){
        let region = CLCircularRegion(center: location.coordinate, radius: CLLocationDistance(speed), identifier: "geofenceRadius")
        locationManager?.startMonitoring(for: region)
    }
    
    func updateLocationManager(_ speed:Int ){
        if speed == 30 {
            locationManager?.distanceFilter = 30
        }else if speed == 60 {
            locationManager?.distanceFilter = 60
        }else if speed == 90 {
            locationManager?.distanceFilter = 90
        }else if speed == 120 {
            locationManager?.distanceFilter = 120
        }else if speed == 250 {
            locationManager?.distanceFilter = 250
        }else if speed == 500 {
            locationManager?.distanceFilter = 500
        }else if speed == 750 {
            locationManager?.distanceFilter = 750
            
        }else{
            locationManager?.distanceFilter = 30
        }
    }
}

extension ActiveTrackingOptions:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationHandler!!(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.updateLocation(manager.location!,"ExitRegion")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.max(by: { (location1, location2) -> Bool in
            return location1.timestamp.timeIntervalSince1970 < location2.timestamp.timeIntervalSince1970}) else { return }
        if location.horizontalAccuracy <= 100{
            self.updateLocation(location,"SignificantLocation")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        self.updateLocation(manager.location!,"didVisit")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        LoggerManager.sharedInstance.writeLocationToFile("Did fail error \(error.localizedDescription)")
    }
    
}
