//
//  ViewController.swift
//  MabKit1
//
//  Created by AhmadALshafei on 10/3/25.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var myMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setStartingLocation()
        addAnnotation()
    }

    func setStartingLocation() {
        
        let location = CLLocationCoordinate2D(latitude: 29.9560079, longitude: 31.0938121)
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: location, span: span)
        myMap.setRegion(region, animated: true)
        myMap.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 2800000)
        myMap.setCameraZoomRange(zoomRange, animated: true)
    }
    func addAnnotation(){
        func setPinUsingMKPointAnnotation(location: CLLocationCoordinate2D){
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "Here"
            annotation.subtitle = "Device Location"
            let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
            myMap.setRegion(coordinateRegion, animated: true)
            myMap.addAnnotation(annotation)
        }
        }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.image = UIImage(named: "marker_gray")
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.image = UIImage(named: "marker_red")
    }

}

