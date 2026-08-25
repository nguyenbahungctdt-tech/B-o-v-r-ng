import SwiftUI

struct CoordinateConverterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    let tabs = ["Nhập tay", "Danh sách", "Tệp (CSV/Excel)"]

    @State private var sourceSystemId = "EPSG:4326"
    @State private var targetSystemId = "9027" // Default to Lam Dong
    @State private var input1 = "" // Longitude or X
    @State private var input2 = "" // Latitude or Y
    @State private var result1 = ""
    @State private var result2 = ""

    var systems: [CoordinateSystem] { CoordinateConverter.shared.systems }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Header
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        VStack(spacing: 8) {
                            Text(tabs[index])
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(selectedTab == index ? Color(red: 46/255, green: 125/255, blue: 50/255) : .gray)

                            Rectangle()
                                .fill(selectedTab == index ? Color(red: 46/255, green: 125/255, blue: 50/255) : Color.clear)
                                .frame(height: 2)
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture { selectedTab = index }
                    }
                }
                .background(Color.white)

                ScrollView {
                    VStack(spacing: 20) {
                        // Source Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("HỆ TỌA ĐỘ NGUỒN")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))

                            SystemPicker(selection: $sourceSystemId, systems: systems)

                            HStack(spacing: 15) {
                                ConverterTextField(placeholder: "Longitude / X", text: $input1)
                                ConverterTextField(placeholder: "Latitude / Y", text: $input2)
                            }
                        }
                        .padding(20)
                        .background(Color.purple.opacity(0.05))
                        .cornerRadius(15)

                        Image(systemName: "arrow.up.arrow.down")
                            .font(.title2.bold())
                            .foregroundColor(.black)

                        // Target Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("HỆ TỌA ĐỘ ĐÍCH")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))

                            SystemPicker(selection: $targetSystemId, systems: systems)

                            if !result1.isEmpty {
                                HStack(spacing: 15) {
                                    ResultBox(text: result1)
                                    ResultBox(text: result2)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.purple.opacity(0.05))
                        .cornerRadius(15)

                        Button(action: performConversion) {
                            Text("CHUYỂN ĐỔI")
                                .font(.system(size: 16, weight: .black))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 46/255, green: 125/255, blue: 50/255))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    .padding(15)
                }
            }
            .navigationTitle("CHUYỂN ĐỔI HỆ TỌA ĐỘ")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
            })
        }
    }

    private func performConversion() {
        guard let x = Double(input1.replacingOccurrences(of: ",", with: ".")),
              let y = Double(input2.replacingOccurrences(of: ",", with: ".")) else { return }

        let src = systems.first { $0.id == sourceSystemId } ?? systems[0]
        let dst = systems.first { $0.id == targetSystemId } ?? systems[0]

        // 1. Convert source to WGS84
        let wgs: (lat: Double, lon: Double)
        if src.projection == "WGS84" {
            wgs = (lat: y, lon: x)
        } else {
            let res = CoordinateConverter.shared.vn2000ToWgs84(x: x, y: y, cm: src.centralMeridian, zd: src.zoneDegrees)
            wgs = (lat: res.lat, lon: res.lon)
        }

        // 2. Convert WGS84 to target
        if dst.projection == "WGS84" {
            if dst.id == "WGS84_DMS" {
                result1 = CoordinateConverter.shared.formatDecimalToDms(wgs.lon)
                result2 = CoordinateConverter.shared.formatDecimalToDms(wgs.lat)
            } else {
                result1 = String(format: "%.6f", wgs.lon)
                result2 = String(format: "%.6f", wgs.lat)
            }
        } else {
            let res = CoordinateConverter.shared.wgs84ToVn2000(lat: wgs.lat, lon: wgs.lon, cm: dst.centralMeridian, zd: dst.zoneDegrees)
            result1 = String(format: "%.1f", res.x)
            result2 = String(format: "%.1f", res.y)
        }
    }
}

struct SystemPicker: View {
    @Binding var selection: String
    let systems: [CoordinateSystem]

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(systems) { sys in
                Text(sys.name).tag(sys.id)
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct ConverterTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .keyboardType(.decimalPad)
    }
}

struct ResultBox: View {
    let text: String
    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .font(.system(size: 14, weight: .bold))
    }
}
