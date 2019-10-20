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
    
    var tileRenderer: MKTileOverlayRenderer!
    private let cyprusCenter = CLLocationCoordinate2D(latitude: 34.997045, longitude: 33.190684)
    private let cyprusNEBound = CLLocationCoordinate2D(latitude: 35.831610, longitude: 34.718857)
    private let cyprusSWBound = CLLocationCoordinate2D(latitude: 34.510659, longitude: 32.266127)
    private var userAnnotation: UserAnnotation?
    private var layer: GMSURLTileLayer?
    private var layerWMS: GMSURLTileLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocaleHelper.shared.language == .greek ? "Xάρτης Kitchener" : "Kitchener Map"
        setupTileRenderer()
        getCardfromGeoserver()
        setupMapView()
        setUpNavigationBar()
        children.forEach{($0 as? MenuViewController)?.delegate = self}
        debugPrint(LayersHelper.shared.data.debugDescription)
    }
    
    private func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(toggleDrawer))
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.setMinZoom(3, maxZoom: 16)
        centerMapOnLocation(location: cyprusCenter)
//        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
//        mapView.addGestureRecognizer(uilgr)
    }
    
    private func getCardfromGeoserver() {
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
            return URL(string: urlkin)
        }
        
        self.layerWMS = GMSURLTileLayer(urlConstructor: urls)
        self.layerWMS?.opacity = 1
        self.layerWMS?.zIndex = 105
        self.layerWMS?.tileSize = 256
        self.layerWMS?.map = mapView
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition(target: location, zoom: 12)
        mapView.animate(to: camera)
    }

    private func setupTileRenderer() {
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
    
    @objc private func toggleDrawer() {
        menuBackground.isHidden = leftMenuTrailingConstraint.constant != 0
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            self.leftMenuTrailingConstraint.constant = self.leftMenuTrailingConstraint.constant == 0 ? self.lefMenuContainer.frame.width : 0
            self.view.layoutIfNeeded()
        })
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
    
    @objc private func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
//        if gestureRecognizer.state == .began {
//            let touchPoint = gestureRecognizer.location(in: mapView)
//            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
//            let annotation = UserAnnotation(title: "", coordinate: newCoordinates)
//            if userAnnotation != nil {
//                mapView.removeAnnotation(userAnnotation!)
//            }
//            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
//                guard let placemarks = placemarks else {
//                    self.addUserAnnotationOnMap(annotation)
//                    return
//                }
//                if placemarks.count > 0 {
//                    let pm = placemarks[0]
//                    // not all places have thoroughfare & subThoroughfare so validate those values
//                    annotation.title = pm.locality
//                    if annotation.title != nil, let sub = pm.subLocality {
//                        annotation.title = annotation.title?.appending(", \(sub)")
//                    }
//                    self.addUserAnnotationOnMap(annotation)
//                } else {
//                    self.addUserAnnotationOnMap(annotation)
//                }
//            })
//        }
    }
    
    private func addUserAnnotationOnMap(_ annotation: UserAnnotation) {
//        if annotation.title == nil {
//            annotation.title = "Θέλετε να αφήσετε ένα σχόλιο ;"
//        }else {
//            annotation.subtitle = "Θέλετε να αφήσετε ένα σχόλιο ;"
//        }
//        userAnnotation = annotation
//        mapView.addAnnotation(annotation)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            self.mapView.selectAnnotation(annotation, animated: true)
//        }
    }
}

extension MapViewController: GMSMapViewDelegate {

}

extension MapViewController: MenuDelegate {
    
    func didTapFilter() {
        closeDrawer()
        openSlider()
        slider.onChangeAction = { newValue in
            self.layer?.opacity = newValue
        }
        slider.onIdleAction = {
            self.closeSlider()
        }
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
