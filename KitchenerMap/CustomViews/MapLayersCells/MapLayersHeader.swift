//
//  MapLayersHeader.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 08/02/2020.
//  Copyright © 2020 GiorgosHadj. All rights reserved.
//

import Foundation
import UIKit

class MapLayersHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var name: UILabel!
    var onTap: (() -> Void)?
    
    @IBAction func onViewTapped(_ sender: Any) {
        onTap?()
    }
}
