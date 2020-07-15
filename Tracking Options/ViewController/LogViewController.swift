//
//  LogViewController.swift
//  Tracking Options
//
//  Created by GeoSpark Mac 15 on 13/07/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import UIKit

class LogViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    var dataCount:[Dictionary<String,Any>] = []
    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var exportLogs: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        serverLogs(currentTimestamp())
        NotificationCenter.default.addObserver(
            self, selector: #selector(newlocation), name: .newLocationSaved,object: nil)
    }
    
    @objc func newlocation(){
        serverLogs(currentTimestamp())
    }

    @objc func serverLogs(_ dateStr:String){
        let datas  = UserDefaults.standard.array(forKey: "GeoSparkKeyForLatLongInfo") as? [[String:Any]]
        if  datas != nil{
            for data in (datas?.enumerated())! {
                let dateVal = data.element
                let dateString = dateVal["timeStamp"] as! String
                if dateString.contains(dateStr){
                    dataCount.append(dateVal)
                }
            }
            DispatchQueue.main.async {
                self.dataCount = self.dataCount.reversed()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func newLocationAdded(_ notification: Notification) {
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataCount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let dic:Dictionary<String,Any> = dataCount[indexPath.row]
        cell.textLabel?.text = dic["activity"] as? String
        cell.detailTextLabel?.text = dic["timeStamp"] as? String
        return cell
    }
    
    @IBAction func exportAction(_ sender: Any) {
        showHud()
        let dataArray = UserDefaults.standard.array(forKey: "GeneratePDF") as? [Dictionary<String,Any>]
        if dataArray?.count == 0 {
            
        }else{
            let dict:Dictionary<String,Any> = ["location":dataArray!]
            saveToJsonFile(dict)
            self.getJsonFile()
        }
    }
    
    func currentTimestamp() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date()
        return dateFormatter.string(from: date)
    }
    
    
    func saveToJsonFile(_ dict:Dictionary<String,Any>) {
        // Get the url of Persons.json in document directory
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("location.json")
        // Transform array into data and save it into file
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            try data.write(to: fileUrl, options: [])
        } catch {
            print(error)
        }
    }
    func getJsonFile(){
        
        self.dismissHud()
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("location.json")
        let vc = UIActivityViewController(activityItems: [fileUrl], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }

    
}
extension Dictionary {
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func printJson() {
        print(json)
    }
    
}
