//
//  DetailViewController.swift
//  IOS_Swift_Spot_Recommend_Machine
//
//  Created by mac03 on 2020/5/28.
//  Copyright © 2020 Tony Li. All rights reserved.
//

import UIKit
import MapKit
class DetailViewController: UIViewController {
    
    var Address = ""
    var Name = ""
    var currentlocation = CLLocation()
    var targetlocation = CLLocationCoordinate2D()
    var friendly = ""
    var disable = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        name.text = Name
        address.text = Address
        if disable == "v"{
            disableToilet.text = "場所提供行動不便者使用廁所: "+"Yes"
        }else{
            disableToilet.text = "場所提供行動不便者使用廁所: "+"No"
        }
        
        if friendly == "v"{
            friendlyToilet.text = "貼心公廁: "+"Yes"
        }else{
            friendlyToilet.text = "貼心公廁: "+"No"
        }
        
        let target = MKPointAnnotation()
        target.title = name.text
        target.coordinate = targetlocation
        let viewRegion = MKCoordinateRegion(center: targetlocation, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(viewRegion, animated: false)
        mapView.addAnnotation(target)
        mapView.showsUserLocation = true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var disableToilet: UILabel!
    @IBOutlet weak var friendlyToilet: UILabel!
    @IBAction func getDirection(_ sender: UIButton) {
        direct()
    }
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    func direct(){
        
        let pB = MKPlacemark(coordinate: targetlocation, addressDictionary: nil)
        let pA = MKPlacemark(coordinate: currentlocation.coordinate, addressDictionary: nil)

        
        
        
        
        let miA = MKMapItem(placemark: pA)
        let miB = MKMapItem(placemark: pB)
        miA.name = "目前位置"
        miB.name = name.text
        
        let routes = [miA, miB]
        
        let options=[MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        MKMapItem.openMaps(with: routes, launchOptions: options)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
