//
//  ViewController.swift
//  GPS Tooklit
//
//  Created by Sylvan Martin on 4/13/19.
//  Copyright © 2019 Sylvan Martin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Constants
    
    /// The amount a button should shrink when pressed
    let buttonShrinkScale: CGFloat = 0.8
    
    /// The amoubt of time to spend on a button animation
    let animationTime: TimeInterval = 0.2
    
    // MARK: Properties
    
    /// The map view of the app
    @IBOutlet weak var map: MKMapView!
    
    /// The location manager
    var locationManager: CLLocationManager!
    
    /// The menu button
    @IBOutlet weak var menuButton: UIButton!
    
    /// Label displaying user's coordinates
    @IBOutlet weak var coordsLabel: UILabel!
    
    /// The annotations button
    @IBOutlet weak var annotationsButton: UIButton!
    
    /// Gesture recognizer for a long press on the map
    var gestureRecognizer: UILongPressGestureRecognizer!
    
    // MARK: View Controller
    
    /// Called when the view loads
    ///
    /// Any setup goes here
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        
        gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        gestureRecognizer.delegate = self
        map.addGestureRecognizer(gestureRecognizer)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        map.userTrackingMode = .follow
        
        // load markers
        
        let fileManager = FileManager.default
        let enumerator  = fileManager.enumerator(atPath: Marker.ArchiveURL.path)
        
        while let element = enumerator?.nextObject() as? String {
            do {
                
                let data = try Data(contentsOf: Marker.ArchiveURL.appendingPathComponent(element))
                
                if let marker = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [Marker.self], from: data) as? Marker {
                    map.addAnnotation(marker)
                } else {
                    print("Couldn't cast")
                }
                
            } catch {
                print("Error on decoding data:", error)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("bye bye")
    }
    
    // MARK: Actions
    
    /// Called when user holds the map, adding an annotation
    @objc func addAnnotation() {
        let location = gestureRecognizer.location(in: map)
        let coordinate = map.convert(location, toCoordinateFrom: map)
        
        // add the marker
        let alertController = UIAlertController(title: "New Marker", message: "Name the marker for your point", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "New Marker"
            textField.clearButtonMode = .whileEditing
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let name = alertController.textFields?[0].text, name.count > 0 {
                let marker = Marker(title: name, subtitle: coordinate.dms, at: coordinate)
                self.map.addAnnotation(marker)
                
                do {
                    let url = Marker.ArchiveURL.appendingPathComponent(marker.title!)
                    
                    let data = try NSKeyedArchiver.archivedData(withRootObject: marker, requiringSecureCoding: true)
                    
                    try data.write(to: url)
                } catch {
                    print("Error on saving marker:", error)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
        
        
        
    }
    
    /// Called when user clicks the menu button
    @IBAction func userPressedMenuButton(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Change the map", message: "Change how the map is displayed", preferredStyle: .actionSheet)

        let hybridFlyover = UIAlertAction(title: "Hybrid", style: .default) { (_) in
            self.map.mapType = .hybridFlyover
        }
        
        let satelliteFlyover = UIAlertAction(title: "Satellite", style: .default) { (_) in
            self.map.mapType = .satelliteFlyover
        }
        
        let standard = UIAlertAction(title: "Standard", style: .default) { (_) in
            self.map.mapType = .standard
        }
        
        let mutedStandard = UIAlertAction(title: "Muted Standard", style: .default) { (_) in
            self.map.mapType = .mutedStandard
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addActions(hybridFlyover, satelliteFlyover, standard, mutedStandard, cancelAction)
        
        self.present(actionSheet, animated: true)
    }
    
    /// Called when user clicks the annotations button
    @IBAction func userPressedMapButton(_ sender: Any) {
        let markerNames: [String] = map.annotations.map { $0.title!! }
        let markerObjects = map.annotations.map { $0 }
        
        let markers = zip(markerNames, markerObjects)
        
        let alertController = UIAlertController(title: "Jump to a marker", message: "Select a marker to view", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        for (name, marker) in markers {
            let action = UIAlertAction(title: name, style: .default) { _ in
                let annotationPoint = MKMapPoint(marker.coordinate);
                let zoomRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1);
                self.map.setVisibleMapRect(zoomRect, animated: true)
            }
            alertController.addAction(action)
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Button Aesthetics
    
    /// Shrinks the menu button when it's pressed
    @IBAction func userTouchedDownOnMenuButton(_ sender: Any) {
        UIView.animate(withDuration: animationTime, animations: {
            self.menuButton.transform = CGAffineTransform(scaleX: self.buttonShrinkScale, y: self.buttonShrinkScale)
        }) { _ in
            UIView.animate(withDuration: self.animationTime) {
                self.menuButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    /// Shrinks the annotations button when it's pressed
    @IBAction func userTouchedDownOnMapButton(_ sender: Any) {
        UIView.animate(withDuration: animationTime, animations: {
            self.annotationsButton.transform = CGAffineTransform(scaleX: self.buttonShrinkScale, y: self.buttonShrinkScale)
        }) { _ in
            UIView.animate(withDuration: self.animationTime) {
                self.annotationsButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    // MARK: Location Manager
    
    /// Called when user's location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordsLabel.text = locations[0].coordinate.dms
    }
    
    // MARK: Map View
    
    /// Called when an annotation is pressed
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let marker = (view.annotation as? Marker) else {
            return
        }
        
        map.setCenter(view.annotation!.coordinate, animated: true)
        
        let alertController = UIAlertController(title: marker.title, message: "Manage this marker", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.map.removeAnnotation(view.annotation!)
            do {
                try FileManager.default.removeItem(at: Marker.ArchiveURL.appendingPathComponent(marker.title!))
            } catch {
                print("Error:", error)
            }
        }
        
        alertController.addActions(cancelAction, deleteAction)
        
        self.present(alertController, animated: true)
    }
    
}

