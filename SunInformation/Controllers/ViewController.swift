//
//  ViewController.swift
//  SunInformation
//
//  Created by Mac on 05.06.18.
//  Copyright © 2018 VasylFuchenko. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityLabel: UILabel!
    
    var sunInformation: Information!
    let locationManager = CLLocationManager()
    var latitude: Double!
    var longitude: Double!
    var location: CLLocation! {
        didSet {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkCoreLocationPermission()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .restricted {
            print("unauthorized to use location service")
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty {
            updateSunInformationForLocation(location: locationString)
            cityLabel.text = locationString
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        locationManager.stopUpdatingLocation()
        if latitude != nil, longitude != nil {
            getSunInformationOnlyWithCoordinate(latitude: latitude, longitude: longitude)
        }
        getCityName()
    }
    
    func getCityName() {
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
            }
        }
    }
    
    func getSunInformationOnlyWithCoordinate(latitude: Double, longitude: Double) {
        SunService.getSunInformation(latitude: latitude, longitude: longitude, completion: { (result) in
            if let sunInformationData = result {
                self.sunInformation = sunInformationData
                DispatchQueue.main.async {
                    self.updateLabel(info: self.sunInformation)
                }
            }
        })
    }
    
    func updateLabel(info: Information) {
        sunsetLabel.text = info.sunset
        sunriseLabel.text = info.sunrise
    }
    
    func updateSunInformationForLocation(location: String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks: [CLPlacemark]? , error: Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    SunService.getSunInformation(latitude: latitude, longitude: longitude, completion: { (result) in
                        if let sunInformationData = result {
                            self.sunInformation = sunInformationData
                            DispatchQueue.main.async {
                                self.updateLabel(info: self.sunInformation)
                            }
                        }
                    })
                }
            }
        }
    }

}






