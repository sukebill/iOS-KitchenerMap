//
//  GravouraView.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 03/02/2020.
//  Copyright © 2020 GiorgosHadj. All rights reserved.
//

import Foundation
import MapKit
import HCMapInfoView
import Kingfisher

class GravouraView: HCMapInfoView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var subtitle: UILabel!
    
    var name: String?
    var image: String?
    var onTap: ((String?, String?) -> Void)?
    
    func refresh() {
        subtitle.text = name
        imageView.kf.setImage(with: URL(string: "https://gaia.hua.gr/" + (image ?? "")))
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        onTap?(name, image)
    }
}
