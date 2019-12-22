//
//  HUASettings.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 21/12/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation

struct HuaSettings {
    let baseMapGroups: [BaseMapGroup]
    let introJS: IntroJS
    let layerGroups: [LayerGroup]
    let settings: Settings
    
    init(with json: NSDictionary?) {
        var baseMaps: [BaseMapGroup] = []
        if let array = json?["baseMapGroups"] as? [NSDictionary] {
            array.forEach { baseMaps.append(BaseMapGroup(with: $0)) }
        }
        baseMapGroups = baseMaps
        introJS = IntroJS(with: json?["introJS"] as? NSDictionary)
        var layers: [LayerGroup] = []
        if let array = json?["layerGroups"] as? [NSDictionary] {
            array.forEach { layers.append(LayerGroup(with: $0)) }
        }
        layers.removeAll { $0.type == "WMSContainer" }
        layerGroups = layers
        settings = Settings(with: json?["settings"] as? NSDictionary)
    }
}

struct BaseMapGroup {
    let alwaysOn: Bool
    let description: Description
    let groupIsClosed: Bool
    let groupIsOn: Bool
    let hasTurnOffAllLayersButton: Bool
    let id: Int
    let layers: [LayerX]
    let name: Name
    let opacity: Int
    let userOrder: Int
    
    init(with json: NSDictionary?) {
        alwaysOn = json?["alwaysOn"] as? Bool ?? false
        description = Description(with: json?["description"] as? NSDictionary)
        groupIsClosed = json?["groupIsClosed"] as? Bool ?? false
        groupIsOn = json?["groupIsOn"] as? Bool ?? false
        hasTurnOffAllLayersButton = json?["hasTurnOffAllLayersButton"] as? Bool ?? false
        id = json?["id"] as? Int ?? 0
        name = Name(with: json?["name"] as? NSDictionary)
        opacity = json?["opacity"] as? Int ?? 0
        userOrder = json?["userOrder"] as? Int ?? 0
        var layers: [LayerX] = []
        guard let array = json?["layers"] as? [NSDictionary] else {
            self.layers = []
            return
        }
        for item in array {
            layers.append(LayerX(with: item))
        }
        layers.removeAll { $0.type == "OSM" }
        self.layers = layers
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

struct Layer {
    let  attribution: Attribution
    let  bounds: [Double]
    let  description: Description
    let  geometryType: String
    let  id: Int?
    let  isOn: Bool
    let  name: Name
    let  opacity: Double?
    let  properties: [Any]
    let  src: String?
    let  type: String?
    let  userOrder: Int?
    
    init(with json: NSDictionary?) {
        attribution = Attribution(with: json?["attribution"] as? NSDictionary)
        bounds = json?["bounds"] as? [Double] ?? []
        description = Description(with: json?["description"] as? NSDictionary)
        geometryType = json?["geometryType"] as? String ?? ""
        id = json?["id"] as? Int
        isOn = json?["isOn"] as? Bool ?? false
        name = Name(with: json?["name"] as? NSDictionary)
        opacity = json?["opacity"] as? Double
        src = json?["src"] as? String
        type = json?["type"] as? String
        userOrder = json?["userOrder"] as? Int
        properties = json?["properties"] as? [Any] ?? []
    }
}

struct LayerX {
    let  bounds: [Double]?
    let  description: Description
    let  id: String
    let  isOn: Bool
    let  name: Name
    let  opacity: Double
    let  parent: String?
    let  src: String
    let  type: String
    let  userOrder: Int
    
    init(with json: NSDictionary?) {
        bounds = json?["bounds"] as? [Double] ?? []
        description = Description(with: json?["description"] as? NSDictionary)
        id = json?["id"] as? String ?? ""
        isOn = json?["isOn"] as? Bool ?? false
        name = Name(with: json?["name"] as? NSDictionary)
        opacity = json?["opacity"] as? Double ?? 0
        parent = json?["parent"] as? String
        src = json?["src"] as? String ?? ""
        type = json?["type"] as? String ?? ""
        userOrder = json?["userOrder"] as? Int ?? 0
    }
}

struct Attribution {
    let  el: String
    let  en: String
    
    init(with json: NSDictionary?) {
        el = json?["el"] as? String ?? ""
        en = json?["en"] as? String ?? ""
    }
}

struct IntroJS {
    let  intro1: Intro
    let  intro10: Intro
    let  intro11: Intro
    let  intro12: Intro
    let  intro13: Intro
    let  intro14: Intro
    let  intro15: Intro
    let  intro16: Intro
    let  intro17: Intro
    let  intro18: Intro
    let  intro19: Intro
    let  intro2: Intro
    let  intro3: Intro
    let  intro4: Intro
    let  intro5: Intro
    let  intro6: Intro
    let  intro7: Intro
    let  intro8: Intro
    let  intro9: Intro
    
    init(with json: NSDictionary?) {
        intro1 = Intro(with: json?["intro1"] as? NSDictionary)
        intro2 = Intro(with: json?["intro2"] as? NSDictionary)
        intro3 = Intro(with: json?["intro3"] as? NSDictionary)
        intro4 = Intro(with: json?["intro4"] as? NSDictionary)
        intro5 = Intro(with: json?["intro5"] as? NSDictionary)
        intro6 = Intro(with: json?["intro6"] as? NSDictionary)
        intro7 = Intro(with: json?["intro7"] as? NSDictionary)
        intro8 = Intro(with: json?["intro8"] as? NSDictionary)
        
        intro9 = Intro(with: json?["intro9"] as? NSDictionary)
        intro10 = Intro(with: json?["intro10"] as? NSDictionary)
        intro11 = Intro(with: json?["intro11"] as? NSDictionary)
        intro12 = Intro(with: json?["intro12"] as? NSDictionary)
        intro13 = Intro(with: json?["intro13"] as? NSDictionary)
        intro14 = Intro(with: json?["intro14"] as? NSDictionary)
        intro15 = Intro(with: json?["intro15"] as? NSDictionary)
        intro16 = Intro(with: json?["intro16"] as? NSDictionary)
        
        intro17 = Intro(with: json?["intro17"] as? NSDictionary)
        intro18 = Intro(with: json?["intro18"] as? NSDictionary)
        intro19 = Intro(with: json?["intro19"] as? NSDictionary)
    }
}

struct Intro {
    let  el: String
    let  en: String
    
    init(with json: NSDictionary?) {
        el = json?["el"] as? String ?? ""
        en = json?["en"] as? String ?? ""
    }
}

struct LayerGroup {
    let  basemapID: Int
    let  description: Description
    let  groupIsClosed: Bool
    let  groupIsOn: Bool
    let  hasTurnOffAllLayersButton: Bool
    let  hide: Bool
    let  id: Int
    let  layers: [LayerX]
    let  name: Name
    let  opacity: Int
    let  sortLayers: String?
    let  type: String
    let  userOrder: Int
    
    init(with json: NSDictionary?) {
        basemapID = json?["basemapID"] as? Int ?? 0
        description = Description(with: json?["description"] as? NSDictionary)
        groupIsClosed = json?["groupIsClosed"] as? Bool ?? false
        groupIsOn = json?["groupIsOn"] as? Bool ?? false
        hasTurnOffAllLayersButton = json?["hasTurnOffAllLayersButton"] as? Bool ?? false
        hide = json?["hide"] as? Bool ?? false
        id = json?["id"] as? Int ?? 0
        opacity = json?["opacity"] as? Int ?? 0
        name = Name(with: json?["name"] as? NSDictionary)
        sortLayers = json?["sortLayers"] as? String
        type = json?["type"] as? String ?? ""
        userOrder = json?["userOrder"] as? Int ?? 0
        var layers: [LayerX] = []
        guard let array = json?["layers"] as? [NSDictionary] else {
            self.layers = []
            return
        }
        for item in array {
            layers.append(LayerX(with: item))
        }
        self.layers = layers
    }
}

struct Settings {
    let  defaultZoom: Int
    let  historicMaps: HistoricMaps
    let  host: String?
    let  initialExtent: [Double]?
    let  initialMapCenter: [Int]?
    let  initialMapZoom: Double?
    let  lang: String?
    let  languages: [String]
    let  mapExtents: MapExtents
    let  maxNumberOfSearchResults: Int
    let  maxZoom: Int
    let  minZoom: Int
    let  path: String?
    
    init(with json: NSDictionary?) {
        defaultZoom = json?["defaultZoom"] as? Int ?? 12
        historicMaps = HistoricMaps(with: json?["defaultZoom"] as? NSDictionary)
        host = json?["host"] as? String
        initialExtent = json?["initialExtent"] as? [Double]
        initialMapCenter = json?["initialMapCenter"] as? [Int]
        initialMapZoom = json?["initialMapZoom"] as? Double ?? 12
        lang = json?["lang"] as? String
        languages = json?["languages"] as? [String] ?? []
        mapExtents = MapExtents(with: json?["mapExtents"] as? NSDictionary)
        maxNumberOfSearchResults = json?["maxNumberOfSearchResults"] as? Int ?? 1
        maxZoom = json?["maxZoom"] as? Int ?? 17
        minZoom = json?["minZoom"] as? Int ?? 7
        path = json?["path"] as? String
    }
}

struct HistoricMaps {
    let  cyprus: Cyprus
    let  lemessos: Lemessos
    let  nicosia: Nicosia
    
    init(with json: NSDictionary?) {
        cyprus = Cyprus(with: json?["cyprus"] as? NSDictionary)
        lemessos = Lemessos(with: json?["cyprus"] as? NSDictionary)
        nicosia = Nicosia(with: json?["cyprus"] as? NSDictionary)
    }
}

struct Cyprus {
    let  layerID: Int?
    
    init(with json: NSDictionary?) {
        layerID = json?["layerID"] as? Int
    }
}

struct Lemessos {
    let  layerID: Int?
    
    init(with json: NSDictionary?) {
        layerID = json?["layerID"] as? Int
    }
}

struct Nicosia {
    let  layerID: Int?
    
    init(with json: NSDictionary?) {
       layerID = json?["layerID"] as? Int
   }
}

struct MapExtents {
    let  cyprus: [Double]?
    let  lemessos: [Double]?
    let  nicosia: [Double]?
    
    init(with json: NSDictionary?) {
        cyprus = json?["cyprus"] as? [Double]
        lemessos = json?["lemessos"] as? [Double]
        nicosia = json?["nicosia"] as? [Double]
    }
}
