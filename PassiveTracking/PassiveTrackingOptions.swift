
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
        locationManager!.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationHandler = handler
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
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    fileprivate func singleGoefence(_ location:CLLocation, _ radius:CLLocationDistance){
        clearGeofence()
        let region = CLCircularRegion(center: location.coordinate, radius: radius, identifier: "KGeofenceRegionIdentifier")
        region.notifyOnExit = true
        locationManager?.startMonitoring(for: region)
    }
    
    fileprivate func clearGeofence(){
        locationManager!.monitoredRegions.forEach { region in
            locationManager!.stopMonitoring(for: region)
        }
    }
    
    fileprivate func updateLocation(_ location:CLLocation, _ activity:String){
        print("\(activity) \(location.description)")
        let radius = Utils.getPassiveRadius(location)
        Utils.saveLastLcoation(location)
        Utils.savePDFData(location, activity, radius)
        LoggerManager.sharedInstance.writeLocationToFile("\(activity) \("    ") \(location.description)")
        Utils.saveLocationToLocal(location, activity)
        AppDelegate().showNotification(location, activity)
        self.singleGoefence(location, CLLocationDistance(radius))
        
        
        NotificationCenter.default.post(name: .newLocationSaved, object: nil)
        
    }
    
}

extension PassiveTrackingOptions{
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        self.updateLocation(manager.location!, "Visit")
        print("MotionPassiveTracking didVisit")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.updateLocation(manager.location!, "ExitRegion")
        print("MotionPassiveTracking didExitRegion")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.max(by: { (location1, location2) -> Bool in
            return location1.timestamp.timeIntervalSince1970 < location2.timestamp.timeIntervalSince1970}) else { return }
        self.updateLocation(location, "SignificantLocation")
        print("MotionPassiveTracking didUpdateLocations")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationHandler!!(status)
        }
    }
    
}
