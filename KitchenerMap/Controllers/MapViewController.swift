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
import HCMapInfoView
import SafariServices
import CoreLocation

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
    private var polyline: MKPolyline?
    private var polygon: MKPolygon?
    private var longPressMarker: MKPointAnnotation?
    private var selectedFeature: Feature?
    private var overlayAlpha: CGFloat = 1
    private var isChangingAlpha: Bool = false
    private var gravoures: [HCAnnotation] = []
    private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocaleHelper.shared.language == .greek ? "Xάρτης Kitchener" : "Kitchener Map"
        setupTileRendererKitchener()
        setWMSLayer()
        setUpLocationManager()
        setupMapView()
        setUpNavigationBar()
        children.forEach{($0 as? MenuViewController)?.delegate = self}
        debugPrint(LayersHelper.shared.data.debugDescription)
        RepresentationHelper.shared.load()
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
    
    private func setUpLocationManager() {
//        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(longPress)
        centerMapOnLocation(location: cyprusCenter)
        let tap = UITapGestureRecognizer(target: self, action: #selector(loadFeature))
        mapView.addGestureRecognizer(tap)
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        addUserAnnotationOnMap(at: newCoordinates)
    }
    
    @objc func loadFeature(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        Interactor.shared.loadFeatureOnLocation(newCoordinates) { [weak self] (feature) in
            guard let feature = feature else { return }
            self?.showInfoWindow(feature: feature)
        }
    }

    private func setWMSLayer() {
        if mkOverlay != nil {
            mapView.removeOverlay(mkOverlay!)
        }
        
        let urlkin = WMSHelper.shared.mapLayersUrl.replacingOccurrences(of: "%s", with: LayersHelper.shared.formattedLayers)
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
        if longPressMarker != nil {
            mapView.removeAnnotation(longPressMarker!)
            longPressMarker = nil
        }
        children.forEach {
            ($0 as? MenuViewController)?.clearMapLayers()
        }
        if mkOverlay != nil {
            mapView.removeOverlay(mkOverlay!)
            mkOverlay = nil
        }
        if lemessosLayer != nil {
            mapView.removeOverlay(lemessosLayer!)
        }
        if nicosiaLayer != nil {
            mapView.removeOverlay(nicosiaLayer!)
        }
        if modernLayerA != nil {
            mapView.removeOverlay(modernLayerA!)
        }
        if modernLayerB != nil {
            mapView.removeOverlay(modernLayerB!)
        }
        if kitchenerLayer == nil {
            setupTileRendererKitchener()
        }
        mapView.removeAnnotations(gravoures)
        gravoures = []
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
        if longPressMarker != nil {
            mapView.removeAnnotation(longPressMarker!)
            longPressMarker = nil
        }
        let longPressMarker = MKPointAnnotation()
        let isGreek = LocaleHelper.shared.language == .greek
        longPressMarker.title = isGreek ? "Επιλεγμένο σημείο" : "Selected point"
        longPressMarker.coordinate = coordinate
        longPressMarker.subtitle = isGreek ? "Θέλετε να αφήσετε σχόλιο;" : "would you like to add a comment?"
        mapView.addAnnotation(longPressMarker)
        self.longPressMarker = longPressMarker
        mapView.selectAnnotation(longPressMarker, animated: true)
    }
}

// MARK: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.title == longPressMarker?.title {
            let identifier = "longpress"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation,
                                                     reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let btn = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        } else if gravoures.contains(where: { (gravoura) -> Bool in
            gravoura.coordinate.latitude == annotation.coordinate.latitude && gravoura.coordinate.longitude == annotation.coordinate.longitude
        }) {
            return HCPinAnnotationView.hcCreateDefaultPin(forMap: mapView, forAnnotation: annotation, withPinColor: .purple, withReuseIdentifier: "gravoura", showCallout: true, withClass: GravouraView.self, mapInfoViewName: "GravouraView", infoViewSize: CGSize(width: 320, height: 160)) { (infoView) in
                debugPrint(infoView)
                guard infoView as? GravouraView != nil else { return }
                (infoView as? GravouraView)?.name = annotation.title ?? ""
                (infoView as? GravouraView)?.image = annotation.subtitle ?? ""
                (infoView as? GravouraView)?.refresh()
                (infoView as? GravouraView)?.onTap = { [weak self] name, image in
                    self?.onGravouraDetailsTapped(name: name, image: image)
                }
            }
        } else {
            return nil
        }
    }
    
    private func onGravouraDetailsTapped(name: String?, image: String?) {
        let link = RepresentationHelper.shared.data?.features.filter {
            $0.properties.clearName == name && $0.properties.thumbnail == image
        }.first?.properties.link
        guard let linkString = link, let url = URL(string: "https://gaia.hua.gr/" +  linkString) else { return }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.reuseIdentifier == "longpress" {
            Route.feedback(coordinates: longPressMarker!.coordinate).push(from: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is WMSMKTileOverlay {
            let renderer = MKTileOverlayRenderer(overlay:overlay)
            renderer.alpha = (overlay as! WMSMKTileOverlay).alpha
            return renderer
        }
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = .yellow
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        if overlay is MKPolygon {
            let polygonRenderer = MKPolygonRenderer(overlay: overlay)
            polygonRenderer.strokeColor = .yellow
            polygonRenderer.lineWidth = 5
            return polygonRenderer
        }
        let renderer = mapView.mapCacheRenderer(forOverlay: overlay)
        if overlay is CachedTileOverlay {
            renderer.alpha = overlayAlpha
        }
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let coordinate = CLLocationCoordinate2DMake(mapView.region.center.latitude,
                                                    mapView.region.center.longitude)
        var span = mapView.region.span
        if span.latitudeDelta < 0.002 { // MIN LEVEL
            span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        } else if span.latitudeDelta > 1.3 { // MAX LEVEL
            span = MKCoordinateSpan(latitudeDelta: 1.3, longitudeDelta: 1.3)
        }
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated:true)
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

// MARK: Menu Drawer

extension MapViewController: MenuDelegate {
    func didSelectRepresentations() {
        guard gravoures.isEmpty else {
            mapView.removeAnnotations(gravoures)
            gravoures = []
            return
        }
        guard let data = RepresentationHelper.shared.data else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.didSelectRepresentations()
            }
            return
        }
        data.features.forEach {
            let marker = HCAnnotation()
            marker.title = $0.properties.clearName
            marker.subtitle = $0.properties.thumbnail
            marker.coordinate = CLLocationCoordinate2D(latitude: $0.geometry.coordinates[1],
                                                       longitude: $0.geometry.coordinates[0])
            mapView.addAnnotation(marker)
            gravoures.append(marker)
        }
    }
    
    func didTapFilter() {
        closeDrawer()
        openSlider()
        slider.onChangeAction = { [weak self] newValue in
            self?.reloadRenderers(CGFloat(newValue))
        }
        slider.onIdleAction = {
            self.closeSlider()
        }
    }
    
    func reloadRenderers(_ alpha: CGFloat) {
        guard alpha != overlayAlpha else { return }
        guard isChangingAlpha == false else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [weak self] in
                self?.reloadRenderers(alpha)
            }
            return
        }
        isChangingAlpha = true
        overlayAlpha = alpha
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        [kitchenerLayer, lemessosLayer, nicosiaLayer, modernLayerA, modernLayerB].filter { $0 != nil }.forEach { layer in
            mapView.addOverlay(layer!)
        }
        isChangingAlpha = false
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
        setWMSLayer()
    }
    
    func didSelect(feature: Feature) {
        selectedFeature = feature
        if polyline != nil {
            mapView.removeOverlay(polyline!)
            polyline = nil
        }
        if polygon != nil {
            mapView.removeOverlay(polygon!)
            polygon = nil
        }
        var points: [CLLocationCoordinate2D] = []
        if let point = feature.geometry?.point {
            points.append(CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng))
        }
        if let geometryPoints = feature.geometry?.points {
            points.append(contentsOf: geometryPoints.map {
                CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng)
            })
        }

        if points.count > 1 {
            polyline = MKPolyline(coordinates: points)
            mapView.addOverlay(polyline!)
            
            let region = MKCoordinateRegion(polyline!.boundingMapRect)
            let regionThatFits = mapView.regionThatFits(region)
            mapView.setRegion(regionThatFits, animated: true)
        } else if points.count == 1 {
            let point = points[0]
            var polygonPoints: [CLLocationCoordinate2D] = []
            polygonPoints.append(CLLocationCoordinate2D(latitude: point.latitude - 0.0005, longitude: point.longitude - 0.0004))
            polygonPoints.append(CLLocationCoordinate2D(latitude: point.latitude + 0.0005, longitude: point.longitude - 0.0004))
            polygonPoints.append(CLLocationCoordinate2D(latitude: point.latitude + 0.0005, longitude: point.longitude + 0.0004))
            polygonPoints.append(CLLocationCoordinate2D(latitude: point.latitude - 0.0005, longitude: point.longitude + 0.0004))
            polygon = MKPolygon(coordinates: &polygonPoints, count: polygonPoints.count)
            mapView.addOverlay(polygon!)
            
            let region = MKCoordinateRegion(polygon!.boundingMapRect)
            var regionThatFits = mapView.regionThatFits(region)
            regionThatFits.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            mapView.setRegion(regionThatFits, animated: true)
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
