//
//  GravouraView.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 03/02/2020.
//  Copyright © 2020 GiorgosHadj. All rights reserved.
//

import Foundation
import MapKit

class GravouraView: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var link: String?
    var image: UIImage?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
