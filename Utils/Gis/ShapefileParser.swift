import Foundation
import CoreLocation

enum GisShapeType: String {
    case POINT, LINE, POLYGON
}

struct GisPoint: Codable {
    let latitude: Double
    let longitude: Double
    var altitude: Double = 0
    var timestamp: Int64 = 0
}

struct GisFeature: Identifiable {
    let id: String
    let layerId: Int64
    let shapeType: GisShapeType
    let points: [GisPoint]
    let attributes: [String: String]
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
}

class ShapefileParser {
    static let shared = ShapefileParser()

    func parseShapefile(url: URL, cm: Double, zd: Int) async -> [GisFeature] {
        var features: [GisFeature] = []
        let shpURL = url
        let dbfURL = url.deletingPathExtension().appendingPathExtension("dbf")

        guard FileManager.default.fileExists(atPath: shpURL.path),
              FileManager.default.fileExists(atPath: dbfURL.path) else {
            return []
        }

        do {
            let shpData = try Data(contentsOf: shpURL)
            let dbfData = try Data(contentsOf: dbfURL)

            // Basic SHP Header check
            let fileCode = Int32(bigEndian: shpData.subdata(in: 0..<4).withUnsafeBytes { $0.load(as: Int32.self) })
            guard fileCode == 9994 else { return [] }

            let shpLen = Int(Int32(bigEndian: shpData.subdata(in: 24..<28).withUnsafeBytes { $0.load(as: Int32.self) })) * 2

            var pos = 100
            var recordIdx = 0

            while pos + 8 <= shpLen && pos < shpData.count {
                let contentLen = Int(Int32(bigEndian: shpData.subdata(in: pos+4..<pos+8).withUnsafeBytes { $0.load(as: Int32.self) })) * 2
                let recordData = shpData.subdata(in: pos+8..<pos+8+contentLen)

                let shapeType = Int32(littleEndian: recordData.subdata(in: 0..<4).withUnsafeBytes { $0.load(as: Int32.self) })

                var points: [GisPoint] = []
                var gType = GisShapeType.POINT

                switch shapeType {
                case 1, 11, 21: // Point
                    gType = .POINT
                    let x = recordData.subdata(in: 4..<12).withUnsafeBytes { $0.load(as: Double.self) }
                    let y = recordData.subdata(in: 12..<20).withUnsafeBytes { $0.load(as: Double.self) }
                    points.append(toGpsPoint(x: x, y: y, cm: cm, zd: zd))

                case 3, 5, 13, 15, 23, 25: // Polyline/Polygon
                    gType = (shapeType == 3 || shapeType == 13 || shapeType == 23) ? .LINE : .POLYGON
                    let numParts = Int(Int32(littleEndian: recordData.subdata(in: 36..<40).withUnsafeBytes { $0.load(as: Int32.self) }))
                    let numPoints = Int(Int32(littleEndian: recordData.subdata(in: 40..<44).withUnsafeBytes { $0.load(as: Int32.self) }))

                    let dataStart = 44 + numParts * 4
                    for i in 0..<numPoints {
                        let pOffset = dataStart + i * 16
                        if pOffset + 16 <= recordData.count {
                            let x = recordData.subdata(in: pOffset..<pOffset+8).withUnsafeBytes { $0.load(as: Double.self) }
                            let y = recordData.subdata(in: pOffset+8..<pOffset+16).withUnsafeBytes { $0.load(as: Double.self) }
                            points.append(toGpsPoint(x: x, y: y, cm: cm, zd: zd))
                        }
                    }
                default: break
                }

                if !points.isEmpty {
                    // Simple DBF placeholder logic for now
                    let attrs: [String: String] = ["ID": "\(recordIdx)"]
                    let minLat = points.map { $0.latitude }.min() ?? 0
                    let maxLat = points.map { $0.latitude }.max() ?? 0
                    let minLon = points.map { $0.longitude }.min() ?? 0
                    let maxLon = points.map { $0.longitude }.max() ?? 0

                    features.append(GisFeature(id: "shp_\(recordIdx)", layerId: 0, shapeType: gType, points: points, attributes: attrs, minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon))
                }

                pos += 8 + contentLen
                recordIdx += 1
            }
        } catch {
            print("SHP Parse error: \(error)")
        }

        return features
    }

    private func toGpsPoint(x: Double, y: Double, cm: Double, zd: Int) -> GisPoint {
        if x > 1000 || y > 1000 {
            let result = CoordinateConverter.shared.vn2000ToWgs84(x: x, y: y, cm: cm, zd: zd)
            return GisPoint(latitude: result.lat, longitude: result.lon)
        }
        return GisPoint(latitude: y, longitude: x)
    }
}
