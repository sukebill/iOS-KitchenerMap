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
import MapCache

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var leftMenuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var lefMenuContainer: UIView!
    @IBOutlet weak var menuBackground: UIView!
    @IBOutlet weak var slider: KMSlider!
    @IBOutlet weak var sliderTopConstraint: NSLayoutConstraint!
    
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
    
    private var longPressMarker: GMSMarker?

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
    var mkOverlay: WMSMKTileOverlay?
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
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let reversedY = Int(pow(Double(2), Double(zoom))) - Int(y) - 1
            let newTemplate = "https://gaia.hua.gr/tms/kitchener_review/\(zoom)/\(x)/\(reversedY).jpg"
            return URL(string: newTemplate)
        }
        layer = GMSURLTileLayer(urlConstructor: urls)
        layer?.zIndex = 100
        layer?.tileSize = 256
//        layer?.map = mapView
        var config = MapCacheConfig(withUrlTemplate: "https://gaia.hua.gr/tms/kitchener_review/{z}/{x}/{y}.jpg")
        config.cacheName = "Kitchener"
        let mapCache = MapCache(withConfig: config)
        mapCache.clear(completition: {})
        mapCache.isYReversed = true
        _ = mapView.useCache(mapCache)
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
//        secondLayer?.map = mapView
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
//        thirdLayer?.map = mapView
    }
    
    private func setupTileRendererModernA() {
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let newTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/\(zoom)/\(y)/\(x).png"
            return URL(string: newTemplate)
        }
        modernLayerA = GMSURLTileLayer(urlConstructor: urls)
        modernLayerA?.zIndex = 102
        modernLayerA?.tileSize = 256
//        modernLayerA?.map = mapView
    }
    
    private func setupTileRendererModernB() {
        let urls: GMSTileURLConstructor = {(x, y, zoom) in
            let newTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/\(zoom)/\(y)/\(x).png"
            return URL(string: newTemplate)
        }
        modernLayerB = GMSURLTileLayer(urlConstructor: urls)
        modernLayerB?.zIndex = 103
        modernLayerB?.tileSize = 256
//        modernLayerB?.map = mapView
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
//        mapView.selectedMarker = nil
        let marker = GMSMarker(position: coordinate)
        let isGreek = LocaleHelper.shared.language == .greek
        marker.title = isGreek ? "Επιλεγμένο σημείο" : "Selected point"
        marker.snippet = isGreek ? "Θέλετε να αφήσετε σχόλιο;" : "would you like to add a comment?"
        marker.appearAnimation = .pop
//        marker.map = mapView
        longPressMarker = marker
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
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        updateNikosiaLayerLevel(mapView)
    }
    
    private func updateNikosiaLayerLevel(_ mapView: GMSMapView) {
        if (mapView.camera.zoom <= 15) {
            secondLayer?.opacity = 0
        } else if let opacity = layer?.opacity {
            secondLayer?.opacity = opacity
        }
    }
}

extension MapViewController: MenuDelegate {
    
    func didTapFilter() {
        closeDrawer()
        openSlider()
        slider.onChangeAction = { newValue in
            self.layer?.opacity = newValue
//            self.updateNikosiaLayerLevel(self.mapView)
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
        // TODO: zoom to feature location and open window
    }
}

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

let MERCATOR_OFFSET: Double = 268435456 // swiftlint:disable:this identifier_name
let MERCATOR_RADIUS: Double = 85445659.44705395 // swiftlint:disable:this identifier_name
struct PixelSpace {
    public var x: Double // swiftlint:disable:this identifier_name
    public var y: Double // swiftlint:disable:this identifier_name
}
