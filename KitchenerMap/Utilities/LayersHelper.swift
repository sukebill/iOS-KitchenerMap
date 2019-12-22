//
//  LayersHelper.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 20/10/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation
import SwifterSwift
import Alamofire

class LayersHelper {
    static var shared = LayersHelper()
    
    let allLayersUrlEncoded = "kitchener:cover_group," +
                                "kitchener:river_network_group," +
                                "kitchener:road_net_group," +
                                "kitchener:telegraph," +
                                "kitchener:borders_group," +
                                "kitchener:km_distance," +
                                "kitchener:point_data_group," +
                                "kitchener:text_town_group," +
                                "kitchener:toponym_po"
    private(set) var data: HuaSettings?
    var layers: [String] = []
    var formattedLayers: String {
        var result = ""
        for item in layers {
            result += item + ","
        }
        result = result.replacingOccurrences(of: "null,", with: "")
        result = result.removingSuffix(",")
        return result
    }
    private let url = "https://gaia.hua.gr/kitchener_review/js/settings_web.json"
    
    private init() {
        Alamofire.request(url, method: .get).responseJSON { [weak self] response in
            self?.data = HuaSettings(with: response.result.value as? NSDictionary)
        }
    }
}
