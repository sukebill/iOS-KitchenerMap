//
//  FeedbackViewController.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 20/10/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isGreek = LocaleHelper.shared.language == .greek
        let greekText = "Η εφαρμογή υποστηρίζει τη δυνατότητα αποστολής μιας τοποθεσίας μαζί με την φωτογραφία σας. Για να το κπάνετε αυτό, πατήστε παρατεταμένα πάνω σε ένα σημείο στο χάρτη και έπειτα πατήστε στο παράθυρο πάνω από την πινέζα."
        let englishText = "This application lets you send us a location with your own comment and photo. Just press on the map for two seconds and then press on the marker's infi window"
        label.text = isGreek ? greekText : englishText
    }
}
