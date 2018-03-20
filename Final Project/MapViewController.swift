//
//  MapViewController.swift
//  Final Project
//
//  Created by Max Moede on 2/28/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import GeoFire
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapL: UILabel!
    var userData : User?
    var databaseRef : DatabaseReference?
    var geoFire: GeoFire?
    var regionQuery: GFRegionQuery?
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManger()
        databaseRef = Database.database().reference().child("users")
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("geofire"))
        mapL.text = "map Stuff"
        DispatchQueue.global(qos: .background).async {
            if let currentLocation = self.locationManager.location?.coordinate {
                let newRegion = MKCoordinateRegionMakeWithDistance(currentLocation, (CLLocationDistance(1609 * 25.0)), CLLocationDistance(1609 * 25.0))
                DispatchQueue.main.async {
                    self.mapView.setRegion(newRegion, animated: true)
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func configureLocationManger() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = 1.0
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    func updateRegionQuery() {
        if let oldQuery = regionQuery {
            oldQuery.removeAllObservers()
        }
        print("this is running")
        regionQuery = geoFire?.query(with: mapView.region)
        
        regionQuery?.observe(.keyEntered, with: { (key, location) in
            self.databaseRef?.queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: { snapshot in
                print("found some values")
                let newProfile = Profile(location: location, key: key, snapshot: snapshot)
                self.addProfile(newProfile)
            })
        })
    }
    
    func addProfile(_ profile : Profile) {
        DispatchQueue.main.async {
            self.mapView.addAnnotation(profile)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        updateRegionQuery()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        mapView.setRegion(MKCoordinateRegionMake((mapView.userLocation.location?.coordinate)!, MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is Profile {
            let annotationView = MKPinAnnotationView()
            annotationView.pinTintColor = .red
            annotationView.annotation = annotation
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
            
            let disclosureButton = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = disclosureButton
            
            return annotationView
        }
        
        return nil
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let thePlayerAnn = view.annotation
        performSegue(withIdentifier: "goToProfile", sender: thePlayerAnn)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile" {
            if let selectedPlayer = sender as? Profile {
                let destVC = segue.destination as! otherProfileView
                destVC.sentProfile = selectedPlayer
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
