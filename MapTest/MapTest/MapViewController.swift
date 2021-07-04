//
//  MapViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 27.01.2021.
//

import UIKit
import MapKit


protocol MapViewControllerDelegate: class {
    func update(data: res)
}

class MapViewController: UIViewController, MapViewControllerDelegate {
    
    

    @IBOutlet weak var addButtonView: UIButton!
    //  @IBOutlet weak var partyName: UITextField!
  //  @IBOutlet weak var partyInfo: UITextField!
    
    var partyName:String!
    var partyInfo:String!
    var dateInfo:String!
    var partyType:String!
    
    var tmpParty:Party?
    let locationManager = CLLocationManager()
    let party = Party(name: "Name", party: "No party", coordinate: CLLocationCoordinate2D(latitude:15.7,longitude:37.3), creator: "", participants: [], date: "", type: "", tittleImage: "", images: [])
    var http:HTTPCommunication = HTTPCommunication()
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.addButtonView.layer.masksToBounds = true
        addButtonView.layer.cornerRadius = 30
       // mapView.addAnnotation(party)
        
        
    }
    
    
    func update(data: res) {
        partyName = data.Name
        partyInfo = data.Info
        dateInfo = data.Date
        partyType = data.PartyType
        print("SAVED")
        }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.mapView.removeAnnotations(mapView.annotations)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLocationEnabled()
       // self.mapView.addAnnotations(parties)
    }
    func checkLocationEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            setupManager()
            checkAuthorization()
        }
        else{
            
            let alert = UIAlertController(title: "Включите службы геолокации", message: "Включить?", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default){(alert) in
                if let url = URL(string: "App-Prefs:root=LOCATION_SERVICES")
                {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            }
        }
    
    
    
    func setupManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func checkAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView?.showsUserLocation = true
            
        case .denied:
            showAlertLocation(title: "Выключены службы геолокации", message: "Сбой получения данных", url: URL(string:UIApplication.openSettingsURLString))
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        default:
            break
        }
    }
    
    func showAlertLocation(title:String,message:String?,url:URL?){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default){(alert) in
            if let url = url
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
extension MapViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let location = locations.last?.coordinate{
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 70000, longitudinalMeters: 70000)
            mapView?.setRegion(region, animated: true)
        }
    }
  /*  func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager, locations: [CLLocation]) {
        if let location = locations.last?.coordinate{
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(region, animated: true)
    }
    }*/
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        checkAuthorization()
    }
   /* func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }*/
    
    @IBAction func addPin(sender:UILongPressGestureRecognizer){
        guard partyInfo != "" && partyName != "" && dateInfo != "" && partyType != "" && partyInfo != nil && partyName != nil && dateInfo != nil && partyType != nil else {return}
        let location = sender.location(in: self.mapView)
        let locCoord = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        let annotation = Party(name:"qwe",party:"qwe",coordinate: CLLocationCoordinate2D(latitude:0.1,longitude:0.1), creator: UserDefault.userName!, participants: [], date: "", type: "", tittleImage: "", images: [])
        annotation.coordinate = locCoord
        annotation.name = partyName
        annotation.party = partyInfo
        annotation.subtitle = partyInfo
        annotation.creator = UserDefault.userName!
        annotation.date = dateInfo
        annotation.type = partyType
        tmpParty = annotation
        http.postParty(tmpParty: tmpParty)
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)

       // self.mapView.addAnnotations(parties)
        partyName = ""
    }
    
    
}
extension MapViewController: MKMapViewDelegate{
   /* func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Party else {return nil}
        
        let viewMarker : MKMarkerAnnotationView
        let idView = "marker"
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: idView) as? MKAnnotationView{
            view.annotation = annotation
            viewMarker = view as! MKMarkerAnnotationView
        }
        else{
            viewMarker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: idView)
            viewMarker.canShowCallout = true
            viewMarker.calloutOffset = CGPoint(x:0,y:6)
            viewMarker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return viewMarker
    }*/
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Party else {return nil}
        
        
        let viewMarker : MKMarkerAnnotationView
        let idView = "marker"
        let ann: MKAnnotationView
        
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: idView) as? MKAnnotationView{
            view.annotation = annotation
            viewMarker = view as! MKMarkerAnnotationView
            ann = view as! MKAnnotationView
        }
        else{
                viewMarker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: idView)
           // viewMarker.canShowCallout = true
          //  viewMarker.calloutOffset = CGPoint(x:0,y:6)
         //   viewMarker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            
         //   viewMarker.markerTintColor = .blue
          //  viewMarker.image = UIImage(data: UIImage(named: "image")!.jpegData(compressionQuality: 1)!, scale: 30)
            
            //ann = MKAnnotationView(annotation: annotation, reuseIdentifier: idView)
            //ann.canShowCallout = true
            //ann.calloutOffset = CGPoint(x:0,y:6)
            //ann.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
           // ann.image =  UIImage(data: UIImage(named: "markerCommon")!.pngData()!, scale: 10)!
            
        /*    if annotation.tittleImage != "" {
                
            http.downloadFile(fileId: annotation.tittleImage) { (data:Data) in
                let image = UIImage(data: data, scale: 20)
                
                let imageView = UIImageView(image: image)
              //  imageView.frame = CGRect(x: 0, y: 6, width: 10.0, height: 10.0)
                
                viewMarker.detailCalloutAccessoryView = imageView
            }
            }
            */
        }
        return viewMarker
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let coordinate = locationManager.location?.coordinate else {
            return
        }
        user.parties.append(tmpParty!)
        //print(user.parties[0].name)
        view.rightCalloutAccessoryView = UIButton(type: .close)
        view.annotation = nil
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let destination = segue.destination as? SearchSettingsController else { return }
            destination.delegate = self
        }
}
