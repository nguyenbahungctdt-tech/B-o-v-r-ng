import Foundation
import CoreLocation

struct GpsPoint: Identifiable, Codable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    var altitude: Double = 0.0
    var speed: Double = 0.0
    var accuracy: Double = 0.0
    var timestampUtc: Int64 = Int64(Date().timeIntervalSince1970 * 1000)

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum GisShapeType: String, Codable {
    case POINT, LINE, POLYGON
}

struct GisFeature: Identifiable, Codable {
    let id: String
    let layerId: Int64
    let shapeType: GisShapeType
    let points: [GpsPoint]
    var attributes: [String: String] = [:]

    var minLat: Double = 0.0
    var maxLat: Double = 0.0
    var minLon: Double = 0.0
    var maxLon: Double = 0.0

    var centroidLat: Double = 0.0
    var centroidLon: Double = 0.0
}
