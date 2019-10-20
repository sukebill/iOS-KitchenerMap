//
//  Layer.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 20/10/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation

struct Layer {
    var type: String?
    var id: Int64?
    var nameID: String?
    var name: Name?
    var description: Description?
    var userOrder: Int64?
    var isOn: Bool?
    var opacity: Double?
    var src: String?
    var parent: String?
    
    init(with json: NSDictionary) {
        type = json["type"] as? String
        id = json["id"] as? Int64
        nameID = json["nameID"] as? String
        name = Name(with: json["name"] as? NSDictionary)
        description = Description(with: json["description"] as? NSDictionary)
        userOrder = json["userOrder"] as? Int64
        isOn = json["isOn"] as? Bool
        opacity = json["opacity"] as? Double
        src = json["src"] as? String
        parent = json["parent"] as? String
    }
}

struct Description {
    let el: String?
    let en: String?
    
    init(with json: NSDictionary?) {
        el = json?["el"] as? String
        en = json?["en"] as? String
    }
}
