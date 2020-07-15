//
//  AppDelegate.swift
//  Tracking Options
//
//  Created by GeoSpark Mac 15 on 13/07/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,TrackingManagerDelegate{
    

    let center = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    

        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }

        TrackingManager.shareInstance.startTracking()
        TrackingManager.shareInstance.delegate = self

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    fileprivate func updateNotification(_ location: CLLocation,_ desc:String){
         let content = UNMutableNotificationContent()
         content.title = "\(desc)"
         content.body = location.description
         content.sound = UNNotificationSound.default
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
         let request = UNNotificationRequest(identifier: "\(location.timestamp)", content: content, trigger: trigger)
         center.add(request, withCompletionHandler: nil)
         
     }
    
    func didUpdateLocation(_ location: CLLocation, _ desc: String, _ radius: Int) {
        Utils.savePDFData(location, desc, radius)
        saveLocationToLocal(location, desc)
        print("didUpdateLocation",location.description)
        self.updateNotification(location, desc)
        
        NotificationCenter.default.post(name: .newLocationSaved, object: nil)
    }
    
    
    fileprivate func saveLocationToLocal(_ location: CLLocation,_ desc:String) {
        let dataDictionary = ["latitude" : location.coordinate.latitude, "longitude" : location.coordinate.longitude,"activity": desc +  "    " + location.description ,"timeStamp" :currentTimestampWithHours() ] as [String : Any]
        var dataArray = UserDefaults.standard.array(forKey: "GeoSparkKeyForLatLongInfo")
        if let _ = dataArray {
            dataArray?.append(dataDictionary)
        }else{
            dataArray = [dataDictionary]
        }
        UserDefaults.standard.set(dataArray, forKey: "GeoSparkKeyForLatLongInfo")
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func currentTimestampWithHours() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        return dateFormatter.string(from: date)
    }

    
}

extension Notification.Name {
    static let newLocationSaved = Notification.Name("newLocationSaved")
}
