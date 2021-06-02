//
//  ViewController.swift
//  mapkitpractice
//
//  Created by yeonBlue on 2021/06/02.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet weak var pinAddressButton: UIView!
    
    @IBAction func pinAddressButtonPressed(_ sender: Any) {
        
        let alertController =  UIAlertController(title: "Enter Address",
                                                 message: "Need your address for Geocoding",
                                                 preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK",
                                     style: .default) { [weak self] action in
            if let tf = alertController.textFields?.first {
                let text = tf.text!
                self?.geocodeAndAnnotate(addressText: text)
            }
        }
        
        let cancelButton = UIAlertAction(title: "No",
                                         style: .cancel,
                                         handler: nil)
        
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        
        alertController.addTextField { tf in
            
        }
        
        present(alertController, animated: true) {
            
        }
    }
    
    func geocodeAndAnnotate(addressText: String) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(addressText) { placemarks, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let cordinates = placemark?.location?.coordinate
            
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = cordinates!
            
            self.mapView.addAnnotation(newAnnotation)
        }
    }
    
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        segmentControl.addTarget(self,
                                 action: #selector(segmentTouch),
                                 for: .valueChanged)

    }

    @objc func segmentTouch() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
    }
    
    func addAnnotation() {
        let annotation = MKPointAnnotation()
        //annotation.coordinate = CLLocationCoordinate2D(latitude: 35.65, longitude: 139.8394)
        annotation.coordinate = mapView.userLocation.coordinate
        annotation.title = "TEST Annotation Title"
        annotation.subtitle = "TEST Subtitle"
        mapView.addAnnotation(annotation)
    }

}

extension ViewController: CLLocationManagerDelegate {
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate,
                                        latitudinalMeters: 10,
                                        longitudinalMeters: 10)
        
        mapView.setRegion(region, animated: true)
        addAnnotation()
    }
    
    /// Returns the view associated with the specified annotation object.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        // var marker = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") as? MKMarkerAnnotationView
        
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        marker.glyphText = "glyph"
        
        marker.canShowCallout = true
        marker.leftCalloutAccessoryView = UIImageView(image: UIImage(systemName: "square.and.pencil"))
        marker.rightCalloutAccessoryView = UIImageView(image: UIImage(systemName: "circle.fill"))
        
        //marker.detailCalloutAccessoryView = UIImageView(image: UIImage(named: "img1"))
        setupMapSnapshot(annotation: marker)
        
        return marker
    }
    
    // MARK: - Map Snapshot
    func setupMapSnapshot(annotation: MKAnnotationView) {
        let options = MKMapSnapshotter.Options()
        
        options.size = CGSize(width: 200, height: 200)
        options.mapType = .hybridFlyover
        
        let center = annotation.annotation?.coordinate ?? CLLocationCoordinate2D(latitude: 20, longitude: 20)
        
        options.camera = MKMapCamera(lookingAtCenter: center, fromDistance: 150, pitch: 60, heading: 0)
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                imageView.image = snapshot.image
                annotation.detailCalloutAccessoryView = imageView
            }
        }
    }
}

