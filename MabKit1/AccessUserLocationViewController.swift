//
//  AccessUserLocationViewController.swift
//  MabKit1
//
//  Created by AhmadALshafei on 10/4/25.
//

import UIKit
import MapKit
import CoreLocation
class AccessUserLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var textSearch: UITextField!
    
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var close: UIButton!
    
    
    @IBOutlet weak var pinToaccessLocation: UIImageView!
    
    @IBOutlet weak var start: UIButton!
    
    
    
    var locationManager = CLLocationManager()
    var lastLocation : CLLocation?
    let annotation = MKPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()
        myMap.delegate = self
        start.isHidden = true
        pinToaccessLocation.isHidden = true
//        textSearch.layer.cornerRadius = 100
//        textSearch.layer.shadowColor = UIColor.black.cgColor
//        textSearch.layer.shadowOpacity = 0.3
//        textSearch.layer.shadowOffset = CGSize(width: 0, height: 2)
//        textSearch.layer.shadowRadius = 4
//        textSearch.layer.masksToBounds = false

        let buttons = [search, close, start]
        buttons.forEach { button in
            button?.layer.cornerRadius = 10
            button?.layer.shadowColor = UIColor.gray.cgColor
            button?.layer.shadowOpacity = 0.7
            button?.layer.shadowOffset = CGSize(width: 0, height: 2)
            button?.layer.shadowRadius = 4
            button?.setTitleColor(.black, for: .normal)
        }
        pinToaccessLocation.layer.cornerRadius = pinToaccessLocation.frame.height / 2
        pinToaccessLocation.layer.shadowColor = UIColor.gray.cgColor
        pinToaccessLocation.layer.shadowOpacity = 0.3
        pinToaccessLocation.layer.shadowOffset = CGSize(width: 0, height: 2)
        pinToaccessLocation.layer.shadowRadius = 4
        pinToaccessLocation.clipsToBounds = true

        textSearch.placeholder = "What place are you looking for?"
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        
        if islocationservicesavailable(){
            CheckAuthorization()
        }else{
            showMsg("Please Enable  Location Services")
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textSearch.layer.cornerRadius = textSearch.frame.height / 2
        textSearch.layer.shadowColor = UIColor.black.cgColor
        textSearch.layer.shadowOpacity = 0.3
        textSearch.layer.shadowOffset = CGSize(width: 0, height: 2)
        textSearch.layer.shadowRadius = 4
        textSearch.layer.masksToBounds = false
        textSearch.backgroundColor = .white
    }

    func islocationservicesavailable() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func CheckAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            myMap.showsUserLocation = true
            break
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            myMap.showsUserLocation = true

            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            myMap.showsUserLocation = true

            break
        case .denied:
            showMsg("please authorize Access to Location")
            break
        case .restricted:
            showMsg("GPS access is restricted. In order to use tracking, please enable GPS in the Settigs app under Privacy, Location Services.")
            break
        default:
            print("default..")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last!
        if let location = lastLocation {
            print("latitude \(location.coordinate.latitude) longitude \(location.coordinate.longitude)")
            zoomToUserLocatio(location: location)
            locationManager.stopUpdatingLocation()

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            myMap.showsUserLocation = true
            break
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            myMap.showsUserLocation = true
            break
            
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            myMap.showsUserLocation = true
            break
            
        case .denied:
            showMsg("please authorize Access to Location")
            break
            
        default:
            print("default..")
        }
    }

    func showMsg(_ msg: String) {
        let alert = UIAlertController(title: "Permission Needed",
                                      message: "You need to enable access in Settings.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Go to Settings now", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // عشان يعمل زوم لمكان المستخدم
    func zoomToUserLocatio(location : CLLocation) {
        
//        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        myMap.setRegion(region, animated: true)
//        myMap.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
//        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 2800000)
//        myMap.setCameraZoomRange(zoomRange, animated: true)
    }
    @IBAction func reLocation(_ sender: Any) {

        if let location = lastLocation {
            print("latitude \(location.coordinate.latitude) longitude \(location.coordinate.longitude)")
            zoomToUserLocatio(location: location)
        }

    }
    
    
    @IBAction func SearchButton(_ sender: Any) {
        if textSearch.text != "" {
            start.isHidden = false
            searchForDestination(destination: textSearch.text!)
        }else{
            textSearch.placeholder = "please enter Place to search"
        }
    }

    func searchForDestination(destination : String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(destination) { (places, error) in
            guard let place = places?.first , error == nil else {return}
            guard let location = place.location else {return}
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.myMap.setRegion(region, animated: true )
            self.annotation.coordinate = location.coordinate
            self.annotation.title = place.name
            self.annotation.subtitle = "\(place.country ?? "") \(place.administrativeArea ?? "")"
            self.myMap.addAnnotation(self.annotation)

        }
        
    }
    var currentRoute: MKPolyline?   // متغير نخزن فيه آخر مسار
    
    @IBAction func closeButton(_ sender: Any) {
        // امسح النص من البحث
        textSearch.text = ""
        
        // امسح الـ pin الحالي (أو كله)
        myMap.removeAnnotation(annotation)
        // أو لو عايز تمسح كل الـ pins:
        // myMap.removeAnnotations(myMap.annotations)
        
        // امسح الـ directions لو موجود
        myMap.removeOverlays(myMap.overlays)

        // اخفاء الأزرار
        pinToaccessLocation.isHidden = true
        start.isHidden = true
        
        // reset flag
        iscleced = false
    }

    var iscleced : Bool = false
    @IBAction func pinButton(_ sender: Any) {
        pinToaccessLocation.isHidden = false
        start.isHidden = false
        iscleced = true
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        getLocationInfi(location: CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
    }
    func getLocationInfi(location : CLLocation){
        if iscleced == false{return}
        else{
        let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location) { (places, error) in
                guard let place = places?.first,error == nil else {return}
                self.textSearch.text = "\(place.name ?? ""), \(place.administrativeArea ?? "")"
            }
        }
    }
    
    @IBAction func startButton(_ sender: Any) {
        if let userLoc = locationManager.location{
            pinToaccessLocation.isHidden = true
            drawDirections(startingLoc: userLoc.coordinate, destinationLoc: myMap.centerCoordinate)
        }
    }
    func drawDirections(startingLoc : CLLocationCoordinate2D , destinationLoc : CLLocationCoordinate2D){
        let startingItem = MKMapItem(placemark: MKPlacemark(coordinate: startingLoc))
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationLoc))
        let request = MKDirections.Request()
        request.source = startingItem
        request.destination = destinationItem
        request.transportType = .automobile
//        request.requestsAlternateRoutes = true
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let response = response else {return}
            for route in response.routes {
                self.myMap.addOverlay(route.polyline)
                self.myMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    var render : MKPolylineRenderer!
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
        render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
}
