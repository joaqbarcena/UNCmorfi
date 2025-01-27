//
//  MapViewController.swift
//  UNCmorfi
//
//  Created by George Alegre on 6/29/17.
//
//  LICENSE is at the root of this project's repository.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    // MARK: Properties
    private let mapView: MKMapView = {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.showsPointsOfInterest = true
        return mapView
    }()

    private let locationManager = CLLocationManager()

    private let viewID = "viewID"

    // MARK: MVC lifecycle
    override func loadView() {
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "map.nav.label".localized()
        if #available(iOS 11.0, *) {
            navigationController!.navigationBar.prefersLargeTitles = true
        }

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        mapView.delegate = self
        
        let uni = Comedor(
            title: "university.annotation.title".localized(),
            subtitle: nil,
            coordinate: CLLocationCoordinate2D(latitude: -31.439734, longitude: -64.189293))

        let downtown = Comedor(
            title: "downtown.annotation.title".localized(),
            subtitle: nil,
            coordinate: CLLocationCoordinate2D(latitude: -31.416686, longitude: -64.189000))

        let annotations = [uni, downtown]
        
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)

        // Annotations appear hidden under navigation and tab bar controllers.
        // The view covers the whole screen so annotations DO appear but under these elements.
        let region: MKCoordinateRegion
        if #available(iOS 11.0, *) {
            // Increase viewing region by 50% (titles are bigger).
            // Shift map downwards just a bit.
            let zoomMultiplier = 1.5
            let center = mapView.region.center
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2DMake(center.latitude + 0.002, center.longitude),
                span: MKCoordinateSpan(
                    latitudeDelta: mapView.region.span.latitudeDelta * zoomMultiplier,
                    longitudeDelta: mapView.region.span.longitudeDelta * zoomMultiplier)
            )
        } else {
            // Increase viewing region by 30%.
            let zoomMultiplier = 1.3
            region = MKCoordinateRegion(
                center: mapView.region.center,
                span: MKCoordinateSpan(
                    latitudeDelta: mapView.region.span.latitudeDelta * zoomMultiplier,
                    longitudeDelta: mapView.region.span.longitudeDelta * zoomMultiplier)
            )
        }
        mapView.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Comedor else { return nil }
        
        let annotationView: MKPinAnnotationView
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: viewID) as? MKPinAnnotationView {
            annotationView = view
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: viewID)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if #available(iOS 10.0, *) {
            MKMapItem(placemark: MKPlacemark(coordinate: view.annotation!.coordinate)).openInMaps(launchOptions: nil)
        } else {
            // Fallback on earlier versions
        }
    }
}
