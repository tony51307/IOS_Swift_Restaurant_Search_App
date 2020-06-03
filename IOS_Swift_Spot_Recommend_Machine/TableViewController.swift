//
//  TableViewController.swift
//  IOS_Swift_Spot_Recommend_Machine
//
//  Created by Tony Lee on 2020/5/27.
//  Copyright © 2020 Tony Li. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DetailCell: UITableViewCell{
    
    @IBOutlet weak var detail: UILabel!
}

class TableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate, URLSessionDelegate, URLSessionDownloadDelegate {
    
    var dataArray = [AnyObject]()
    var locationManager = CLLocationManager()
    var  currentLocation = CLLocation()
    var search_distance: Float = 3000
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            shopList.removeAll()
            let dataDic = try JSONSerialization.jsonObject(with: NSData(contentsOf: location as URL)! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:[String:AnyObject]]
            
            dataArray = dataDic["result"]!["results"] as! [AnyObject]
            for p in dataArray{
                if (p["類別"] as! String == "餐廳"){
                    let targetLocation = CLLocation (latitude: Double(p["緯度"] as! String)!, longitude: Double(p["經度"] as! String)!)
                    let d = Float(currentLocation.distance(from: targetLocation))
                    let newShop: shopdata = shopdata(num: p["_id"] as AnyObject, name: p["單位名稱"] as AnyObject,address: p["地址"] as AnyObject, latitude: Double(p["緯度"] as! String)!, longitude: Double(p["經度"] as! String)!, distance: d, disable: p["場所提供行動不便者使用廁所"] as! String, friendly: p["貼心公廁"] as! String)
                    shopList.append(newShop)
                }
            }
            shopList.sort { (lhs, rhs) in return lhs.distance < rhs.distance }
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        } catch {
            print("Error!")
        }
    }
    
    @IBOutlet weak var distance_display: UILabel!

    @IBAction func distance_stepper(_ sender: UIStepper) {
        if search_distance != Float(sender.value){
            search_distance = Float(sender.value)
                self.tableView.reloadData()
            }
        search_distance = Float(sender.value)
        distance_display.text = "搜尋距離: "+String(format: "%.2f", search_distance/1000)+" KM"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distance_display.text = "搜尋距離: "+String(format: "%.2f", search_distance/1000)+" KM"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl!)
        refreshControl!.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let url = NSURL(string: "https://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=008ed7cf-2340-4bc4-89b0-e258a5573be2")
        
        let sessionWithConfigure = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionWithConfigure, delegate: self, delegateQueue: OperationQueue.main)
        
        let dataTask = session.downloadTask(with: url! as URL)
        refreshControl!.beginRefreshing()
        dataTask.resume()
        self.tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
        self.tableView.reloadData()
    }
    
    @objc func loadData(){
        self.locationManager.startUpdatingLocation()
        
        let url = NSURL(string: "https://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=008ed7cf-2340-4bc4-89b0-e258a5573be2")
        
        let sessionWithConfigure = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionWithConfigure, delegate: self, delegateQueue: OperationQueue.main)
        
        let dataTask = session.downloadTask(with: url! as URL)
        
        dataTask.resume()
        self.tableView.reloadData()
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = (manager.location)!
    }
    
    var shopList:[shopdata] = []
    var displayList:[shopdata] = []
    
    struct shopdata{
        var num: AnyObject
        var name: AnyObject
        var address: AnyObject
        var latitude = 0.0
        var longitude = 0.0
        var distance: Float
        var disable = ""
        var friendly = ""
    }

    // MARK: - Table view data source

    
  
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        displayList.removeAll()
        for shop in shopList{
            if Float(shop.distance)<=search_distance{
                displayList.append(shop)
            }
        }
        if displayList.count == 0{
           return 1
        }else{
            return displayList.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DetailCell

        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell") as! DetailCell
        }
        
        if displayList.count == 0{
            cell.accessoryType = .none
            cell.detail?.text = ""
            cell.textLabel?.text = "目前查無餐廳，請稍等或是移動及更改搜尋距離"
            self.tableView.allowsSelection = false
        }else{
            self.tableView.allowsSelection = true
            cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = shopList[indexPath.row].name as? String
        if shopList[indexPath.row].distance < 1000{
            cell.detail?.text = "距離: <1km"
        }else if shopList[indexPath.row].distance > 10000{
            cell.detail?.text = "距離: >10km"
        }else{
            cell.detail?.text = "距離: "+String(format: "%.2f", shopList[indexPath.row].distance/1000)+" km"
        }
        }
        
        return cell
    }
    
    var path = 0
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        path = indexPath.row
        performSegue(withIdentifier: "mySegue", sender: self)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let vc_text = segue.destination as! DetailViewController
        vc_text.Name = shopList[path].name as! String
        vc_text.Address = shopList[path].address as! String
        
        vc_text.currentlocation = currentLocation
        vc_text.targetlocation =  CLLocationCoordinate2DMake(shopList[path].latitude, shopList[path].longitude)
        vc_text.disable = shopList[path].disable
        vc_text.friendly = shopList[path].friendly

        
    }


}

