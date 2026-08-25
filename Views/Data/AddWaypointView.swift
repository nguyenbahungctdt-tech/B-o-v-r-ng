import SwiftUI
import CoreLocation

struct AddWaypointView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var preferences: UserPreferences

    @State private var locationSource = 0 // 0: GPS, 1: TÂM BẢN ĐỒ, 2: THỦ CÔNG
    @State private var title = ""
    @State private var notes = ""

    // Values passed from Map
    var currentGPS: CLLocationCoordinate2D?
    var mapCenter: CLLocationCoordinate2D?

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("ĐÁNH DẤU ĐIỂM THỰC ĐỊA")
                .font(.system(size: 20, weight: .black))
                .foregroundColor(.black)
                .padding(.top, 20)

            // Location Source Tabs
            HStack(spacing: 0) {
                TabButton(title: "GPS", isSelected: locationSource == 0) { locationSource = 0 }
                TabButton(title: "TÂM BẢN ĐỒ", isSelected: locationSource == 1) { locationSource = 1 }
                TabButton(title: "THỦ CÔNG", isSelected: locationSource == 2) { locationSource = 2 }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)

            // Coordinate Display Box
            VStack(alignment: .leading, spacing: 8) {
                Text("Tọa độ ghi nhận:")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.green)

                let coord = getDisplayCoordinate()
                let vn = CoordinateConverter.shared.wgs84ToVn2000(lat: coord.latitude, lon: coord.longitude, cm: preferences.vn2000CentralMeridian, zd: preferences.vn2000ZoneDegrees)

                let cmStr = String(format: "%.2f", preferences.vn2000CentralMeridian).replacingOccurrences(of: ".00", with: "").replacingOccurrences(of: ".", with: "°") + "'"

                Text("VN2000 Mui \(preferences.vn2000ZoneDegrees)° - \(cmStr) (\(preferences.vn2000ProvinceName)): X=\(String(format: "%.2f", vn.x)), Y=\(String(format: "%.2f", vn.y))")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))

                Text("WGS84: \(String(format: "%.6f", coord.latitude)), \(String(format: "%.6f", coord.longitude))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)

            // Input Fields
            VStack(spacing: 15) {
                TextField("Tên điểm khảo sát *", text: $title)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))

                TextEditor(text: $notes)
                    .frame(height: 100)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        ZStack(alignment: .topLeading) {
                            if notes.isEmpty {
                                Text("Ghi chú thực địa")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 18)
                            }
                            RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        }
                    )
            }
            .padding(.horizontal)

            // Buttons
            VStack(spacing: 12) {
                Button(action: { saveAndReport() }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("LƯU & BÁO CÁO (EMAIL)")
                    }
                    .font(.system(size: 14, weight: .black))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 46/255, green: 125/255, blue: 50/255))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }

                Button(action: { saveLocal() }) {
                    HStack {
                        Image(systemName: "tray.and.arrow.down.fill")
                        Text("CHỈ LƯU MÁY (LOCAL)")
                    }
                    .font(.system(size: 14, weight: .black))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                    .cornerRadius(25)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color(red: 46/255, green: 125/255, blue: 50/255), lineWidth: 1))
                }
            }
            .padding(.horizontal)

            Button("HỦY BỎ") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.green)
            .padding(.bottom, 20)
        }
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
        .edgesIgnoringSafeArea(.bottom)
    }

    private func getDisplayCoordinate() -> CLLocationCoordinate2D {
        switch locationSource {
        case 0: return currentGPS ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        case 1: return mapCenter ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        default: return currentGPS ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }

    private func saveLocal() {
        presentationMode.wrappedValue.dismiss()
    }

    private func saveAndReport() {
        presentationMode.wrappedValue.dismiss()
    }
}
