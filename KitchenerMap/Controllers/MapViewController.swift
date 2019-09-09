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
    //    @IBOutlet weak var mapView: MKMapView!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTileRenderer()
        setupMapView()
        setUpNavigationBar()
        children.forEach{($0 as? MenuViewController)?.delegate = self}
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

//extension MapViewController: MKMapViewDelegate {
//
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        return tileRenderer
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? UserAnnotation, userAnnotation == annotation else {
//            return nil
//        }
//        let identifier = "userMarker"
//        var view: MKMarkerAnnotationView
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: 0, y: 0)
//            view.rightCalloutAccessoryView = UIButton(type: .contactAdd)
//        }
//        return view
//    }
//
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let vc = UIStoryboard.main!.instantiateViewController(withClass: TakeCommentViewController.self)!
//        vc.location = view.annotation!.coordinate
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}

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

extension MKMapView {
    open var currentZoomLevel: Int {
        let maxZoom: Double = 24
        let zoomScale = visibleMapRect.size.width / Double(frame.size.width)
        let zoomExponent = log2(zoomScale)
        return Int(maxZoom - ceil(zoomExponent))
    }
    
    open func setCenterCoordinate(_ centerCoordinate: CLLocationCoordinate2D,
                                  withZoomLevel zoomLevel: Int,
                                  animated: Bool) {
        let minZoomLevel = min(zoomLevel, 28)
        
        let span = coordinateSpan(centerCoordinate, andZoomLevel: minZoomLevel)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        
        setRegion(region, animated: animated)
    }
}

let MERCATOR_OFFSET: Double = 268435456 // swiftlint:disable:this identifier_name
let MERCATOR_RADIUS: Double = 85445659.44705395 // swiftlint:disable:this identifier_name
struct PixelSpace {
    public var x: Double // swiftlint:disable:this identifier_name
    public var y: Double // swiftlint:disable:this identifier_name
}

fileprivate extension MKMapView {
    func coordinateSpan(_ centerCoordinate: CLLocationCoordinate2D, andZoomLevel zoomLevel: Int) -> MKCoordinateSpan {
        let space = pixelSpace(fromLongitue: centerCoordinate.longitude, withLatitude: centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent = 20 - zoomLevel
        let zoomScale = pow(2.0, Double(zoomExponent))
        
        // scale the map’s size in pixel space
        let mapSizeInPixels = self.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // figure out the position of the top-left pixel
        let topLeftPixelX = space.x - (scaledMapWidth / 2)
        let topLeftPixelY = space.y - (scaledMapHeight / 2)
        
        var minSpace = space
        minSpace.x = topLeftPixelX
        minSpace.y = topLeftPixelY
        
        var maxSpace = space
        maxSpace.x += scaledMapWidth
        maxSpace.y += scaledMapHeight
        
        // find delta between left and right longitudes
        let minLongitude = coordinate(fromPixelSpace: minSpace).longitude
        let maxLongitude = coordinate(fromPixelSpace: maxSpace).longitude
        let longitudeDelta = maxLongitude - minLongitude
        
        // find delta between top and bottom latitudes
        let minLatitude = coordinate(fromPixelSpace: minSpace).latitude
        let maxLatitude = coordinate(fromPixelSpace: maxSpace).latitude
        let latitudeDelta = -1 * (maxLatitude - minLatitude)
        
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    func pixelSpace(fromLongitue longitude: Double, withLatitude latitude: Double) -> PixelSpace {
        let x = round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * Double.pi / 180.0)
        let y = round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * Double.pi / 180.0)) / (1 - sin(latitude * Double.pi / 180.0))) / 2.0) // swiftlint:disable:this line_length
        return PixelSpace(x: x, y: y)
    }
    
    func coordinate(fromPixelSpace pixelSpace: PixelSpace) -> CLLocationCoordinate2D {
        let longitude = ((round(pixelSpace.x) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / Double.pi
        let latitude = (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelSpace.y) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / Double.pi // swiftlint:disable:this line_length
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
