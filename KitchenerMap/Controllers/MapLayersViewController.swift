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
    
    private let data = LayersHelper.shared.data
    private let isGreek = LocaleHelper.shared.language == .greek
    private var selectedIndexPaths: [IndexPath] = []
    
    var onMapLayerSelectionChanged: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.expandableDelegate = self
        tableView.animation = .automatic
    }
}

extension MapLayersViewController: ExpandableDelegate {
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightsForExpandedRowAt indexPath: IndexPath) -> [CGFloat]? {
        return data[indexPath.row].layers.map { _ in 50 }
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {
        let layers = data[indexPath.row].layers
        var cells: [UITableViewCell] = []
        for item in layers {
            let cell = tableView.dequeueReusableCell(withClass: MapLayerTableViewCell.self)
            cell.setUp(name: isGreek ? item.name?.el : item.name?.en, layerId: item.src) 
            cells.append(cell)
        }
        return cells
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCell: UITableViewCell, didSelectExpandedRowAt indexPath: IndexPath) {
        (expandedCell as? MapLayerTableViewCell)?.toggle()
        onMapLayerSelectionChanged?()
        print("kfjhnvkjvfn")
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        print("dfhjkbvdfhjkbvj")
    }
    
    func expandableTableView(_ expandableTableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: MapLayerGroupCell.self)
        cell.layerGroupName.text = isGreek ? data[indexPath.row].name?.el : data[indexPath.row].name?.en
        return cell
    }
}
