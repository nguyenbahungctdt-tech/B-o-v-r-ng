import Foundation
import CoreLocation

struct CoordinateSystem: Identifiable, Codable {
    let id: String
    let name: String
    let projection: String
    var centralMeridian: Double = 107.75
    var zoneDegrees: Int = 3
}

struct DatumShift: Codable {
    let dx: Double
    let dy: Double
    let dz: Double
    var rx: Double = 0.0
    var ry: Double = 0.0
    var rz: Double = 0.0
    var ds: Double = 0.0
    var is7Param: Boolean = false
}

class CoordinateConverter {
    static let shared = CoordinateConverter()

    private let a_wgs84: Double = 6378137.0
    private let f_wgs84: Double = 1.0 / 298.257223563

    private let defaultShift = DatumShift(
        dx: -191.90441429,
        dy: -39.30318279,
        dz: -111.45032835,
        rx: -0.00928836 * (.pi / (180 * 3600)),
        ry: 0.01975479 * (.pi / (180 * 3600)),
        rz: -0.00427372 * (.pi / (180 * 3600)),
        ds: 0.252906278 * 1e-6,
        is7Param: true
    )

    func wgs84ToVn2000(lat: Double, lon: Double, cm: Double, zd: Int) -> (x: Double, y: Double) {
        let local = applyDatumShift(lat: lat, lon: lon, inverse: true, shift: defaultShift)
        return transverseMercator(lat: local.lat, lon: local.lon, cm: cm, k0: zd == 6 ? 0.9996 : 0.9999)
    }

    func vn2000ToWgs84(x: Double, y: Double, cm: Double, zd: Int) -> (lat: Double, lon: Double) {
        let local = inverseTransverseMercator(x: x, y: y, cm: cm, k0: zd == 6 ? 0.9996 : 0.9999)
        let wgs = applyDatumShift(lat: local.lat, lon: local.lon, inverse: false, shift: defaultShift)
        return wgs
    }

    private func applyDatumShift(lat: Double, lon: Double, inverse: Bool, shift: DatumShift) -> (lat: Double, lon: Double) {
        let sign: Double = inverse ? -1.0 : 1.0
        let phi = lat * .pi / 180.0
        let lam = lon * .pi / 180.0
        let b = a_wgs84 * (1.0 - f_wgs84)
        let e2 = (a_wgs84 * a_wgs84 - b * b) / (a_wgs84 * a_wgs84)

        let n = a_wgs84 / sqrt(1.0 - e2 * sin(phi) * sin(phi))
        let x = n * cos(phi) * cos(lam)
        let y = n * cos(phi) * sin(lam)
        let z = n * (1.0 - e2) * sin(phi)

        let dx = sign * shift.dx
        let dy = sign * shift.dy
        let dz = sign * shift.dz
        let s = 1.0 + sign * shift.ds

        var nx: Double, ny: Double, nz: Double

        if shift.is7Param {
            let rx = sign * shift.rx
            let ry = sign * shift.ry
            let rz = sign * shift.rz
            nx = dx + s * (x - rz * y + ry * z)
            ny = dy + s * (rz * x + y - rx * z)
            nz = dz + s * (-ry * x + rx * y + z)
        } else {
            nx = x + dx
            ny = y + dy
            nz = z + dz
        }

        let nlam = atan2(ny, nx)
        let p = sqrt(nx * nx + ny * ny)
        var nphi = atan2(nz, p * (1.0 - e2))

        for _ in 0..<10 {
            let nn = a_wgs84 / sqrt(1.0 - e2 * sin(nphi) * sin(nphi))
            nphi = atan2(nz + e2 * nn * sin(nphi), p)
        }

        return (nphi * 180.0 / .pi, nlam * 180.0 / .pi)
    }

    private func transverseMercator(lat: Double, lon: Double, cm: Double, k0: Double) -> (x: Double, y: Double) {
        let e2 = 2 * f_wgs84 - f_wgs84 * f_wgs84
        let ep2 = e2 / (1 - e2)
        let phi = lat * .pi / 180.0
        let lam = lon * .pi / 180.0
        let lam0 = cm * .pi / 180.0

        let n = a_wgs84 / sqrt(1.0 - e2 * sin(phi) * sin(phi))
        let t = tan(phi) * tan(phi)
        let c = ep2 * cos(phi) * cos(phi)
        let aa = (lam - lam0) * cos(phi)

        let m = a_wgs84 * ((1.0 - e2 / 4.0 - 3.0 * e2 * e2 / 64.0 - 5.0 * e2 * e2 * e2 / 256.0) * phi - (3.0 * e2 / 8.0 + 3.0 * e2 * e2 / 32.0 + 45.0 * e2 * e2 * e2 / 1024.0) * sin(2.0 * phi) + (15.0 * e2 * e2 / 256.0 + 45.0 * e2 * e2 * e2 / 1024.0) * sin(4.0 * phi) - (35.0 * e2 * e2 / 3072.0) * sin(6.0 * phi))

        let x = 500000.0 + k0 * n * (aa + (1.0 - t + c) * pow(aa, 3) / 6.0 + (5.0 - 18.0 * t + t * t + 72.0 * c - 58.0 * ep2) * pow(aa, 5) / 120.0)
        let y = k0 * (m + n * tan(phi) * (pow(aa, 2) / 2.0 + (5.0 - t + 9.0 * c + 4.0 * c * c) * pow(aa, 4) / 24.0 + (61.0 - 58.0 * t + t * t + 600.0 * c - 330.0 * ep2) * pow(aa, 6) / 720.0))

        return (x, y)
    }

    private func inverseTransverseMercator(x: Double, y: Double, cm: Double, k0: Double) -> (lat: Double, lon: Double) {
        let e2 = 2 * f_wgs84 - f_wgs84 * f_wgs84
        let ep2 = e2 / (1 - e2)
        let lam0 = cm * .pi / 180.0
        let xx = x - 500000.0
        let m = y / k0

        let mu = m / (a_wgs84 * (1.0 - e2 / 4.0 - 3.0 * e2 * e2 / 64.0 - 5.0 * e2 * e2 * e2 / 256.0))
        let e1 = (1.0 - sqrt(1.0 - e2)) / (1.0 + sqrt(1.0 - e2))

        let p1 = mu + (3.0 * e1 / 2.0 - 27.0 * pow(e1, 3) / 32.0) * sin(2.0 * mu) + (21.0 * pow(e1, 2) / 16.0 - 55.0 * pow(e1, 4) / 32.0) * sin(4.0 * mu) + (151.0 * pow(e1, 3) / 96.0) * sin(6.0 * mu)

        let n1 = a_wgs84 / sqrt(1.0 - e2 * sin(p1) * sin(p1))
        let t1 = tan(p1) * tan(p1)
        let c1 = ep2 * cos(p1) * cos(p1)
        let r1 = a_wgs84 * (1.0 - e2) / pow(1.0 - e2 * sin(p1) * sin(p1), 1.5)
        let d = xx / (n1 * k0)

        let lat = p1 - (n1 * tan(p1) / r1) * (pow(d, 2) / 2.0 - (5.0 + 3.0 * t1 + 10.0 * c1 - 4.0 * c1 * c1 - 9.0 * ep2) * pow(d, 4) / 24.0 + (61.0 + 90.0 * t1 + 298.0 * c1 + 45.0 * pow(t1, 2) - 252.0 * ep2 - 3.0 * pow(c1, 2)) * pow(d, 6) / 720.0)
        let lon = lam0 + (d - (1.0 + 2.0 * t1 + c1) * pow(d, 3) / 6.0 + (5.0 - 2.0 * c1 + 28.0 * t1 - 3.0 * pow(c1, 2) + 8.0 * ep2 + 24.0 * pow(t1, 2)) * pow(d, 5) / 120.0) / cos(p1)

        return (lat * 180.0 / .pi, lon * 180.0 / .pi)
    }
}
