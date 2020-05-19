//
//  ViewController.swift
//  ISS-Tracking-Application
//
//  Created by Anup Deshpande on 5/19/20.
//  Copyright © 2020 Anup Deshpande. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    var placesClient: GMSPlacesClient!
    var userLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isMyLocationEnabled = true
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        // Get Current Location of ISS
        NetworkManager.instance.getIssCurrentLocation({ (location) in
            let position = CLLocationCoordinate2D(latitude: Double(location.lat)!, longitude: Double(location.long)!)
            let marker = GMSMarker(position: position)
            marker.title = "ISS"
            marker.map = self.mapView
            
            let issCurrentLocation = GMSCameraPosition.camera(withLatitude: Double(location.lat)!,
                                                              longitude: Double(location.long)!,
                                                              zoom: 6)
            self.mapView.camera = issCurrentLocation
            
        }) { (error) in
            print(error)
        }
        
        // Get ISS pass time
        NetworkManager.instance.getIssPassTime(latitude: 1.11, longitude: 1.11, {
            print("success")
        }) { (error) in
            print(error)
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView.camera = camera
        
        placesClient = GMSPlacesClient.shared()
    }

    @IBAction func searchLocationTapped(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
          UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func currentLocationTapped(_ sender: UIBarButtonItem) {
        if userLocation != nil{
            NetworkManager.instance.getIssPassTime(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, {
                print("success")
            }) { (error) in
                print("error")
            }
        }
        
        
    }
}

extension ViewController: GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print(place.coordinate.latitude)
        print(place.coordinate.longitude)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last!
    }
}
