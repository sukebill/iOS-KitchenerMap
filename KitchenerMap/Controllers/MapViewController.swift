//
//  ViewController.swift
//  KitchenerMap
//
//  Created by GiorgosHadj on 06/04/2019.
//  Copyright © 2019 GiorgosHadj. All rights reserved.
//

import UIKit
import SwifterSwift
import MapKit
import GoogleMaps

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var leftMenuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lefMenuContainer: UIView!
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var slider: KMSlider!
    @IBOutlet weak var sliderTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var featureWindow: UIView!
    @IBOutlet weak var featureTitle: UILabel!
    @IBOutlet weak var featureCategory: UILabel!
    @IBOutlet weak var featureCloseButton: UIButton!
    @IBOutlet weak var featurePoiName: UILabel!
    @IBOutlet weak var featureNameGreek: UILabel!
    @IBOutlet weak var featureNameEnglish: UILabel!
    @IBOutlet weak var featureSeconsName: UILabel!
    @IBOutlet weak var featureDistrict: UILabel!
    
    var tileRenderer: MKTileOverlayRenderer!
    private let cyprusCenter = CLLocationCoordinate2D(latitude: 34.997045, longitude: 33.190684)
    private let cyprusNEBound = CLLocationCoordinate2D(latitude: 35.831610, longitude: 34.718857)
    private let cyprusSWBound = CLLocationCoordinate2D(latitude: 34.510659, longitude: 32.266127)
    private var userAnnotation: UserAnnotation?
    private var layer: GMSURLTileLayer?
    private var secondLayer: GMSURLTileLayer?
    private var thirdLayer: GMSURLTileLayer?
    private var modernLayerA: GMSURLTileLayer?
    private var modernLayerB: GMSURLTileLayer?
    private var layerWMS: GMSURLTileLayer?
    private var polyline: GMSPolyline?
    private var polygon: GMSPolygon?
    private var longPressMarker: GMSMarker?
    private var selectedFeature: Feature?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocaleHelper.shared.language == .greek ? "Xάρτης Kitchener" : "Kitchener Map"
        setupTileRendererKitchener()
        setWMSLayer()
        setupMapView()
        setUpNavigationBar()
        children.forEach{($0 as? MenuViewController)?.delegate = self}
        debugPrint(LayersHelper.shared.data.debugDescription)
    }
    
    private func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(toggleDrawer))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(clearFilters))
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.setMinZoom(7, maxZoom: 17.99)
        mapView.isIndoorEnabled = false
        mapView.settings.myLocationButton = true
        centerMapOnLocation(location: cyprusCenter)
    }
    
    private func setWMSLayer() {
        let layerWMS = WMSTileOverlay()
        // Implement GMSTileURLConstructor
        // Returns a Tile based on the x,y,zoom coordinates, and the requested floor
        let urls: GMSTileURLConstructor = { (x: UInt, y: UInt, zoom: UInt) -> URL? in
            let bbox = layerWMS.bboxFromXYZ(x, y: y, z: zoom)
            var urlkin = layerWMS.url
            urlkin = urlkin.replacingOccurrences(of: "%f", with: "\(bbox.left)")
            urlkin = urlkin.replacingOccurrences(of: "%e", with: "\(bbox.bottom)")
            urlkin = urlkin.replacingOccurrences(of: "%d", with: "\(bbox.right)")
            urlkin = urlkin.replacingOccurrences(of: "%g", with: "\(bbox.top)")
            urlkin = urlkin.replacingOccurrences(of: "%s", with: LayersHelper.shared.formattedLayers)
            return URL(string: urlkin)
        }
        
        self.layerWMS = GMSURLTileLayer(urlConstructor: urls)
        self.layerWMS?.opacity = 1
        self.layerWMS?.zIndex = 200
        self.layerWMS?.tileSize = 256
        self.layerWMS?.map = mapView
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition(target: location, zoom: 12)
        mapView.animate(to: camera)
    }

    private func setupTileRendererKitchener() {
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let reversedY = Int(pow(Double(2), Double(zoom))) - Int(y) - 1
            let newTemplate = "https://gaia.hua.gr/tms/kitchener_review/\(zoom)/\(x)/\(reversedY).jpg"
            return URL(string: newTemplate)
        }
        layer = GMSURLTileLayer(urlConstructor: urls)
        layer?.zIndex = 100
        layer?.tileSize = 256
        layer?.map = mapView
    }
    
    
    private func setupTileRendererLeukosia() {
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let reversedY = Int(pow(Double(2), Double(zoom))) - Int(y) - 1
            let newTemplate = "https://gaia.hua.gr/tms/kitchener_nicosia_plan/\(zoom)/\(x)/\(reversedY).png"
            return URL(string: newTemplate)
        }
        secondLayer = GMSURLTileLayer(urlConstructor: urls)
        secondLayer?.zIndex = 101
        secondLayer?.tileSize = 256
        secondLayer?.map = mapView
    }
    
    private func setupTileRendererLimasol() {
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let reversedY = Int(pow(Double(2), Double(zoom))) - Int(y) - 1
            let newTemplate = "https://gaia.hua.gr/tms/kitchener_limassol_plan/\(zoom)/\(x)/\(reversedY).png"
            return URL(string: newTemplate)
        }
        thirdLayer = GMSURLTileLayer(urlConstructor: urls)
        thirdLayer?.zIndex = 101
        thirdLayer?.tileSize = 256
        thirdLayer?.map = mapView
    }
    
    private func setupTileRendererModernA() {
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let newTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/\(zoom)/\(y)/\(x).png"
            return URL(string: newTemplate)
        }
        modernLayerA = GMSURLTileLayer(urlConstructor: urls)
        modernLayerA?.zIndex = 102
        modernLayerA?.tileSize = 256
        modernLayerA?.map = mapView
    }
    
    private func setupTileRendererModernB() {
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let newTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/\(zoom)/\(y)/\(x).png"
            return URL(string: newTemplate)
        }
        modernLayerB = GMSURLTileLayer(urlConstructor: urls)
        modernLayerB?.zIndex = 103
        modernLayerB?.tileSize = 256
        modernLayerB?.map = mapView
    }
    
    @objc private func clearFilters() {
        LayersHelper.shared.layers = []
        children.forEach {
            ($0 as? MenuViewController)?.clearMapLayers()
        }
        layerWMS?.clearTileCache()
        layerWMS?.map = nil
        layerWMS = nil
        setWMSLayer()
        longPressMarker?.map = nil
        longPressMarker = nil
    }
    
    @objc private func toggleDrawer() {
        menuBackground.isHidden = leftMenuTrailingConstraint.constant != 0
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.leftMenuTrailingConstraint.constant = self.leftMenuTrailingConstraint.constant == 0 ? self.lefMenuContainer.frame.width : 0
            self.view.layoutIfNeeded()
        })
        children.forEach {
            ($0 as? MenuViewController)?.reloadSelections()
        }
    }
    
    private func closeDrawer() {
        menuBackground.isHidden = true
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.leftMenuTrailingConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func onMenuBackgroundTapped(_ sender: Any) {
        closeDrawer()
    }
    
    private func addUserAnnotationOnMap(at coordinate: CLLocationCoordinate2D) {
        longPressMarker?.map = nil
        mapView.selectedMarker = nil
        let marker = GMSMarker(position: coordinate)
        let isGreek = LocaleHelper.shared.language == .greek
        marker.title = isGreek ? "Επιλεγμένο σημείο" : "Selected point"
        marker.snippet = isGreek ? "Θέλετε να αφήσετε σχόλιο;" : "would you like to add a comment?"
        marker.appearAnimation = .pop
        marker.map = mapView
        longPressMarker = marker
        mapView.selectedMarker = longPressMarker
    }
    
    private func showInfoWindow(feature: Feature) {
        featureWindow.isHidden = false
        let isGreek = LocaleHelper.shared.language == .greek
        featureTitle.text = isGreek ? (feature.properties?.values?.nameEL ?? "Χωρίς Όνομα") : (feature.properties?.values?.nameEN ?? "No Name")
        featureCategory.text = isGreek ? feature.properties?.values?.categoryEL : feature.properties?.values?.categoryEN
        featurePoiName.text = feature.poiProperties.name
        featurePoiName.superview?.isHidden = feature.poiProperties.name == nil
        featureNameGreek.text = feature.poiProperties.nameGreek
        featureNameGreek.superview?.isHidden = feature.poiProperties.nameGreek == nil
        featureNameEnglish.text = feature.poiProperties.nameRoman
        featureNameEnglish.superview?.isHidden = feature.poiProperties.nameRoman == nil
        featureSeconsName.text = feature.poiProperties.secondName
        featureSeconsName.superview?.isHidden = feature.poiProperties.secondName == nil
        featureDistrict.text = feature.poiProperties.district
        featureDistrict.superview?.isHidden = feature.poiProperties.district == nil
    }
    
    @IBAction func onFeatureCloseTapped(_ sender: Any) {
        featureWindow.isHidden = true
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        addUserAnnotationOnMap(at: coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if marker == longPressMarker {
            Route.feedback(coordinates: marker.position).push(from: self)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        updateNikosiaLayerLevel(mapView)
        updateLemesosLayerLevel(mapView)
        featureWindow.isHidden = true
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updateNikosiaLayerLevel(mapView)
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        switch overlay {
        case polyline, polygon:
            if let feature = selectedFeature {
                showInfoWindow(feature: feature)
            }
        default:
            return
        }
    }
    
    private func updateNikosiaLayerLevel(_ mapView: GMSMapView) {
        if (mapView.camera.zoom <= 15) {
            secondLayer?.opacity = 0
        } else if let opacity = layer?.opacity {
            secondLayer?.opacity = opacity
        }
    }
    
    private func updateLemesosLayerLevel(_ mapView: GMSMapView) {
        if (mapView.camera.zoom <= 15) {
            thirdLayer?.opacity = 0
        } else if let opacity = layer?.opacity {
            thirdLayer?.opacity = opacity
        }
    }
}

// MARK: Menu Drawer

extension MapViewController: MenuDelegate {
    
    func didTapFilter() {
        closeDrawer()
        openSlider()
        slider.onChangeAction = { newValue in
            self.layer?.opacity = newValue
            self.updateNikosiaLayerLevel(self.mapView)
            self.layerWMS?.opacity = newValue
        }
        slider.onIdleAction = {
            self.closeSlider()
        }
    }
    
    func didSelectMapLayer(_ layer: LayerX) {
        switch layer.userOrder {
        case 2:
            if layer.src.contains("limassol") {
                if thirdLayer == nil {
                    setupTileRendererLimasol()
                } else {
                    thirdLayer?.map = nil
                    thirdLayer = nil
                }
            } else if layer.src.contains("nicosia") {
                if secondLayer == nil {
                    setupTileRendererLeukosia()
                } else {
                    secondLayer?.map = nil
                    secondLayer = nil
                }
            } else if layer.src.contains("kitchener") {
                if self.layer == nil {
                    setupTileRendererKitchener()
                } else {
                    self.layer?.map = nil
                    self.layer = nil
                }
            }
        case 4:
            if modernLayerA == nil {
                setupTileRendererModernA()
            } else {
                modernLayerA?.map = nil
                modernLayerA = nil
            }
        case 5:
            if modernLayerB == nil {
                setupTileRendererModernB()
            } else {
                modernLayerB?.map = nil
                modernLayerB = nil
            }
        default:
            break
        }
        didSelectMapLayer()
    }
    
    func didSelectMapLayer() {
        layerWMS?.clearTileCache()
        layerWMS?.map = nil
        layerWMS = nil
        setWMSLayer()
    }
    
    func didSelect(feature: Feature) {
        selectedFeature = feature
        polyline?.map = nil
        polygon?.map = nil
        var points: [Geometry.Location] = []
        if let point = feature.geometry?.point {
            points.append(point)
        }
        if let geometryPoints = feature.geometry?.points {
            points.append(contentsOf: geometryPoints)
        }
        
        let path = GMSMutablePath()
        if points.count > 1 {
            points.forEach { path.add(CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng))}
            polyline = GMSPolyline(path: path)
            polyline?.map = mapView
            polyline?.strokeColor = .yellow
            polyline?.strokeWidth = 10
            polyline?.zIndex = 105
            polyline?.isTappable = true
            
            let bounds = GMSCoordinateBounds(path: path)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapView.animate(with: update)
        } else if points.count == 1 {
            let point = points[0]
            path.add(CLLocationCoordinate2D(latitude: point.lat - 0.0005, longitude: point.lng - 0.0004))
            path.add(CLLocationCoordinate2D(latitude: point.lat + 0.0005, longitude: point.lng - 0.0004))
            path.add(CLLocationCoordinate2D(latitude: point.lat + 0.0005, longitude: point.lng + 0.0004))
            path.add(CLLocationCoordinate2D(latitude: point.lat - 0.0005, longitude: point.lng + 0.0004))
            
            polygon = GMSPolygon(path: path)
            polygon?.strokeWidth = 10
            polygon?.strokeColor = .yellow
            polygon?.zIndex = 105
            polygon?.isTappable = true
            polygon?.map = mapView
            
            let update = GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: point.lat,
                                                                          longitude: point.lng),
                                                   zoom: 14)
            mapView.animate(with: update)
        }
        
        showInfoWindow(feature: feature)
        
        closeDrawer()
    }
}

// MARK: Slider

extension MapViewController {
    
    private func openSlider() {
        slider.fadeIn(duration: 0.2)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.sliderTopConstraint.constant = self.slider.height
            self.view.layoutIfNeeded()
        })
        slider.open()
    }
    
    private func closeSlider() {
        slider.fadeOut(duration: 0.2)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.sliderTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        slider.close()
    }
}
