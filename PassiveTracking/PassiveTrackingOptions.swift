
//
//  MotionPassiveTracking.swift
//  Motion
//
//  Created by GeoSpark Mac 15 on 14/07/20.
//

import UIKit
import CoreLocation

internal class PassiveTrackingOptions: NSObject,CLLocationManagerDelegate {
    
    static let shareInstance = PassiveTrackingOptions()
    var locationManager:CLLocationManager?
    fileprivate var currentBGTask: UIBackgroundTaskIdentifier?

    fileprivate var locationHandler: locationStatus?
    
    required override init () {
        super.init()
        self.setDelegate()
    }
    
    fileprivate func setDelegate(){
        if self.locationManager == nil {
            self.locationManager = CLLocationManager()
        }
        if self.locationManager!.delegate == nil {
            self.locationManager!.delegate = self
        }
    }
    
    func requestLocationPermission(_ handler:locationStatus){
        setDelegate()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationHandler = handler
    }
    
    func startTracking(){
        currentBGTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            if self.currentBGTask != UIBackgroundTaskIdentifier.invalid{
                UIApplication.shared.endBackgroundTask(self.currentBGTask!)
                self.currentBGTask = UIBackgroundTaskIdentifier.invalid
            }
        })

        setDelegate()
        
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.delegate = self
        locationManager?.distanceFilter = 500
        locationManager?.startMonitoringVisits()
        locationManager?.startMonitoringSignificantLocationChanges()
    
        LoggerManager.sharedInstance.writeLocationToFile("startTracking \(locationManager?.description)")
    }
    func stopTracking(){
        locationManager?.stopMonitoringVisits()
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    fileprivate func singleGoefence(_ location:CLLocation, _ radius:CLLocationDistance){
        LoggerManager.sharedInstance.writeLocationToFile("Create  geofence")

        clearGeofence()
        let region = CLCircularRegion(center: location.coordinate, radius: 100, identifier: "KGeofenceRegionIdentifier")
        region.notifyOnExit = true
        region.notifyOnEntry = true
        LoggerManager.sharedInstance.writeLocationToFile("\(region.description)")
        locationManager?.startMonitoring(for: region)
    }
    
    fileprivate func clearGeofence(){
        LoggerManager.sharedInstance.writeLocationToFile("clearGeofence")
        locationManager!.monitoredRegions.forEach { region in
            locationManager!.stopMonitoring(for: region)
        }
    }
    
    fileprivate func updateLocation(_ location:CLLocation, _ activity:String){
        self.singleGoefence(location, 100)

        print("\(activity) \(location.description)")
        let radius = Utils.getPassiveRadius(location)
        Utils.saveLastLcoation(location)
        Utils.savePDFData(location, activity, radius)
        LoggerManager.sharedInstance.writeLocationToFile("\(activity) \("    ") \(location.description)")
        Utils.saveLocationToLocal(location, activity)
        AppDelegate().showNotification(location, activity)
        
        
        NotificationCenter.default.post(name: .newLocationSaved, object: nil)
        
    }
    
}

extension PassiveTrackingOptions{
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        self.updateLocation(manager.location!, "Visit")
        LoggerManager.sharedInstance.writeLocationToFile("Visit")
        print("MotionPassiveTracking didVisit")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.updateLocation(manager.location!, "ExitRegion")
        LoggerManager.sharedInstance.writeLocationToFile("ExitRegion")
        print("MotionPassiveTracking didExitRegion")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.updateLocation(manager.location!, "DidEnter")
        LoggerManager.sharedInstance.writeLocationToFile("didEnterRegion")
        print("MotionPassiveTracking DidEnter")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.max(by: { (location1, location2) -> Bool in
            return location1.timestamp.timeIntervalSince1970 < location2.timestamp.timeIntervalSince1970}) else { return }
        self.updateLocation(location, "SignificantLocation")
        print("MotionPassiveTracking didUpdateLocations")
        LoggerManager.sharedInstance.writeLocationToFile("SignificantLocation")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            if locationHandler != nil{
                locationHandler!!(status)
            }
        }
    }
    
}
