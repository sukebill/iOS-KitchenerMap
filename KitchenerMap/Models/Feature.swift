//
//  Feature.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 20/10/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation

struct Feature {
    let type: String?//n.get("type").asString
    let id: String?// = json.get("id").asString
    let geometryName: String?// = json.get("geometry_name").asString
    let properties: Properties?
    let geometry: Geometry?// = Geometry(json.getAsJsonObject("geometry"))
    let poiProperties: POIProperties//? = null
    
    init(with json: NSDictionary?) {
        type = json?["type"] as? String
        id = json?["id"] as? String
        geometryName = json?["geometry_name"] as? String
        let prprts = (json?["properties"] as? NSDictionary)?["properties"] as? String
        if prprts == nil {
            properties = Properties(with: (json?["properties"] as? NSDictionary)?["display_properties"] as? String)
        } else {
            properties = Properties(with: prprts)
        }
        geometry = Geometry(with: json?["geometry"] as? NSDictionary)
        poiProperties = POIProperties(with: json?["properties"] as? NSDictionary)
    }
}

struct Properties {
    var values: PropertyNames?
    
    init(with string: String?) {
        guard string != nil else { return }
        let escapedString = string!.replacingOccurrences(of: "\\", with: "")
        guard let jsonArray = ((try? JSONSerialization.jsonObject(with: escapedString.data(using: .utf8)!, options : .allowFragments) as? [NSDictionary]) as [NSDictionary]??) else { return }
        values = PropertyNames(with: jsonArray ?? [])
    }
}

struct PropertyNames {
    var categoryEN: String?
    var categoryEL: String?
    var nameEN: String?
    var nameEL: String?
    var GIDEN: String?
    var GIDEL: String?
    var UUIDEN: String?
    var UUIDEL: String?
    var dbNameEN: String?
    var dbNameEL: String?
    
    init(with jsonArray: [NSDictionary]) {
        jsonArray.forEach { json in
            let key = (json["name"] as? NSDictionary)?["en"] as? String
            let en = (json["value"] as? NSDictionary)?["en"] as? String
            let el = (json["value"] as? NSDictionary)?["el"] as? String
            switch key {
            case "GID":
                GIDEL = el
                GIDEN = en
            case "UUID":
                UUIDEL = el
                UUIDEN = en
            case "Database table name":
                dbNameEL = el
                dbNameEN = en
            case "Category":
                categoryEL = el
                categoryEN = en
            case "Map label":
                nameEL = el
                nameEN = en
            default:
                break
            }
        }
    }
}

struct Geometry {
    typealias Location = (lat: Double, lng: Double)
    let isPoint: Bool
    let isMultiLineString: Bool
    let isMultiPolygon: Bool
    var point: Location?
    var points: [Location]?
    
    init(with json: NSDictionary?) {
        isPoint = json?["type"] as? String == "Point"
        isMultiLineString = json?["type"] as? String == "MultiLineString"
        isMultiPolygon = json?["type"] as? String == "MultiPolygon"
        if isPoint {
            let lng = (json?["coordinates"] as! [Double])[0]
            let lat = (json?["coordinates"] as! [Double])[1]
            point = (lat, lng)
        }
        if isMultiLineString {
            points = []
            guard let coordinates = json?["coordinates"] as? [NSArray] else { return }
            guard coordinates.count > 0 else { return }
            let realArray = coordinates[0]
            for item in realArray where item as? [Double] != nil {
                let lng = (item as! [Double])[0]
                let lat = (item as! [Double])[1]
                points?.append((lat, lng))
            }
        }
        if isMultiPolygon {
            points = []
            guard let coordinates = json?["coordinates"] as? [NSArray] else { return }
            guard coordinates.count > 0 else { return }
            let realArray = coordinates[0]
            guard realArray.count > 0 else { return }
            guard let trueArray = realArray[0] as? NSArray else { return }
            for item in trueArray where item as? [Double] != nil {
                let lng = (item as! [Double])[0]
                let lat = (item as! [Double])[1]
                points?.append((lat, lng))
            }
        }
    }
}

struct POIProperties {
    let district: String?
    let name: String?
    let secondName: String?
    let nameGreek: String?
    let nameRoman: String?
    
    init(with json: NSDictionary?) {
        district = json?["district_1"] as? String
        name = json?["name"] as? String
        secondName = json?["name2"] as? String
        nameGreek = json?["greek"] as? String
        nameRoman = json?["roman"] as? String
    }
}
