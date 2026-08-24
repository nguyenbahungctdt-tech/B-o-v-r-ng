# BaoVeRung - Ứng dụng iOS Bảo vệ rừng (Đại Thành)

Ứng dụng di động độc lập dành cho hệ điều hành iOS, hỗ trợ cán bộ lâm nghiệp trong công tác tuần tra, quản lý rừng và ghi nhận hiện trường.

## Tính năng chính
- **Bản đồ Lâm nghiệp:** Hỗ trợ MapLibre SDK, hiển thị các lớp GIS (KML, GeoJSON, MBTiles).
- **Hệ tọa độ VN2000:** Tích hợp bộ chuyển đổi tọa độ VN2000 cho 63 tỉnh thành Việt Nam.
- **Tuần tra & Báo cáo:**
    - Ghi lại lộ trình tuần tra (Tracklog) ngay cả khi offline.
    - Mẫu báo cáo sự vụ vi phạm lâm luật.
    - Ghi nhận đa dạng sinh học (Động thực vật).
    - Báo cáo tác động tài nguyên rừng (Cháy rừng, phá rừng).
- **Làm việc Ngoại tuyến:** Lưu trữ dữ liệu cục bộ bằng CoreData và đồng bộ khi có mạng.

## Công nghệ sử dụng
- **SwiftUI:** Xây dựng giao diện hiện đại, tối ưu cho iPhone/iPad.
- **CoreData:** Quản lý cơ sở dữ liệu cục bộ.
- **MapLibre Native SDK:** Công cụ bản đồ mạnh mẽ, hỗ trợ vector và raster tiles ngoại tuyến.
- **CoreLocation:** Truy xuất tọa độ GPS chính xác cao.

## Hướng dẫn cài đặt cho nhà phát triển
1. Yêu cầu: macOS chạy Xcode 15 trở lên.
2. Sao chép mã nguồn về máy.
3. Mở tệp `BaoVeRungApp.swift` trong Xcode.
4. Cấu hình **Bundle Identifier** và **Signing & Capabilities**.
5. Cài đặt các thư viện phụ thuộc (Dependencies) qua Swift Package Manager (SPM):
    - MapLibre Native SDK: `https://github.com/maplibre/maplibre-native-ios`
6. Nhấn **Run** để khởi chạy trên trình giả lập hoặc thiết bị thật.

## Liên hệ
Dự án được phát triển bởi Công ty TNHH MTV ĐTPT Đại Thành.
