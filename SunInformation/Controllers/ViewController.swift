//
//  ViewController.swift
//  SunInformation
//
//  Created by Mac on 05.06.18.
//  Copyright © 2018 VasylFuchenko. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

class ViewController: UIViewController {

    //MARK: Outlets
    
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    //MARK: Properties
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    let locationManager = CLLocationManager()
    var sunInformation: Information!
    var latitude: Double!
    var longitude: Double!
    var location: CLLocation! {
        didSet {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkCoreLocationPermission()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        view.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
  
        definesPresentationContext = true
        }
    
    //MARK: Private functions
    
    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .restricted {
            print("unauthorized to use location service")
        }
    }
    
    func countryCityName(location: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                var placemark: CLPlacemark!
                placemark = placemarks![0]
                if let city = placemark?.locality {
                    self.cityLabel.text = String(city)
                } else {
                    self.cityLabel.text = "City didn't found"
                }
                if let country = placemark?.country {
                    self.countryLabel.text = String(country)
                } else {
                    self.countryLabel.text = "Country didn't found"
                }
            }
        }
    }
    
    func updateSunInformationForLocation(currentLocation: String) {
        CLGeocoder().geocodeAddressString(currentLocation) { (placemarks: [CLPlacemark]? , error: Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    SunService.shared.getSunInformation(latitude: latitude, longitude: longitude, completion: { (result) in
                        if let sunInformationData = result {
                            self.sunInformation = sunInformationData
                            DispatchQueue.main.async {
                                self.updateLabel(info: self.sunInformation, location: location)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func getSunInformationOnlyWithCoordinate(latitude: Double, longitude: Double) {
        SunService.shared.getSunInformation(latitude: latitude, longitude: longitude, completion: { (result) in
            if let sunInformationData = result {
                self.sunInformation = sunInformationData
                DispatchQueue.main.async {
                    self.updateLabel(info: self.sunInformation, location: self.location)
                }
            }
        })
    }
    
    func updateLabel(info: Information, location: CLLocation) {
        sunsetLabel.text = info.sunset
        sunriseLabel.text = info.sunrise
        countryCityName(location: location)
    }

}

     //MARK: extension GMSAutocompleteResultsViewControllerDelegate

extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        updateSunInformationForLocation(currentLocation: "\(place.name)")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

     //MARK: extension CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    location = locations.last
    locationManager.stopUpdatingLocation()
    if latitude != nil, longitude != nil {
        getSunInformationOnlyWithCoordinate(latitude: latitude, longitude: longitude)
    }
    countryCityName(location: location)
    }
}






