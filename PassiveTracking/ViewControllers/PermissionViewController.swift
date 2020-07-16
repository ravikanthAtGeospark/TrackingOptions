//
//  ViewController.swift
//  Tracking Options
//
//  Created by GeoSpark Mac 15 on 13/07/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit
import CoreLocation


public typealias locationStatus = ((_ status:CLAuthorizationStatus) -> Void)?

class PermissionViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc fileprivate func applicationWillEnterForeground(_ notification: NSNotification) {
        print(CLLocationManager.authorizationStatus().rawValue)
        if CLLocationManager.authorizationStatus().rawValue == 3 {
            Utils.moveHome()
        }
    }

    @IBAction func locationAction(_ sender: Any) {
        locationBtn.setTitle("Provide Permission", for: .normal)
        PassiveTrackingOptions.shareInstance.requestLocationPermission { (status) in
            if status != .authorizedAlways{
                if let url = URL(string:UIApplication.openSettingsURLString)
                {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
}

