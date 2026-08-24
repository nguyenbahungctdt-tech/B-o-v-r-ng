import SwiftUI

struct CoordinateConverterView: View {
    @State private var wgs84Lat = ""
    @State private var wgs84Lon = ""
    @State private var vn2000X = ""
    @State private var vn2000Y = ""
    @State private var cm = "107.75"
    @State private var zone = 3

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hệ tọa độ WGS84 (GPS)")) {
                    TextField("Vĩ độ (Latitude)", text: $wgs84Lat)
                        .keyboardType(.decimalPad)
                    TextField("Kinh độ (Longitude)", text: $wgs84Lon)
                        .keyboardType(.decimalPad)

                    Button("Chuyển sang VN2000") {
                        if let lat = Double(wgs84Lat), let lon = Double(wgs84Lon) {
                            let res = CoordinateConverter.shared.wgs84ToVn2000(lat: lat, lon: lon, cm: Double(cm) ?? 107.75, zd: zone)
                            vn2000X = String(format: "%.1f", res.x)
                            vn2000Y = String(format: "%.1f", res.y)
                        }
                    }
                    .foregroundColor(.blue)
                }

                Section(header: Text("Hệ tọa độ VN2000")) {
                    TextField("Tọa độ X", text: $vn2000X)
                        .keyboardType(.decimalPad)
                    TextField("Tọa độ Y", text: $vn2000Y)
                        .keyboardType(.decimalPad)

                    Button("Chuyển sang WGS84") {
                        if let x = Double(vn2000X), let y = Double(vn2000Y) {
                            let res = CoordinateConverter.shared.vn2000ToWgs84(x: x, y: y, cm: Double(cm) ?? 107.75, zd: zone)
                            wgs84Lat = String(format: "%.6f", res.lat)
                            wgs84Lon = String(format: "%.6f", res.lon)
                        }
                    }
                    .foregroundColor(.green)
                }

                Section(header: Text("Cấu hình phép chiếu")) {
                    TextField("Kinh tuyến trục (CM)", text: $cm)
                        .keyboardType(.decimalPad)
                    Picker("Múi chiếu", selection: $zone) {
                        Text("3 độ").tag(3)
                        Text("6 độ").tag(6)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Chuyển đổi tọa độ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
