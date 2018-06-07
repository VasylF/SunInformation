//
//  SunService.swift
//  SunInformation
//
//  Created by Mac on 07.06.18.
//  Copyright © 2018 VasylFuchenko. All rights reserved.
//

import Foundation
import Alamofire
//"https://api.sunrise-sunset.org/json?lat=49.839683&lng=24.029717"

class SunService {
    
    static let sunURL = "https://api.sunrise-sunset.org/json?"
    
    static func getSunInformation(latitude: Double, longitude: Double, completion:  @escaping (Information?) -> Void) {
        let url = sunURL + "lat=\(latitude)&lng=\(longitude)"
        if let sunInformationURL = URL(string: "\(url)") {
            Alamofire.request(sunInformationURL).responseJSON { (response) in
                if let responseJSON : Dictionary = response.result.value as? [String: Any] {
                    if let responseDictionary : Dictionary = responseJSON["results"] as? [String: String] {
                        let sunInfo = Information(infoDictionary: responseDictionary)
                        completion(sunInfo)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    
    
}
