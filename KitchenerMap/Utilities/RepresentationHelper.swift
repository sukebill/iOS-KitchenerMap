//
//  RepresentationHelper.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 03/02/2020.
//  Copyright © 2020 GiorgosHadj. All rights reserved.
//

import Foundation

class RepresentationHelper {
    static let shared = RepresentationHelper()
    
    private var representationEl: Representation?
    private var representationEn: Representation?
    
    var data: Representation? {
        LocaleHelper.shared.language == .greek ? representationEl : representationEn
    }
    
    private init() {
        load()
    }
    
    func load() {
        if let dict = UserDefaults.standard.dictionary(forKey: "representationEl") {
            representationEl = Representation(with: dict as NSDictionary)
        }
        if let dict = UserDefaults.standard.dictionary(forKey: "representationEn") {
            representationEn = Representation(with: dict as NSDictionary)
        }
        loadFromNetwork()
    }
    
    func loadFromNetwork() {
        Interactor.shared.loadRepresentations(url: "https://gaia.hua.gr/el/coastal_cyprus/visualrepresentations/json") { [weak self] (data) in
            self?.representationEl = data
            UserDefaults.standard.set(try? JSONEncoder().encode(data),
                                      forKey: "representationEl")
        }
        
        Interactor.shared.loadRepresentations(url: "https://gaia.hua.gr/en/coastal_cyprus/visualrepresentations/json") { [weak self] (data) in
            self?.representationEn = data
            UserDefaults.standard.set(try? JSONEncoder().encode(data),
                                      forKey: "representationEn")
        }
    }
}
