//
//  Base.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 20/10/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation

struct Base {
    var id: Int?
    var name: Name?
    var groupIsOn: Bool?
    var groupIsClosed: Bool?
    var userOrder: Int?
    var opacity: Double?
    var type: String?
    var layers: [Layer] = []
    
    init(with json: NSDictionary) {
        id = json["id"] as? Int
        name = Name(with: json["name"] as? NSDictionary)
        groupIsOn = json["groupIsOn"] as? Bool
        groupIsClosed = json["groupIsClosed"] as? Bool
        opacity = json["opacity"] as? Double
        type = json["type"] as? String
        userOrder = json["userOrder"] as? Int
        if let array = json["layers"] as? [NSDictionary] {
            array.forEach {
                layers.append(Layer(with: $0))
            }
        }
    }
}

struct Name {
    let el: String?
    let en: String?
    
    init(with json: NSDictionary?) {
        el = json?["el"] as? String
        en = json?["en"] as? String
    }
}
