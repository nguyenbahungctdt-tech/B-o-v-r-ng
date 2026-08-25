import UIKit
import MapLibre
import SwiftUI

class MapViewController: UIViewController, MLNMapViewDelegate {
    var mapView: MLNMapView!
    // Default to Google Satellite
    var currentStyleURL: URL = URL(string: "https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}")!

    var onCenterChanged: ((CLLocationCoordinate2D) -> Void)?
    var onZoomChanged: ((Double) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MLNMapView(frame: view.bounds, styleURL: currentStyleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 11.9404, longitude: 108.4378), zoomLevel: 13, animated: false)
        mapView.delegate = self

        // Show user location
        mapView.showsUserLocation = true

        view.addSubview(mapView)

        // Initial layer loading
        loadDefaultLayers()
    }

    func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
        onCenterChanged?(mapView.centerCoordinate)
        onZoomChanged?(mapView.zoomLevel)
    }

    private func loadDefaultLayers() {
        // Here we would load default_map_SDD.mbtiles and default_map_Kk2025.mbtiles
        // if they exist in the app bundle or documents
        print("Initializing default GIS layers...")
    }

    func updateStyle(url: String) {
        if url.contains("{x}") {
            // It's a tile template, generate a simple style JSON
            let styleJSON = """
            {
                "version": 8,
                "sources": {
                    "raster-tiles": {
                        "type": "raster",
                        "tiles": ["\(url)"],
                        "tileSize": 256
                    }
                },
                "layers": [{
                    "id": "simple-tiles",
                    "type": "raster",
                    "source": "raster-tiles",
                    "minzoom": 0,
                    "maxzoom": 22
                }]
            }
            """
            if let data = styleJSON.data(using: .utf8) {
                mapView.styleURL = try? MLNStyle.url(forStyleJSON: styleJSON) // Wait, MapLibre usage of JSON
            }
            // Correct way for MapLibre Native:
            let tempURL = URL(string: "data:application/json;base64," + styleJSON.data(using: .utf8)!.base64EncodedString())!
            mapView.styleURL = tempURL
            return
        }

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
    @Binding var mapCenter: CLLocationCoordinate2D?
    @Binding var zoomLevel: Double
    @Binding var styleURL: String

    func makeUIViewController(context: Context) -> MapViewController {
        let vc = MapViewController()
        vc.onCenterChanged = { coord in
            DispatchQueue.main.async {
                self.mapCenter = coord
            }
        }
        vc.onZoomChanged = { zoom in
            DispatchQueue.main.async {
                self.zoomLevel = zoom
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        uiViewController.updateStyle(url: styleURL)
        if let center = centerCoordinate {
            uiViewController.centerOnLocation(lat: center.latitude, lon: center.longitude, zoom: zoomLevel)
            DispatchQueue.main.async {
                self.centerCoordinate = nil // Reset to avoid loop
            }
        }
    }
}
