//
//  ViewController.swift
//  SunInformation
//
//  Created by Mac on 05.06.18.
//  Copyright © 2018 VasylFuchenko. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityLabel: UILabel!
    
    var sunInformation: Information!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        updateSunInformationForLocation(location: "Lviv")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty {
            updateSunInformationForLocation(location: locationString)
            cityLabel.text = locationString
        }
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






