//
//  Interactor.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 01/12/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class Interactor {
    static let shared: Interactor = Interactor()
    private let textSearchBaseUrl = "https://gaia.hua.gr/geoserver/ows?service=wfs" +
                   "&version=2.0.0" +
                   "&request=GetFeature" +
                   "&typeName=kitchener:parametric_search_table2" +
                   "&outputFormat=application/json" +
                   "&viewparams=term:$" +
                   "&srsName=EPSG:4326"
    
    private var header = ["X-Credentials":"private-user=mobileAPIuser1&private-pw=OesomEtaT"]
    
    private init() {}
    
    func textSearch(_ text: String, onCompletion: @escaping (SearchResult) -> Void) {
        let url = textSearchBaseUrl.replacingOccurrences(of: "$", with: text)
        
        Alamofire.request(url, method: .get, headers: header).responseJSON { response in
            guard let data = response.result.value as? NSDictionary else { return }
            let searchResult = SearchResult(with: data)
            onCompletion(searchResult)
        }
    }
    
    func loadRepresentations(url: String, onCompletion: @escaping (Representation) -> Void) {
        Alamofire.request(url, method: .get, headers: header).responseJSON { (response) in
            guard let data = response.result.value as? NSDictionary else { return }
            let representation = Representation(with: data)
            onCompletion(representation)
        }
    }
    
    func loadFeatureOnLocation(_ location: CLLocationCoordinate2D, onCompletion: @escaping (Feature?) -> Void) {
        let latSW = (location.latitude - 0.05).string
        let lonSW = (location.longitude - 0.05).string
        let latNE = (location.latitude + 0.05).string
        let lonNE = (location.longitude + 0.05).string
        var baseUrl = "https://gaia.hua.gr/geoserver/ows?service=WMS" +
                "&version=1.3.0" +
                "&request=GetFeatureInfo" +
                "&SERVICE=WMS" +
                "&FORMAT=image/png" +
                "&TRANSPARENT=true" +
                "&INFO_FORMAT=application/json" +
                "&FEATURE_COUNT=1" +
                "&EXCEPTIONS=application/json" +
                "&QUERY_LAYERS=%t" +
                "&LAYERS=%s" +
                "&I=50" +
                "&J=50" +
                "&CRS=EPSG:4326" +
                "&STYLES=" +
                "&WIDTH=101" +
                "&HEIGHT=101" +
                "&BBOX=" + latSW + "," + lonSW + "," + latNE + "," + lonNE
        
        var layerString = LayersHelper.shared.formattedLayers
        if layerString == "" {
            layerString = LayersHelper.shared.allLayersUrlEncoded
        }
        baseUrl =  baseUrl.replacingOccurrences(of: "%t", with: layerString).replacingOccurrences(of: "%s", with: layerString)
        
        Alamofire.request(baseUrl, method: .get, headers: header).responseJSON { (response) in
            guard let data = response.result.value as? NSDictionary else { return }
            let searchResult = SearchResult(with: data)
            onCompletion(searchResult.features.first)
        }
    }
}
