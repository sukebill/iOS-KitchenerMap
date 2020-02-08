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
    
    @IBOutlet var tableView: UITableView!
    
    private var data: HuaSettings? {
        return LayersHelper.shared.data
    }
    private let isGreek = LocaleHelper.shared.language == .greek
    private var selectedIndexPaths: [IndexPath] = []
    
    var onMapLayerSelectionChanged: ((LayerX?) -> Void)?
    var openedSections: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 54
        tableView.estimatedSectionHeaderHeight = 54
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = 50
        let headerNib = UINib.init(nibName: "MapLayersHeader", bundle: Bundle.main)
        tableView.register(nib: headerNib,
                           withHeaderFooterViewClass: MapLayersHeader.self)
    }
    
    func clearSelections() {
        tableView.reloadData()
    }
}

extension MapLayersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return (data?.baseMapGroups.count ?? 0) + (data?.layerGroups.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard openedSections.contains(section) else {
            return 0
        }
        if section < data?.baseMapGroups.count ?? 0 {
            return data?.baseMapGroups[section].layers.count ?? 0
        } else {
            return data?.layerGroups[section - (data?.baseMapGroups.count ?? 0)].layers.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var layers: [LayerX] = []
        if indexPath.section < data?.baseMapGroups.count ?? 0 {
            layers = data?.baseMapGroups[indexPath.section].layers ?? []
        } else {
            layers = data?.layerGroups[indexPath.section - (data?.baseMapGroups.count ?? 0)].layers ?? []
        }
        let item = layers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withClass: MapLayerTableViewCell.self)
        cell.setUp(name: isGreek ? item.name.el : item.name.en,
                   layerId: item.src,
                   layerX: item)
        return cell
    }
}

extension MapLayersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? MapLayerTableViewCell
        cell?.toggle()
        onMapLayerSelectionChanged?(cell?.layerX)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String? = ""
        if section < data?.baseMapGroups.count ?? 0 {
           let name = data?.baseMapGroups[section].name
           title = isGreek ? name?.el : name?.en
        } else {
           let name = data?.layerGroups[section - (data?.baseMapGroups.count ?? 0)].name
           title = isGreek ? name?.el : name?.en
        }
        let view = tableView.dequeueReusableHeaderFooterView(withClass: MapLayersHeader.self)
        view.name.text = title
        view.onTap = { [weak self] in
            self?.onHeaderTapped(section)
        }
        return view
    }
    
    private func onHeaderTapped(_ section: Int) {
        if openedSections.contains(section) {
            openedSections.removeAll(section)
        } else {
            openedSections.append(section)
        }
        tableView.reloadSections([section], with: .automatic)
    }
}
