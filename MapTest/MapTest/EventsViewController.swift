//
//  EventsViewController.swift
//  MapTest
//
//  Created by Alexander Malygin on 08.02.2021.
//

import UIKit
import MapKit




class EventsViewController: UIViewController {

    var partyName:String!
    var partyInfo:String!
    
    var tmpParty:Party?
    let locationManager = CLLocationManager()
    let party = Party(name: "Name", party: "No party", coordinate: CLLocationCoordinate2D(latitude:15.7,longitude:37.3), creator: "", participants: [], date: "", type: "", tittleImage: "", images: [])
    var http:HTTPCommunication = HTTPCommunication()
    @IBOutlet weak var mapView: MKMapView!
    
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  http.retrieveData(nil, tableView: nil)
        self.mapView.delegate = self
       // mapView.addAnnotation(party)
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkLocationEnabled()
        http.retrieveParties( nil, tableView: nil) {
            [weak self] (data) -> Void in
            guard let json = String(data: data, encoding: String.Encoding.utf8) else { return }
            print("JSON: ", json)
            do {
                let jsonObjectAny: Any = try JSONSerialization.jsonObject(with: data, options: [])
                print(jsonObjectAny as? [String:Any])
                let jsonObject = jsonObjectAny as! [[String:Any]]
                parties = []
                    for item in jsonObject{
                        parties.append(Party(id : item["id"] as! String, name: item["name"] as! String, party: item["party"] as! String, coordinate: CLLocationCoordinate2D(latitude: item["latitude"] as! Double, longitude: item["longitude"] as! Double), creator: item["creator"] as! String, participants: item["participants"] as! Array<String>, date: item["date"] as! String, type: item["type"] as! String, tittleImage: item["tittleImage"] as! String, images: item["images"] as! Array<String>))
                }
                if self?.mapView.annotations != nil{
                    self?.mapView.removeAnnotations((self?.mapView.annotations)!)
                }
                self?.mapView.addAnnotations(parties)
            } catch {
                print("Can't serialize data.")
            }
        }
      //  self.mapView.addAnnotations(parties)
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
        
        let settingsAction = UIAlertAction(title: "Настройки", style: .default){(alert) in
            if let url = url
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



extension EventsViewController:CLLocationManagerDelegate{
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


    
    
}
extension EventsViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation as! Party
        if annotation.tittleImage != "" {
            
        http.downloadFile(fileId: annotation.tittleImage) { (data:Data) in
            let image = UIImage(data: data, scale: 20)
            
            let imageView = UIImageView(image: image)
          //  imageView.frame = CGRect(x: 0, y: 6, width: 10.0, height: 10.0)
           // let viewMarker = view as! MKMarkerAnnotationView
            let viewMarker = view as! MKAnnotationView
          //  viewMarker.image = UIImage(data: view.image!.pngData()!, scale: 20)
            viewMarker.detailCalloutAccessoryView = imageView
        }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let viewMarker = view as! MKMarkerAnnotationView
      //  viewMarker.image = UIImage(data: view.image!.pngData()!, scale: 10)
    }
    
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
            viewMarker.canShowCallout = true
            viewMarker.calloutOffset = CGPoint(x:0,y:6)
            viewMarker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            
         //   viewMarker.markerTintColor = .blue
        //    viewMarker.image = UIImage(data: UIImage(named: "image")!.jpegData(compressionQuality: 1)!, scale: 30)
            /*
            ann = MKAnnotationView(annotation: annotation, reuseIdentifier: idView)
            ann.canShowCallout = true
            ann.calloutOffset = CGPoint(x:0,y:6)
            ann.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            if annotation.participants.count > 10 {
            ann.image = UIImage(data: UIImage(named: "marker")!.pngData()!, scale: 10)
            }
            else{
                ann.image = UIImage(data: UIImage(named: "markerCommon")!.pngData()!, scale: 10)
            }
 */
            
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
        guard let annotation = view.annotation as? Party else {print("Error"); return}
        //user.parties.append(tmpParty!)
        //print(user.parties[0].name)

        /*if !user.partyIds.contains(annotation.id as! String){
        user.partyIds.append(annotation.id as! String)
        }*/
        
        let newVC = storyboard?.instantiateViewController(identifier: "EventViewController") as! EventViewController
       // navigationController?.pushViewController(newVC!, animated: true)
        newVC.loadView()
        
        newVC.party = annotation as! Party
        newVC.titleView.text = annotation.name
        newVC.creatorView.text = annotation.creator
        newVC.participantsView.text = String(annotation.participants.count)
        newVC.descriptionView.text = annotation.subtitle
        newVC.viewDidLoad()
        navigationController?.showDetailViewController(newVC, sender: nil)
    
       // view.rightCalloutAccessoryView = UIButton(type: .close)
       // view.annotation = nil
        
    }
    
    
}
