//
//  MenuViewController.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 07/04/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit
import SafariServices

protocol MenuDelegate: class {
    func didTapFilter()
    func didSelectMapLayer()
    func didSelect(feature: Feature)
    func didSelectMapLayer(_ layer: LayerX)
    func didSelectRepresentations()
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
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var policyView: UIView!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var representationButton: UIButton!
    
    var delegate: MenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapLayersSetup()
        searchViewSetup()
        setUpText()
    }
    
    private func setUpText() {
        let isGreek = LocaleHelper.shared.language == .greek
        languaheLabel.text = isGreek ? "Γλώσσα:" : "Language:"
        searchButton.setTitleForAllStates(isGreek ? "Αναζήτηση Σημείου" : "Search for a Place")
        mapLayersButton.setTitleForAllStates(isGreek ? "Χαρτογραφικά Επίπεδα" : "Map Layers")
        representationButton.setTitleForAllStates(isGreek ? "Αναπαραστάσεις" : "Representations")
        transparencyButton.setTitleForAllStates(isGreek ? "Χαρτογραφικό Υπόβαθρο" : "Background Basemaps")
        feedbackButton.setTitleForAllStates(isGreek ? "Ανατροφοδότηση" : "Feedback")
        aboutButton.setTitleForAllStates(isGreek ? "Σχετικά με την Εφαρμογή" : "About the App")
        termsButton.setTitleForAllStates(isGreek ? "Όροι Χρήσης" : "Terms of Service")
        privacyButton.setTitleForAllStates(isGreek ? "Πολιτική Απορρήτου" : "Privacy Policy")
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
        titleLabel.text = LocaleHelper.shared.language == .greek ? "Σχετικά με την εφαρμογή" : "About this app"

        topView.isHidden = false
        aboutView.isHidden = false
    }
    
    @IBAction func onTermsTapped(_ sender: Any) {
        let isGreek = LocaleHelper.shared.language == .greek
        var urlString = "https://gaia.hua.gr/kitchener_review/terms_$.html"
        urlString = urlString.replacingOccurrences(of: "$", with: isGreek ? "el" : "en")
        guard let url = URL(string: urlString) else { return }
        let svc = SFSafariViewController(url: url)
        parent?.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func onPolicyTapped(_ sender: Any) {
        let isGreek = LocaleHelper.shared.language == .greek
        var urlString = "https://gaia.hua.gr/kitchener_review/privacy_$.html"
        urlString = urlString.replacingOccurrences(of: "$", with: isGreek ? "el" : "en")
        guard let url = URL(string: urlString) else { return }
        let svc = SFSafariViewController(url: url)
        parent?.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func onTransparencyTapped(_ sender: Any) {
        delegate?.didTapFilter()
    }
    
    @IBAction func onFeddbackTapped(_ sender: Any) {
        titleLabel.text = LocaleHelper.shared.language == .greek ? "Ανατροφοδότηση" : "Feedback"
        topView.isHidden = false
        feedbackView.isHidden = false
    }
    
    @IBAction func onSilviaTapped(_ sender: Any) {
        let isGreek = LocaleHelper.shared.language == .greek
        let urlString = isGreek ? "https://www.sylviaioannoufoundation.org/el/" : "https://www.sylviaioannoufoundation.org/en/"
        guard let url = URL(string: urlString) else { return }
        let svc = SFSafariViewController(url: url)
        parent?.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func onHarokopioTapped(_ sender: Any) {
        let urlString = "https://www.hua.gr"
        guard let url = URL(string: urlString) else { return }
        let svc = SFSafariViewController(url: url)
        parent?.present(svc, animated: true, completion: nil)
    }
    
    @IBAction func onCancelTapped(_ sender: Any) {
        [feedbackView, mapLayersView, searchView, topView, aboutView, termsView, policyView].forEach {
            $0?.isHidden = true
        }
    }
    
    @IBAction func onRepresentationTapped(_ sender: UIButton) {
        delegate?.didSelectRepresentations()
    }
}

extension MenuViewController {
    private func mapLayersSetup() {
        let vc = children.filter { $0 is MapLayersViewController }.first as? MapLayersViewController
        vc?.onMapLayerSelectionChanged = { [weak self] layer in
            if let layer = layer, layer.type == "tile" {
                self?.delegate?.didSelectMapLayer(layer)
                return
            }
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
