//
//  AppDelegate.swift
//  PassiveTracking
//
//  Created by GeoSpark Mac 15 on 16/07/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    let center = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        if CLLocationManager.authorizationStatus().rawValue == 3 {
            ReActiveTrackingOptions.shareInstance.startTracking()
        }

        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }
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

    func showNotification(_ location: CLLocation,_ desc:String){
         let content = UNMutableNotificationContent()
         content.title = "\(desc)"
         content.body = location.description
         content.sound = UNNotificationSound.default
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
         let request = UNNotificationRequest(identifier: "\(location.timestamp)", content: content, trigger: trigger)
         center.add(request, withCompletionHandler: nil)
         
     }


}

