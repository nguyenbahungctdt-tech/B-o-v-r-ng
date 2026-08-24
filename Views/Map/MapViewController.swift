import UIKit
import MapLibre
import SwiftUI

class MapViewController: UIViewController, MLNMapViewDelegate {
    var mapView: MLNMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Default style (OSM Bright or similar)
        let styleURL = URL(string: "https://demotiles.maplibre.org/style.json")!
        mapView = MLNMapView(frame: view.bounds, styleURL: styleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 11.9404, longitude: 108.4378), zoomLevel: 13, animated: false)
        mapView.delegate = self

        view.addSubview(mapView)
    }

    func addGisLayer(features: [GisFeature], layerId: String) {
        guard let style = mapView.style else { return }

        var points: [MLNPointFeature] = []
        for feature in features {
            if feature.shapeType == .POINT, let pt = feature.points.first {
                let mPt = MLNPointFeature()
                mPt.coordinate = CLLocationCoordinate2D(latitude: pt.latitude, longitude: pt.longitude)
                mPt.attributes = feature.attributes
                points.append(mPt)
            }
        }

        let source = MLNShapeSource(identifier: "source_\(layerId)", features: points, options: nil)
        style.addSource(source)

        let layer = MLNCircleStyleLayer(identifier: "layer_\(layerId)", source: source)
        layer.circleColor = NSExpression(forConstantValue: UIColor.green)
        layer.circleRadius = NSExpression(forConstantValue: 5)
        style.addLayer(layer)
    }
}

// SwiftUI Wrapper
struct MapLibreView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }

    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        // Handle updates from SwiftUI
    }
}
