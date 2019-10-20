//
//  SearchResult.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 20/10/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation

struct SearchResult {
    let type: String?
    let features: [Feature]
    let numbersReturned: Int
    let crs: Crs?
    
    init(with json: NSDictionary) {
        type = json["type"] as? String
        numbersReturned = json["numberReturned"] as? Int ?? 0
        crs = Crs(with: json["crs"] as? NSDictionary)
        let array = json["features"] as? [NSDictionary]
        var featureArray = [Feature]()
        for json in array ?? [] {
            featureArray.append(Feature(with: json))
        }
        let isGreek = LocaleHelper.shared.language == .greek
        featureArray.sort {
            isGreek ? ($0.properties?.values?.nameEL ?? "" < $1.properties?.values?.nameEL ?? "")
                : ($0.properties?.values?.nameEN ?? "" < $1.properties?.values?.nameEN ?? "")
        }
        features = featureArray
    }
}

struct Crs {
    let type: String?
    
    init(with json: NSDictionary?) {
        type = json?["type"] as? String
    }
}
