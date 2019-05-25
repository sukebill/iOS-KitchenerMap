//
//  UserAnnotation.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 25/05/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import MapKit

class UserAnnotation: NSObject, MKAnnotation {
    var title: String?
    let coordinate: CLLocationCoordinate2D
    var subtitle: String?
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
}

extension UserAnnotation {
    static func == (lhs: UserAnnotation, rhs: UserAnnotation) -> Bool {
        let t = lhs.title == rhs.title
        let s = lhs.subtitle == rhs.subtitle
        let lat = lhs.coordinate.latitude == rhs.coordinate.latitude
        let lon = lhs.coordinate.longitude == rhs.coordinate.longitude
        return t && s && lat && lon
    }
}
