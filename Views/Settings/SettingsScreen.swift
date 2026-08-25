import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var preferences: UserPreferences
    @State private var showSystemSelector = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 1. Hệ tọa độ chính
                SettingGroupCard(title: "HỆ TỌA ĐỘ HIỂN THỊ CHÍNH", icon: "network") {
                    Button(action: { showSystemSelector = true }) {
                        HStack {
                            let sys = CoordinateConverter.shared.systems.first { $0.id == preferences.activeCoordSystemId } ?? CoordinateConverter.shared.systems[0]
                            Text(sys.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                }

                // 2. Phông chữ & Hiển thị chung
                SettingGroupCard(title: "PHÔNG CHỮ & HIỂN THỊ CHUNG", icon: "text.cursor") {
                    Picker("Bảng mã hóa font", selection: $preferences.fontEncoding) {
                        ForEach(["TCVN3", "VNI", "Unicode"], id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Toggle("Hiển thị lớp nhãn (Global)", isOn: $preferences.showLabelsGlobal)
                    Divider()
                    Group {
                        Toggle("Hiển thị Hình ảnh", isOn: $preferences.showImagesGlobal)
                        Toggle("Hiển thị Điểm", isOn: $preferences.showPointsGlobal)
                        Toggle("Hiển thị Tracklog", isOn: $preferences.showTracklogsGlobal)
                        Toggle("Hiển thị Đường (vệt)", isOn: $preferences.showLinesGlobal)
                        Toggle("Hiển thị Vùng", isOn: $preferences.showPolygonsGlobal)
                        Toggle("Hiển thị Nhật ký sự vụ", isOn: $preferences.showIncidentsGlobal)
                        Toggle("Hiển thị Động thực vật", isOn: $preferences.showFloraFaunaGlobal)
                        Toggle("Hiển thị Tác động tự nhiên", isOn: $preferences.showNaturalImpactGlobal)
                    }
                }

                // 3. Cài đặt chi tiết (Groups)
                SettingGroupCard(title: "CÀI ĐẶT HÌNH ẢNH", icon: "camera.fill") {
                    Toggle("Hiển thị nhãn tên", isOn: $preferences.showImageLabels)
                    HStack {
                        Text("Kích thước biểu tượng")
                        Spacer()
                        Text("\(preferences.imageIconSize)px").bold()
                    }
                }

                // 4. Thông số kỹ thuật & Cảm biến
                SettingGroupCard(title: "THÔNG SỐ KỸ THUẬT & CẢM BIẾN", icon: "gearshape.2.fill") {
                    Picker("Đơn vị đo độ dài", selection: $preferences.distanceUnit) {
                        ForEach(["m", "km"], id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Picker("Đơn vị đo diện tích", selection: $preferences.areaUnit) {
                        ForEach(["m2", "ha"], id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    HStack {
                        Text("Lọc GPS (mét)")
                        Spacer()
                        TextField("5.0", value: $preferences.gpsFilterDistance, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                // 5. Software Info
                VStack(alignment: .leading, spacing: 5) {
                    Text("PHẦN MỀM CHUYÊN NGÀNH LÂM NGHIỆP")
                        .font(.system(size: 13, weight: .black))
                    Text("Hệ thống Quản lý tuần tra Bảo vệ rừng - Đại Thành")
                        .font(.system(size: 12))
                    Text("Phiên bản v1.2 (Android 100% Match)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Divider()
                    Text("Tác giả: Nguyễn Bá Hưng - 0983.407.464")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer(minLength: 50)
            }
            .padding(.vertical)
        }
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
        .navigationTitle("CẤU HÌNH HỆ THỐNG")
        .sheet(isPresented: $showSystemSelector) {
            SystemSelectorView()
        }
    }
}

struct SettingGroupCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                Text(title)
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.1))

            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(Color.white)
        }
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
