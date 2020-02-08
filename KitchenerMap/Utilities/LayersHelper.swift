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
    var layers: [LayerX] = []
    var formattedLayers: String {
        var result = ""
        let sortedLayers = layers.sorted { $0.userOrder < $1.userOrder }.map { $0.src }
        for item in sortedLayers {
            result += item + ","
        }
        result = result.replacingOccurrences(of: "null,", with: "")
        result = result.removingSuffix(",")
        return result
    }
    private let url = "https://gaia.hua.gr/kitchener_review/js/settings_web.json"
    private var header = ["X-Application-Request-Origin":"mobileSet=mobileAPIuser1&mobileSubSet=OesomEtaT"]
    
    private init() {
        Alamofire.request(url, method: .get, headers: header).responseJSON { [weak self] response in
            self?.data = HuaSettings(with: response.result.value as? NSDictionary)
            guard let kitchenerMapLayer = self?.data?.baseMapGroups.first?.layers.first else { return }
            self?.layers.append(kitchenerMapLayer)
        }
    }
}
