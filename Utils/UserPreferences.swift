import Foundation
import SwiftUI

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()

    // 1. Coordinate System Settings
    @Published var vn2000CentralMeridian: Double = 107.75
    @Published var vn2000ZoneDegrees: Int = 3
    @Published var vn2000ProvinceName: String = "Lâm Đồng"
    @Published var activeCoordSystemId: String = "9027"

    // 2. Global Visibility
    @Published var showLabelsGlobal: Bool = true
    @Published var showImagesGlobal: Bool = true
    @Published var showPointsGlobal: Bool = true
    @Published var showTracklogsGlobal: Bool = true
    @Published var showLinesGlobal: Bool = true
    @Published var showPolygonsGlobal: Bool = true
    @Published var showIncidentsGlobal: Bool = true
    @Published var showDailyJournalsGlobal: Bool = true
    @Published var showFloraFaunaGlobal: Bool = true
    @Published var showNaturalImpactGlobal: Bool = true

    // 3. Category Customization (Colors & Icons)
    @Published var imageColor: String = "#FFD32F2F"
    @Published var imageIconType: String = "camera"
    @Published var imageIconSize: Int = 40
    @Published var showImageLabels: Bool = true
    @Published var imageLabelSize: Int = 14

    @Published var pointColor: String = "#FF1976D2"
    @Published var pointIconType: String = "tree"
    @Published var pointIconSize: Int = 40
    @Published var showPointLabels: Bool = true
    @Published var pointLabelSize: Int = 14

    @Published var tracklogColor: String = "#FFFF3D00"
    @Published var tracklogWidth: Float = 3.0
    @Published var tracklogStyle: String = "solid"
    @Published var showTracklogLabels: Bool = true
    @Published var showTracklogValue: Bool = true
    @Published var tracklogFontSize: Int = 14

    @Published var lineColor: String = "#FF9C27B0"
    @Published var lineWidth: Float = 2.0
    @Published var lineStyle: String = "solid"
    @Published var showLineLabels: Bool = true
    @Published var showLineValue: Bool = true
    @Published var lineFontSize: Int = 14

    @Published var polygonBoundaryColor: String = "#FF1976D2"
    @Published var polygonFillColor: String = "#334CAF50"
    @Published var polygonWidth: Float = 2.0
    @Published var polygonStyle: String = "solid"
    @Published var showPolygonLabels: Bool = true
    @Published var showPolygonValue: Bool = true
    @Published var polygonFontSize: Int = 14

    // 4. System & Sensors
    @Published var fontEncoding: String = "TCVN3"
    @Published var distanceUnit: String = "km"
    @Published var areaUnit: String = "ha"
    @Published var gpsFilterDistance: Double = 5.0
    @Published var antennaHeight: Double = 0.0
    @Published var useAGps: Bool = true
    @Published var shakeToMoveMap: Bool = false
    @Published var keepScreenOn: Bool = true

    // 5. Default Info
    @Published var defaultIncidentLeader: String = ""
    @Published var defaultIncidentField: String = "Lâm nghiệp"
    @Published var defaultRecipientEmail: String = "nguyenbahung.ctdt@gmail.com"

    // 6. User Session
    @Published var registeredName: String = "Nguyễn Bá Hưng"
    @Published var registeredEmail: String = "nguyenbahung.ctdt@gmail.com"
    @Published var registeredPhone: String = "0986407464"
    @Published var registeredUnit: String = "Công ty TNHH MTV ĐTPT Đại Thành"
    @Published var registeredDept: String = "Phòng QL,SD&PTR"
    @Published var expiryDate: String = "2027-01-02"
    @Published var permissions: String = "FULL"

    func save() {
        // Logic to persist to UserDefaults
    }
}
