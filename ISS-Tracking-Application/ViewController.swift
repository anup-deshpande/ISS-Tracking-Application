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
        
        mapView.isUserInteractionEnabled = false
        
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector: #selector(locateISS), userInfo: nil, repeats: true)
        
        placesClient = GMSPlacesClient.shared()
    }
    
    @objc func locateISS(){
        // Get Current Location of ISS
        NetworkManager.instance.getIssCurrentLocation({ (location) in
            self.mapView.clear()
            let position = CLLocationCoordinate2D(latitude: Double(location.lat)!, longitude: Double(location.long)!)
            let marker = GMSMarker(position: position)
            marker.title = "ISS"
            marker.map = self.mapView
            marker.icon = #imageLiteral(resourceName: "spaceStation")
            
            let issCurrentLocation = GMSCameraPosition.camera(withLatitude: Double(location.lat)!,
                                                              longitude: Double(location.long)!,
                                                              zoom: 6)
            self.mapView.camera = issCurrentLocation
            
        }) { (error) in
            print(error)
        }
        
    }

    @IBAction func searchLocationTapped(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func currentLocationTapped(_ sender: UIBarButtonItem) {
        
        if userLocation != nil{
            NetworkManager.instance.getIssPassTime(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, { (dates) in
                var labelText = ""
                for i in 0..<dates.count{
                    labelText += dates[i]
                    if i != dates.count - 1{
                        labelText += "\n"
                    }
                }
                
                self.timeLabel.text = labelText
            }) { (error) in
                print("error")
            }
        }
        
        
    }
}

extension ViewController: GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        NetworkManager.instance.getIssPassTime(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, { (dates) in
            
                var labelText = ""
                for i in 0..<dates.count{
                    labelText += dates[i]
                    if i != dates.count - 1{
                        labelText += "\n"
                    }
                }
                
                self.timeLabel.text = labelText
            }) { (error) in
                print("error")
            }
        
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
