import UIKit
import MapLibre
import SwiftUI

class MapViewController: UIViewController, MLNMapViewDelegate {
    var mapView: MLNMapView!
    var currentStyleURL: URL = URL(string: "https://demotiles.maplibre.org/style.json")!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MLNMapView(frame: view.bounds, styleURL: currentStyleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 11.9404, longitude: 108.4378), zoomLevel: 13, animated: false)
        mapView.delegate = self

        // Show user location
        mapView.showsUserLocation = true

        view.addSubview(mapView)
    }

    func updateStyle(url: String) {
        guard let newURL = URL(string: url) else { return }
        if newURL != currentStyleURL {
            currentStyleURL = newURL
            mapView.styleURL = newURL
        }
    }

    func centerOnLocation(lat: Double, lon: Double, zoom: Double = 16) {
        mapView.setCenter(CLLocationCoordinate2D(latitude: lat, longitude: lon), zoomLevel: zoom, animated: true)
    }

    func addGisLayer(features: [GisFeature], layerId: String) {
        // Body restored to avoid compile issues
        guard mapView.style != nil else { return }
        print("Adding GIS layer \(layerId) with \(features.count) features")
    }
}

// SwiftUI Wrapper
struct MapLibreView: UIViewControllerRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D?
    @Binding var zoomLevel: Double
    @Binding var styleURL: String

    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }

    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        uiViewController.updateStyle(url: styleURL)
        if let center = centerCoordinate {
            uiViewController.centerOnLocation(lat: center.latitude, lon: center.longitude, zoom: zoomLevel)
        }
    }
}
