//
//  Representation.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 03/02/2020.
//  Copyright © 2020 GiorgosHadj. All rights reserved.
//

import Foundation

struct Representation: Codable {
    let features: [RepFeature]
    let type: String
    
    init(with json: NSDictionary) {
        type = json["type"] as? String ?? ""
        guard let jsonArray = json["features"] as? [NSDictionary] else {
            features = []
            return
        }
        var features: [RepFeature] = []
        for item in jsonArray  {
            features.append(RepFeature(with: item))
        }
        self.features = features
    }
}

struct RepFeature: Codable {
    let geometry: RepGeometry
    let properties: PropertiesX
    let type: String
    
    init(with json: NSDictionary) {
        geometry = RepGeometry(with: json["geometry"] as? NSDictionary)
        properties = PropertiesX(with: json["properties"] as? NSDictionary)
        type = json["type"] as? String ?? ""
    }

    struct RepGeometry: Codable {
        let coordinates: [Double]
        let type: String
        
        init(with json: NSDictionary?) {
            coordinates = json?["coordinates"] as? [Double] ?? []
            type = json?["type"] as? String ?? ""
        }
    }
    
    struct PropertiesX: Codable {
        let clearName: String
        let link: String
        let name: String
        let number: String
        let orientation: Int
        let thumbnail: String
        let type: String
        
        init(with json: NSDictionary?) {
            clearName = json?["clearName"] as? String ?? ""
            link = json?["link"] as? String ?? ""
            name = json?["name"] as? String ?? ""
            number = json?["number"] as? String ?? ""
            orientation = json?["orientation"] as? Int ?? 0
            thumbnail = json?["thumbnail"] as? String ?? ""
            type = json?["type"] as? String ?? ""
        }
    }
}
