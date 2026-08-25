import Foundation
import CoreLocation

class MapInfoParser {
    static let shared = MapInfoParser()

    private let BLOCK_SIZE = 512
    private let MAX_PTS = 200000

    struct MapInfoParams {
        let resX: Double
        let resY: Double
        let centerX: Double
        let centerY: Double
        let cm: Double
        let zd: Int
    }

    class MapInfoBuffer {
        private let data: Data
        private var isBigEndian = true

        init(data: Data) {
            self.data = data
        }

        func setOrder(bigEndian: Bool) {
            self.isBigEndian = bigEndian
        }

        func lp(_ logical: Int) -> Int {
            if logical < 512 { return logical }
            let dataOffset = logical - 512
            let blockIdx = (dataOffset / 508) + 1
            let offsetInBlock = dataOffset % 508
            return (blockIdx * 512) + 4 + offsetInBlock
        }

        func getByte(_ logical: Int) -> UInt8 {
            let p = lp(logical)
            return p < data.count ? data[p] : 0
        }

        func getInt16(_ logical: Int) -> Int16 {
            var val: Int16 = 0
            for i in 0..<2 {
                let byte = getByte(logical + i)
                if isBigEndian {
                    val = (val << 8) | Int16(byte)
                } else {
                    val |= Int16(byte) << (i * 8)
                }
            }
            return val
        }

        func getInt32(_ logical: Int) -> Int32 {
            var val: Int32 = 0
            for i in 0..<4 {
                let byte = getByte(logical + i)
                if isBigEndian {
                    val = (val << 8) | Int32(byte)
                } else {
                    val |= Int32(byte) << (i * 8)
                }
            }
            return val
        }

        func getDouble(_ logical: Int) -> Double {
            var bytes = [UInt8]()
            for i in 0..<8 {
                bytes.append(getByte(logical + i))
            }
            if !isBigEndian { bytes.reverse() }
            return bytes.withUnsafeBytes { $0.load(as: Double.self) }
        }

        var count: Int { data.count }
    }

    func parseMapInfo(url: URL, cm: Double, zd: Int) async -> [GisFeature] {
        let folder = url.deletingLastPathComponent()
        let base = url.deletingPathExtension().lastPathComponent

        guard let mapURL = findFile(folder: folder, base: base, ext: "map"),
              let idURL = findFile(folder: folder, base: base, ext: "id"),
              let datURL = findFile(folder: folder, base: base, ext: "dat") else {
            return []
        }

        do {
            let mapData = try Data(contentsOf: mapURL)
            let idData = try Data(contentsOf: idURL)
            let datData = try Data(contentsOf: datURL)

            let reader = MapInfoBuffer(data: mapData)

            // MapInfo uses Big Endian for geometry
            reader.setOrder(bigEndian: true)

            // Bounds and Resolution logic (simplified for initial implementation)
            let xMin = reader.getDouble(150)
            let yMin = reader.getDouble(158)
            let xMax = reader.getDouble(166)
            let yMax = reader.getDouble(174)

            let resX = (xMax > xMin) ? (xMax - xMin) / 2000000000.0 : 1.0
            let resY = (yMax > yMin) ? (yMax - yMin) / 2000000000.0 : 1.0
            let centerX = (xMax + xMin) / 2.0
            let centerY = (yMax + yMin) / 2.0

            let params = MapInfoParams(resX: resX, resY: resY, centerX: centerX, centerY: centerY, cm: cm, zd: zd)

            // Read ID file to get offsets
            let offsets = readIdFile(data: idData)
            var features: [GisFeature] = []

            for (idx, physOff) in offsets.enumerated() {
                if physOff <= 0 || physOff >= mapData.count { continue }
                let logOff = pl(physOff)
                let objFeatures = readObject(reader: reader, logOff: logOff, index: idx, params: params)
                features.append(contentsOf: objFeatures)
            }

            return features
        } catch {
            print("MapInfo parse error: \(error)")
            return []
        }
    }

    private func pl(_ physical: Int) -> Int {
        if physical < 512 { return physical }
        let blockIdx = physical / 512
        let offsetInBlock = physical % 512
        let dataSoFar = (blockIdx - 1) * 508
        return 512 + dataSoFar + (offsetInBlock < 4 ? 0 : offsetInBlock - 4)
    }

    private func readIdFile(data: Data) -> [Int] {
        var offsets: [Int] = []
        let count = data.count / 4
        for i in 0..<count {
            let val = Int32(bigEndian: data.subdata(in: (i*4)..<(i*4+4)).withUnsafeBytes { $0.load(as: Int32.self) })
            if val > 0 { offsets.append(Int(val)) }
        }
        return offsets
    }

    private func readObject(reader: MapInfoBuffer, logOff: Int, index: Int, params: MapInfoParams) -> [GisFeature] {
        let typeByte = reader.getByte(logOff)
        let type = Int(typeByte & 0x7F)
        var features: [GisFeature] = []

        switch type {
        case 1, 2: // Point
            let pts = [toGps(ix: Int(reader.getInt32(logOff + 4)), iy: Int(reader.getInt32(logOff + 8)), p: params)]
            features.append(wrap(idx: index, ring: 0, type: .POINT, pts: pts))
        case 3: // Line
            let pts = [
                toGps(ix: Int(reader.getInt32(logOff + 4)), iy: Int(reader.getInt32(logOff + 8)), p: params),
                toGps(ix: Int(reader.getInt32(logOff + 12)), iy: Int(reader.getInt32(logOff + 16)), p: params)
            ]
            features.append(wrap(idx: index, ring: 0, type: .LINE, pts: pts))
        case 4, 6: // Pline
            let n = Int(reader.getInt32(logOff + 20))
            if n > 0 && n <= MAX_PTS {
                var pts: [GpsPoint] = []
                for i in 0..<n {
                    pts.append(toGps(ix: Int(reader.getInt32(logOff + 24 + i * 8)), iy: Int(reader.getInt32(logOff + 28 + i * 8)), p: params))
                }
                features.append(wrap(idx: index, ring: 0, type: .LINE, pts: pts))
            }
        case 8, 9, 13: // Region
            let nRings = Int(reader.getInt32(logOff + 20))
            let nTotal = Int(reader.getInt32(logOff + 24))
            if nRings > 0 && nTotal > 0 {
                var ringSizes: [Int] = []
                for i in 0..<nRings {
                    ringSizes.append(Int(reader.getInt32(logOff + 28 + i * 4)))
                }
                let fChain = Int(reader.getInt32(logOff + 28 + nRings * 4))
                if fChain > 0 {
                    var allPts: [GpsPoint] = []
                    readPointChain(reader: reader, logOff: pl(fChain), total: nTotal, pts: &allPts, p: params)

                    var start = 0
                    for (i, count) in ringSizes.enumerated() {
                        if start + count <= allPts.count {
                            let ring = Array(allPts[start..<(start + count)])
                            features.append(wrap(idx: index, ring: i, type: .POLYGON, pts: ring))
                        }
                        start += count
                    }
                }
            }
        default: break
        }
        return features
    }

    private func readPointChain(reader: MapInfoBuffer, logOff: Int, total: Int, pts: inout [GpsPoint], p: MapInfoParams) {
        var cLog = logOff
        var read = 0
        while read < total && cLog > 0 && cLog < reader.count {
            let blockSize = Int(reader.getInt32(cLog))
            let nextPhys = Int(reader.getInt32(cLog + 4))
            if blockSize <= 8 { break }

            let n = min(total - read, (blockSize - 8) / 8)
            for i in 0..<n {
                let ix = Int(reader.getInt32(cLog + 8 + i * 8))
                let iy = Int(reader.getInt32(cLog + 12 + i * 8))
                pts.append(toGps(ix: ix, iy: iy, p: p))
            }
            read += n
            if nextPhys > 0 && read < total {
                cLog = pl(nextPhys)
            } else {
                break
            }
        }
    }

    private func toGps(ix: Int, iy: Int, p: MapInfoParams) -> GpsPoint {
        let x = p.centerX + (Double(ix) * p.resX)
        let y = p.centerY + (Double(iy) * p.resY)
        let res = CoordinateConverter.shared.vn2000ToWgs84(x: x, y: y, cm: p.cm, zd: p.zd)
        return GpsPoint(latitude: res.lat, longitude: res.lon)
    }

    private func wrap(idx: Int, ring: Int, type: GisShapeType, pts: [GpsPoint]) -> GisFeature {
        let minLat = pts.map { $0.latitude }.min() ?? 0
        let maxLat = pts.map { $0.latitude }.max() ?? 0
        let minLon = pts.map { $0.longitude }.min() ?? 0
        let maxLon = pts.map { $0.longitude }.max() ?? 0
        return GisFeature(id: "mi_\(idx)_\(ring)", layerId: 0, shapeType: type, points: pts, attributes: [:], minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon, centroidLat: (minLat+maxLat)/2, centroidLon: (minLon+maxLon)/2)
    }

    private func findFile(folder: URL, base: String, ext: String) -> URL? {
        let variants = ["\(base).\(ext)", "\(base).\(ext.uppercased())", "\(base.lowercased()).\(ext)", "\(base.uppercased()).\(ext)"]
        for v in variants {
            let url = folder.appendingPathComponent(v)
            if FileManager.default.fileExists(atPath: url.path) { return url }
        }
        return nil
    }
}
