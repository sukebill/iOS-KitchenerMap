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
        mapView.showsUserLocation = true
        mapView.showsScale = true
        centerMapOnLocation(location: cyprusCenter, map: mapView)
        let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(uilgr)
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D, map: MKMapView) {
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        DispatchQueue.main.async {
            map.setRegion(region, animated: true)
        }
    }

    private func setupTileRenderer() {
//        let overlay = KMTileRendererLocal()
//        overlay.canReplaceMapContent = false
//        mapView.addOverlay(overlay, level: MKOverlayLevel.aboveLabels)
//        tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
//        overlay.minimumZ = 15
//        overlay.maximumZ = 17
        
        let template = "https://gaia.hua.gr/tms/kitchener2/test/{z}/{x}/{y}.png"
        let overlay = MKTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = false
        overlay.isGeometryFlipped = true
        mapView.addOverlay(overlay, level: .aboveLabels)
        tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
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
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = UserAnnotation(title: "", coordinate: newCoordinates)
            if userAnnotation != nil {
                mapView.removeAnnotation(userAnnotation!)
            }
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                guard let placemarks = placemarks else {
                    self.addUserAnnotationOnMap(annotation)
                    return
                }
                if placemarks.count > 0 {
                    let pm = placemarks[0]
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    annotation.title = pm.locality
                    if annotation.title != nil, let sub = pm.subLocality {
                        annotation.title = annotation.title?.appending(", \(sub)")
                    }
                    self.addUserAnnotationOnMap(annotation)
                } else {
                    self.addUserAnnotationOnMap(annotation)
                }
            })
        }
    }
    
    private func addUserAnnotationOnMap(_ annotation: UserAnnotation) {
        if annotation.title == nil {
            annotation.title = "Θέλετε να αφήσετε ένα σχόλιο ;"
        }else {
            annotation.subtitle = "Θέλετε να αφήσετε ένα σχόλιο ;"
        }
        userAnnotation = annotation
        mapView.addAnnotation(annotation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return tileRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? UserAnnotation, userAnnotation == annotation else {
            return nil
        }
        let identifier = "userMarker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 0)
            view.rightCalloutAccessoryView = UIButton(type: .contactAdd)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //TODO: openj screen for comment and photo
    }
}

extension MapViewController: MenuDelegate {
    
    func didTapFilter() {
        closeDrawer()
        openSlider()
        slider.onChangeAction = { newValue in
            self.tileRenderer.alpha = CGFloat(newValue)
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
