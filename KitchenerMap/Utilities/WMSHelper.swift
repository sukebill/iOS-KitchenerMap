//
//  WMSHelper.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 20/10/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation

struct WMSHelper {
    static let shared = WMSHelper()
    
    var mapLayersUrl =  "https://gaia.hua.gr/geoserver/ows?service=WMS&resource=02422ff9-9e60-430f-bbc5-bb5324359198" +
                        "&version=1.3.0" +
                        "&request=GetMap" +
                        "&layers=%s" +
                        "&bbox=%f,%e,%d,%g" +
                        "&width=256" +
                        "&height=256" +
                        "&srs=EPSG:3857" +
                        "&format=image/png" +
                        "&transparent=true"
    
    var infoFormat = "https://gaia.hua.gr/geoserver/ows?service=WMS&resource=02422ff9-9e60-430f-bbc5-bb5324359198" +
                        "&version=1.3.0" +
                        "&INFO_FORMAT=application/json" +
                        "&REQUEST=GetFeatureInfo" +
                        "&LAYERS=%s" +
                        "&bbox=%f,%e,%d,%g" +
                        "&QUERY_LAYERS=%t" +
                        "&bbox=%f,%e,%d,%g" +
                        "&width=256" +
                        "&height=256" +
                        "&srs=EPSG:3857"
    
    var featureInfoString = ""
    
    private init() {}
}
