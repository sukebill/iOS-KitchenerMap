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
import MapCache

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
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
    private var kitchenerLayer: CachedTileOverlay?
    private var nicosiaLayer: CachedTileOverlay?
    private var lemessosLayer: CachedTileOverlay?
    private var modernLayerA: CachedTileOverlay?
    private var modernLayerB: CachedTileOverlay?
    private var mkOverlay: WMSMKTileOverlay?
//    private var polyline: GMSPolyline?
//    private var polygon: GMSPolygon?
//    private var longPressMarker: GMSMarker?
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
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
//        mapView.setMinZoom(7, maxZoom: 17.99)
//        mapView.isIndoorEnabled = false
//        mapView.settings.myLocationButton = true
        centerMapOnLocation(location: cyprusCenter)
    }

    private func setWMSLayer() {
        let layerWMS = WMSTileOverlay()
        
        if mkOverlay != nil {
            mapView.removeOverlay(mkOverlay!)
        }
        
        let urlkin = layerWMS.url.replacingOccurrences(of: "%s", with: LayersHelper.shared.formattedLayers)
        mkOverlay = WMSMKTileOverlay(urlArg: urlkin, useMercatorArg: true)
        mkOverlay?.canReplaceMapContent = false
        mkOverlay?.alpha = 1
        mapView.addOverlay(mkOverlay!)
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location,
                                        span: MKCoordinateSpan(latitudeDelta: 1.3,
                                                               longitudeDelta: 1.3))

        mapView.setRegion(region, animated: true)
    }

    private func setupTileRendererKitchener() {
        var config = MapCacheConfig(withUrlTemplate: "https://gaia.hua.gr/tms/kitchener_review/{z}/{x}/{y}.jpg")
        config.cacheName = "Kitchener"
        config.maximumZ = 16
        let mapCache = MapCache(withConfig: config)
        kitchenerLayer = mapView.useCache(mapCache, isGeometryFlipped: true)
    }
    
    
    private func setupTileRendererLeukosia() {
        var config = MapCacheConfig(withUrlTemplate: "https://gaia.hua.gr/tms/kitchener_nicosia_plan/{z}/{x}/{y}.png")
        config.cacheName = "Leukosia"
        config.minimumZ = 15
        let mapCache = MapCache(withConfig: config)
        nicosiaLayer = mapView.useCache(mapCache, isGeometryFlipped: true)
    }
    
    private func setupTileRendererLimasol() {
        var config = MapCacheConfig(withUrlTemplate: "https://gaia.hua.gr/tms/kitchener_limassol_plan/{z}/{x}/{y}.png")
        config.cacheName = "Limassol"
        config.minimumZ = 15
        let mapCache = MapCache(withConfig: config)
        lemessosLayer = mapView.useCache(mapCache, isGeometryFlipped: true)
    }
    
    private func setupTileRendererModernA() {
        var config = MapCacheConfig(withUrlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.png")
        config.cacheName = "World_Imagery"
        let mapCache = MapCache(withConfig: config)
        modernLayerA = mapView.useCache(mapCache, isGeometryFlipped: false)
        modernLayerA?.tileSize = CGSize(width: 256, height: 256)
    }
    
    private func setupTileRendererModernB() {
        var config = MapCacheConfig(withUrlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}.png")
        config.cacheName = "World_Topo_Map"
        let mapCache = MapCache(withConfig: config)
        modernLayerB = mapView.useCache(mapCache, isGeometryFlipped: false)
        modernLayerB?.tileSize = CGSize(width: 256, height: 256)
    }
    
    @objc private func clearFilters() {
        LayersHelper.shared.layers = []
        children.forEach {
            ($0 as? MenuViewController)?.clearMapLayers()
        }
//        layerWMS?.clearTileCache()
//        layerWMS?.map = nil
//        layerWMS = nil
        setWMSLayer()
//        longPressMarker?.map = nil
//        longPressMarker = nil
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
//        longPressMarker?.map = nil
//        mapView.selectedMarker = nil
//        let marker = GMSMarker(position: coordinate)
        let isGreek = LocaleHelper.shared.language == .greek
//        marker.title = isGreek ? "Επιλεγμένο σημείο" : "Selected point"
//        marker.snippet = isGreek ? "Θέλετε να αφήσετε σχόλιο;" : "would you like to add a comment?"
//        marker.appearAnimation = .pop
//        marker.map = mapView
//        longPressMarker = marker
//        mapView.selectedMarker = longPressMarker
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is WMSMKTileOverlay {
            let renderer = MKTileOverlayRenderer(overlay:overlay)
            renderer.alpha = (overlay as! WMSMKTileOverlay).alpha
            return renderer
        }
        return mapView.mapCacheRenderer(forOverlay: overlay)
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

//extension MapViewController: GMSMapViewDelegate {
//    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
//        addUserAnnotationOnMap(at: coordinate)
//    }
//
//    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
//        if marker == longPressMarker {
//            Route.feedback(coordinates: marker.position).push(from: self)
//        }
//    }
//
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        updateNikosiaLayerLevel(mapView)
//        updateLemesosLayerLevel(mapView)
//        featureWindow.isHidden = true
//    }
//
//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        updateNikosiaLayerLevel(mapView)
//    }
//
//    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
//        switch overlay {
//        case polyline, polygon:
//            if let feature = selectedFeature {
//                showInfoWindow(feature: feature)
//            }
//        default:
//            return
//        }
//    }
//
//    private func updateNikosiaLayerLevel(_ mapView: GMSMapView) {
//        if (mapView.camera.zoom <= 15) {
//            secondLayer?.opacity = 0
//        } else if let opacity = layer?.opacity {
//            secondLayer?.opacity = opacity
//        }
//    }
//
//    private func updateLemesosLayerLevel(_ mapView: GMSMapView) {
//        if (mapView.camera.zoom <= 15) {
//            thirdLayer?.opacity = 0
//        } else if let opacity = layer?.opacity {
//            thirdLayer?.opacity = opacity
//        }
//    }
//}

// MARK: Menu Drawer

extension MapViewController: MenuDelegate {
    
    func didTapFilter() {
        closeDrawer()
        openSlider()
        slider.onChangeAction = { newValue in
//            self.layer?.opacity = newValue
//            self.updateNikosiaLayerLevel(self.mapView)
//            self.layerWMS?.opacity = newValue
        }
        slider.onIdleAction = {
            self.closeSlider()
        }
    }
    
    func didSelectMapLayer(_ layer: LayerX) {
        switch layer.userOrder {
        case 2:
            if layer.src.contains("limassol") {
                if lemessosLayer == nil {
                    setupTileRendererLimasol()
                } else {
                    mapView.removeOverlay(lemessosLayer!)
                    lemessosLayer = nil
                }
            } else if layer.src.contains("nicosia") {
                if nicosiaLayer == nil {
                    setupTileRendererLeukosia()
                } else {
                    mapView.removeOverlay(nicosiaLayer!)
                    nicosiaLayer = nil
                }
            } else if layer.src.contains("kitchener") {
                if kitchenerLayer == nil {
                    setupTileRendererKitchener()
                } else {
                    mapView.removeOverlay(kitchenerLayer!)
                    kitchenerLayer = nil
                }
            }
        case 4:
            if modernLayerA == nil {
                setupTileRendererModernA()
            } else {
                mapView.removeOverlay(modernLayerA!)
                modernLayerA = nil
            }
        case 5:
            if modernLayerB == nil {
                setupTileRendererModernB()
            } else {
                mapView.removeOverlay(modernLayerB!)
                modernLayerB = nil
            }
        default:
            break
        }
        didSelectMapLayer()
    }
    
    func didSelectMapLayer() {
//        layerWMS?.clearTileCache()
//        layerWMS?.map = nil
//        layerWMS = nil
        setWMSLayer()
    }
    
    func didSelect(feature: Feature) {
        selectedFeature = feature
//        polyline?.map = nil
//        polygon?.map = nil
//        var points: [Geometry.Location] = []
//        if let point = feature.geometry?.point {
//            points.append(point)
//        }
//        if let geometryPoints = feature.geometry?.points {
//            points.append(contentsOf: geometryPoints)
//        }
//
//        let path = GMSMutablePath()
//        if points.count > 1 {
//            points.forEach { path.add(CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng))}
//            polyline = GMSPolyline(path: path)
//            polyline?.map = mapView
//            polyline?.strokeColor = .yellow
//            polyline?.strokeWidth = 10
//            polyline?.zIndex = 105
//            polyline?.isTappable = true
//
//            let bounds = GMSCoordinateBounds(path: path)
//            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
//            mapView.animate(with: update)
//        } else if points.count == 1 {
//            let point = points[0]
//            path.add(CLLocationCoordinate2D(latitude: point.lat - 0.0005, longitude: point.lng - 0.0004))
//            path.add(CLLocationCoordinate2D(latitude: point.lat + 0.0005, longitude: point.lng - 0.0004))
//            path.add(CLLocationCoordinate2D(latitude: point.lat + 0.0005, longitude: point.lng + 0.0004))
//            path.add(CLLocationCoordinate2D(latitude: point.lat - 0.0005, longitude: point.lng + 0.0004))
//
//            polygon = GMSPolygon(path: path)
//            polygon?.strokeWidth = 10
//            polygon?.strokeColor = .yellow
//            polygon?.zIndex = 105
//            polygon?.isTappable = true
//            polygon?.map = mapView
//
//            let update = GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: point.lat,
//                                                                          longitude: point.lng),
//                                                   zoom: 14)
//            mapView.animate(with: update)
//        }
        
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
