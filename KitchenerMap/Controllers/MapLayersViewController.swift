//
//  MapLayersViewController.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 20/10/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit
import ExpandableCell

class MapLayersViewController: UIViewController {
    
    @IBOutlet var tableView: ExpandableTableView!
    
    private var data: HuaSettings? {
        return LayersHelper.shared.data
    }
    private let isGreek = LocaleHelper.shared.language == .greek
    private var selectedIndexPaths: [IndexPath] = []
    
    var onMapLayerSelectionChanged: ((LayerX?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.expandableDelegate = self
        tableView.animation = .left
    }
    
    func clearSelections() {
        tableView.reloadData()
    }
}

extension MapLayersViewController: ExpandableDelegate {
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightsForExpandedRowAt indexPath: IndexPath) -> [CGFloat]? {
        if indexPath.row < data?.baseMapGroups.count ?? 0 {
            return data?.baseMapGroups[indexPath.row].layers.map { _ in 50 }
        } else {
            return data?.layerGroups[indexPath.row - (data?.baseMapGroups.count ?? 0)].layers.map { _ in 50 }
        }
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {
        var layers: [LayerX] = []
        if indexPath.row < data?.baseMapGroups.count ?? 0 {
            layers = data?.baseMapGroups[indexPath.row].layers ?? []
        } else {
            layers = data?.layerGroups[indexPath.row - (data?.baseMapGroups.count ?? 0)].layers ?? []
        }
        var cells: [UITableViewCell] = []
        for item in layers {
            let cell = tableView.dequeueReusableCell(withClass: MapLayerTableViewCell.self)
            cell.setUp(name: isGreek ? item.name.el : item.name.en,
                       layerId: item.src,
                       layerX: item)
            cells.append(cell)
        }
        return cells
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCell: UITableViewCell, didSelectExpandedRowAt indexPath: IndexPath) {
        (expandedCell as? MapLayerTableViewCell)?.toggle()
        onMapLayerSelectionChanged?((expandedCell as? MapLayerTableViewCell)?.layerX)
    }
    
    func expandableTableView(_ expandableTableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
         return (data?.baseMapGroups.count ?? 0) + (data?.layerGroups.count ?? 0)
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: MapLayerGroupCell.self)
        if indexPath.row < data?.baseMapGroups.count ?? 0 {
            cell.layerGroupName.text = isGreek ? data?.baseMapGroups[indexPath.row].name.el : data?.baseMapGroups[indexPath.row].name.en
        } else {
            let offset = data?.baseMapGroups.count ?? 0
            cell.layerGroupName.text = isGreek ? data?.layerGroups[indexPath.row - offset].name.el : data?.layerGroups[indexPath.row - offset].name.en
        }
        return cell
    }
}
