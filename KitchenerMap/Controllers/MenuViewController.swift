//
//  MenuViewController.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 07/04/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit

protocol MenuDelegate: class {
    func didTapFilter()
    func didSelectMapLayer()
    func didSelect(feature: Feature)
    func didSelectMapLayer(_ layer: LayerX) 
}

class MenuViewController: UIViewController {
    @IBOutlet weak var languaheLabel: UILabel!
    @IBOutlet weak var mapLayersButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var transparencyButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapLayersView: UIView!
    @IBOutlet weak var searchView: UIView!
    
    var delegate: MenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapLayersSetup()
        searchViewSetup()
    }
    
    @IBAction func onGreekTapped(_ sender: Any) {
        LocaleHelper.shared.saveLanguage(.greek)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapViewController")
        parent?.navigationController?.setViewControllers([vc], animated: true)
    }
    
    @IBAction func onEnglishTapped(_ sender: Any) {
        LocaleHelper.shared.saveLanguage(.other)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapViewController")
        parent?.navigationController?.setViewControllers([vc], animated: true)
    }
    
    @IBAction func onLayersTapped(_ sender: Any) {
        titleLabel.text = LocaleHelper.shared.language == .greek ? "Χαρτογραφικά επίπεδα" : "Map Layers"
        topView.isHidden = false
        mapLayersView.isHidden = false
        let vc = children.filter { $0 is MapLayersViewController }.first as? MapLayersViewController
        vc?.tableView.reloadData()
    }
    
    @IBAction func onSearchTapped(_ sender: Any) {
        titleLabel.text = LocaleHelper.shared.language == .greek ? "Αναζήτηση σημείου" : "Search for a place"
        topView.isHidden = false
        searchView.isHidden = false
    }
    
    @IBAction func onAboutTapped(_ sender: Any) {
    }
    
    @IBAction func onTransparencyTapped(_ sender: Any) {
        delegate?.didTapFilter()
    }
    
    @IBAction func onFeddbackTapped(_ sender: Any) {
        titleLabel.text = LocaleHelper.shared.language == .greek ? "Ανατροφοδότηση" : "Feedback"
        topView.isHidden = false
        feedbackView.isHidden = false
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        [feedbackView, mapLayersView, searchView, topView].forEach {
            $0?.isHidden = true
        }
    }
}

extension MenuViewController {
    private func mapLayersSetup() {
        let vc = children.filter { $0 is MapLayersViewController }.first as? MapLayersViewController
        vc?.onMapLayerSelectionChanged = { [weak self] layer in
            self?.delegate?.didSelectMapLayer()
        }
    }
    
    func clearMapLayers() {
        let vc = children.filter { $0 is MapLayersViewController }.first as? MapLayersViewController
        vc?.clearSelections()
    }
    
    func reloadSelections() {
        let vc = children.filter { $0 is MapLayersViewController }.first as? MapLayersViewController
        vc?.tableView.reloadData()
    }
}

extension MenuViewController {
    private func searchViewSetup() {
        let vc = children.filter { $0 is SearchViewController }.first as? SearchViewController
        vc?.onFeatureSelected = { [weak self] feature in
            self?.delegate?.didSelect(feature: feature)
        }
    }
}
