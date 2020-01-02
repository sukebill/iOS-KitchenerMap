//
//  PolicyViewController.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 02/01/2020.
//  Copyright © 2020 GiorgosHadj. All rights reserved.
//

import UIKit
import WebKit

class PolicyViewController: UIViewController {
    @IBOutlet weak var webview: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    func load() {
        let isGreek = LocaleHelper.shared.language == .greek
        var urlString = "https://gaia.hua.gr/kitchener_review/privacy_$.html"
        urlString = urlString.replacingOccurrences(of: "$", with: isGreek ? "el" : "en")
        guard let url = URL(string: urlString) else { return }
        webview.load(URLRequest(url: url))
    }
}
