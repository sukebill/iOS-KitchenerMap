//
//  Interactor.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 01/12/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation
import Alamofire

class Interactor {
    static let shared: Interactor = Interactor()
    private let textSearchBaseUrl = "https://gaia.hua.gr/geoserver/ows?service=wfs" +
                   "&version=2.0.0" +
                   "&request=GetFeature" +
                   "&typeName=kitchener:parametric_search_table2" +
                   "&outputFormat=application/json" +
                   "&viewparams=term:$" +
                   "&resource=02422ff9-9e60-430f-bbc5-bb5324359198" +
                   "&srsName=EPSG:4326"
    
    private init() {}
    
    func textSearch(_ text: String, onCompletion: @escaping (SearchResult) -> Void) {
        let url = textSearchBaseUrl.replacingOccurrences(of: "$", with: text)
        
        Alamofire.request(url, method: .get).responseJSON { response in
            guard let data = response.result.value as? NSDictionary else { return }
            let searchResult = SearchResult(with: data)
            onCompletion(searchResult)
        }
    }
}
