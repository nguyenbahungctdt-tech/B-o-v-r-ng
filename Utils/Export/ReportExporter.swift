import Foundation

struct ReportExporter {
    static let shared = ReportExporter()

    func generatePatrolReportText(
        patrolLog: [String: Any],
        officer: [String: String],
        cm: Double,
        zone: Int
    ) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"

        let discoveryTime = patrolLog["discoveryTime"] as? Int64 ?? 0
        let dateStr = df.string(from: Date(timeIntervalSince1970: TimeInterval(discoveryTime / 1000)))
        let nowStr = df.string(from: Date())

        let report = """
        CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM
        Độc lập - Tự do - Hạnh phúc
        --------------------------

        PHIẾU GHI NHẬN TUẦN TRA BẢO VỆ RỪNG (iOS)

        I. THÔNG TIN CHUNG
        - Cán bộ thực hiện: \(officer["name"] ?? "Chưa xác định")
        - Đơn vị: \(officer["unit"] ?? "Hạt Kiểm lâm / Ban Quản lý rừng")
        - Thời gian phát hiện: \(dateStr)
        - Thời gian lập báo cáo: \(nowStr)

        II. CHI TIẾT SỰ VỤ
        - Loại hình sự vụ: \(patrolLog["incidentType"] ?? "")
        - Địa điểm: \(patrolLog["violationLocation"] ?? "")

        III. THÔNG TIN VỊ TRÍ (GPS)
        - Hệ tọa độ WGS84: Lat \(patrolLog["latitude"] ?? 0), Lon \(patrolLog["longitude"] ?? 0)
        - Hệ tọa độ VN2000 (CM \(cm)): X=\(patrolLog["vn2000X"] ?? 0), Y=\(patrolLog["vn2000Y"] ?? 0)

        IV. ĐỐI TƯỢNG VÀ TANG VẬT
        - Đối tượng: \(patrolLog["violatorName"] ?? "Chưa xác định")
        - Tang vật: \(patrolLog["confiscatedTools"] ?? "Không có")

        V. BIỆN PHÁP XỬ LÝ
        - Ghi chú: \(patrolLog["notes"] ?? "Không có")

        ----------------------------------------------------
        Báo cáo trích xuất từ Hệ thống Bảo vệ rừng - Đại Thành (iOS)
        """
        return report
    }
}
