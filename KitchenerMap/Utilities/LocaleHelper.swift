//
//  LocaleHelper.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 20/10/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import Foundation

enum Language: String {
    case greek
    case other
}

class LocaleHelper {
    static let shared = LocaleHelper()
    private let key = "KITCHENERLOCALE"
    var language: Language
    
    private init() {
        language = Language(rawValue: UserDefaults().object(forKey: key) as? String ?? "greek") ?? .greek
    }
    
    func saveLanguage(_ language: Language) {
        self.language = language
        UserDefaults().set(language.rawValue, forKey: key)
    }
}
