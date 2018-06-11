//
//  Information.swift
//  SunInformation
//
//  Created by Mac on 05.06.18.
//  Copyright © 2018 VasylFuchenko. All rights reserved.
//

import Foundation

class Information {
    
    let sunrise: String?
    let sunset: String?

    struct infoKeys {
        static let sunrise = "sunrise"
        static let sunset = "sunset"
    }

    init(infoDictionary: [String: String]) {
        if let sunrise = infoDictionary[infoKeys.sunrise] {
            self.sunrise = sunrise
        } else {
            self.sunrise = nil
        }
        if let sunset = infoDictionary[infoKeys.sunset] {
            self.sunset = sunset
        } else {
            self.sunset = nil
        }
    }
    
}
