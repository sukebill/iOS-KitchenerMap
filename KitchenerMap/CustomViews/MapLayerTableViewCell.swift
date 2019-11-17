//
//  MapLayerTableViewCell.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 17/11/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit
import M13Checkbox

class MapLayerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var layerName: UILabel!
    @IBOutlet weak var checkbox: M13Checkbox!
    
    private var layerId: String = ""

    func setUp(name: String?, layerId: String?) {
        self.layerId = layerId ?? ""
        layerName.text = name
        let isSelected = LayersHelper.shared.layers.contains(self.layerId)
        checkbox.setCheckState(isSelected ? .checked : .unchecked, animated: false)
    }
    
    func toggle() {
        checkbox.toggleCheckState()
        if LayersHelper.shared.layers.contains(layerId) {
            LayersHelper.shared.layers.removeAll(layerId)
        } else {
            LayersHelper.shared.layers.append(layerId)
        }
    }

}
