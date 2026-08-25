import Foundation

struct GpxExporter {
    static let shared = GpxExporter()

    private let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    func exportTrackToGpx(title: String, points: [GpsPoint], startTime: Date) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Ứng dụng Bảo vệ rừng - Đại Thành"
          xmlns="http://www.topografix.com/GPX/1/1"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <metadata>
            <name>\(escapeXml(title))</name>
            <time>\(iso8601Formatter.string(from: startTime))</time>
          </metadata>
          <trk>
            <name>\(escapeXml(title))</name>
            <trkseg>
        """

        for pt in points {
            let timeStr = iso8601Formatter.string(from: Date(timeIntervalSince1970: TimeInterval(pt.timestampUtc / 1000)))
            xml += """
                  <trkpt lat="\(pt.latitude)" lon="\(pt.longitude)">
                    <ele>\(pt.altitude)</ele>
                    <time>\(timeStr)</time>
                  </trkpt>
            """
        }

        xml += """
            </trkseg>
          </trk>
        </gpx>
        """

        return xml
    }

    func exportWaypointsToGpx(waypoints: [(title: String, lat: Double, lon: Double, desc: String, time: Date)]) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Ứng dụng Bảo vệ rừng - Đại Thành"
          xmlns="http://www.topografix.com/GPX/1/1"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <metadata>
            <name>Danh sách điểm khảo sát</name>
            <time>\(iso8601Formatter.string(from: Date()))</time>
          </metadata>
        """

        for wp in waypoints {
            xml += """
              <wpt lat="\(wp.lat)" lon="\(wp.lon)">
                <time>\(iso8601Formatter.string(from: wp.time))</time>
                <name>\(escapeXml(wp.title))</name>
                <desc>\(escapeXml(wp.desc))</desc>
              </wpt>
            """
        }

        xml += "</gpx>"
        return xml
    }

    private func escapeXml(_ input: String) -> String {
        return input.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
