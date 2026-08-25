import SwiftUI

struct SystemSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var preferences: UserPreferences
    @State private var searchQuery = ""

    var systems: [CoordinateSystem] { CoordinateConverter.shared.systems }

    var filteredSystems: [CoordinateSystem] {
        if searchQuery.isEmpty { return systems }
        return systems.filter { $0.name.lowercased().contains(searchQuery.lowercased()) || $0.id.contains(searchQuery) }
    }

    var groupedSystems: [String: [CoordinateSystem]] {
        Dictionary(grouping: filteredSystems) { sys in
            if sys.projection == "WGS84" { return "Hệ tọa độ Quốc tế (WGS 84)" }
            if sys.projection == "VN2000" && sys.zoneDegrees == 3 { return "VN2000 Múi 3° (Theo Tỉnh)" }
            if sys.projection == "VN2000" && sys.zoneDegrees == 6 { return "VN2000 Múi 6° (Toàn quốc)" }
            if sys.projection == "UTM" { return "Hệ lưới chiếu UTM WGS 84" }
            return "Khác"
        }
    }

    let groupOrder = [
        "Hệ tọa độ Quốc tế (WGS 84)",
        "VN2000 Múi 3° (Theo Tỉnh)",
        "VN2000 Múi 6° (Toàn quốc)",
        "Hệ lưới chiếu UTM WGS 84",
        "Khác"
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar like Android
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Tìm kiếm (Tên hoặc EPSG)...", text: $searchQuery)
                        .font(.system(size: 15))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .padding()

                List {
                    ForEach(groupOrder.filter { groupedSystems[$0] != nil }, id: \.self) { group in
                        Section(header: Text(group).font(.system(size: 12, weight: .black)).foregroundColor(.green)) {
                            ForEach(groupedSystems[group] ?? []) { sys in
                                Button(action: {
                                    preferences.activeCoordSystemId = sys.id
                                    if sys.projection == "VN2000" {
                                        preferences.vn2000CentralMeridian = sys.centralMeridian
                                        preferences.vn2000ZoneDegrees = sys.zoneDegrees
                                        // Attempt to extract province name
                                        if let start = sys.name.range(of: "(")?.upperBound,
                                           let end = sys.name.range(of: ")")?.lowerBound {
                                            preferences.vn2000ProvinceName = String(sys.name[start..<end])
                                        }
                                    }
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Image(systemName: sys.projection == "WGS84" ? "network" : "map.fill")
                                                .foregroundColor(preferences.activeCoordSystemId == sys.id ? .green : .gray)
                                            Text(sys.name)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(preferences.activeCoordSystemId == sys.id ? .green : .black)
                                        }
                                        Text("ID: \(sys.id) | CM: \(String(format: "%.1f", sys.centralMeridian))°")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())

                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("ĐÓNG")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .navigationTitle("CHỌN HỆ TỌA ĐỘ")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 245/255, green: 245/255, blue: 245/255))
        }
    }
}
