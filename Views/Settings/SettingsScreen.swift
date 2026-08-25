import SwiftUI

struct SettingsScreen: View {
    @State private var centralMeridian = "107.75"
    @State private var zoneDegrees = "3"
    @State private var province = "Lâm Đồng"

    // Forestry specific settings
    @State private var distUnit = "km"
    @State private var areaUnit = "ha"
    @State private var gpsFilter = "5.0"

    let provinces = ["Lâm Đồng", "Đắk Lắk", "Gia Lai", "Kon Tum", "Đắk Nông"]
    let distUnits = ["m", "km"]
    let areaUnits = ["m2", "ha"]

    var body: some View {
        Form {
            Section(header: Text("Cấu hình VN2000").font(.caption.bold())) {
                Picker("Tỉnh thành", selection: $province) {
                    ForEach(provinces, id: \.self) { Text($0) }
                }
                HStack {
                    Text("KTT (CM)")
                    Spacer()
                    TextField("107.75", text: $centralMeridian)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Múi chiếu")
                    Spacer()
                    TextField("3", text: $zoneDegrees)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section(header: Text("Đơn vị & GPS").font(.caption.bold())) {
                Picker("Khoảng cách", selection: $distUnit) {
                    ForEach(distUnits, id: \.self) { Text($0) }
                }
                .pickerStyle(SegmentedPickerStyle())

                Picker("Diện tích", selection: $areaUnit) {
                    ForEach(areaUnits, id: \.self) { Text($0) }
                }
                .pickerStyle(SegmentedPickerStyle())

                HStack {
                    Text("Lọc GPS (mét)")
                    Spacer()
                    TextField("5.0", text: $gpsFilter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }

            @State private var isSyncing = false
    @State private var syncMessage: String? = nil

    var body: some View {
        Form {
            // ... (Sections before)
            Section(header: Text("Tài khoản & Hệ thống").font(.caption.bold())) {
                Button(action: verifyKey) {
                    Label("Kiểm tra mã kích hoạt", systemImage: "key.fill")
                }

                Button(action: startManualSync) {
                    HStack {
                        Label("Đồng bộ ngay với Firebase", systemImage: "arrow.clockwise.icloud.fill")
                        if isSyncing {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .foregroundColor(.blue)
                .disabled(isSyncing)

                if let msg = syncMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Button(action: {}) {
                    Label("Đăng xuất", systemImage: "power")
                }
                .foregroundColor(.red)
            }
            // ...
        }
        .navigationTitle("Cài đặt")
    }

    private func verifyKey() {
        // Logic to verify current key
    }

    private func startManualSync() {
        isSyncing = true
        syncMessage = "Đang kiểm tra dữ liệu..."

        Task {
            // Simulating sync for now - in real app would loop through pending CoreData records
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)

            DispatchQueue.main.async {
                isSyncing = false
                syncMessage = "Đã đồng bộ thành công lúc \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))"
            }
        }
    }
}

            Section(header: Text("Thông tin").font(.caption.bold())) {
                HStack {
                    Text("Phiên bản")
                    Spacer()
                    Text("1.2 (iOS 100% Match)")
                }
                Text("Công ty MTV ĐTPT Đại Thành")
            }
        }
        .navigationTitle("Cài đặt")
    }
}
