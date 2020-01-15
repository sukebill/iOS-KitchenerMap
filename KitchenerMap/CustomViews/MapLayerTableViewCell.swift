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
    
    var layerX: LayerX!
    private var id: String = ""

    func setUp(name: String?, layerId: String?, layerX: LayerX) {
        self.layerX = layerX
        checkbox.isUserInteractionEnabled = false
        id = layerId ?? ""
        layerName.text = name
        let isSelected = LayersHelper.shared.layers.contains { (layer) -> Bool in
            layer.src == layerX.src
        }
        checkbox.setCheckState(isSelected ? .checked : .unchecked, animated: false)
    }
    
    func toggle() {
        checkbox.toggleCheckState()
        if LayersHelper.shared.layers.contains(where: { (layer) -> Bool in
            layer.src == layerX.src
        }){
            LayersHelper.shared.layers.removeAll { (layer) -> Bool in
                layer.src == layerX.src
            }
        } else {
            LayersHelper.shared.layers.append(layerX)
        }
    }
}
