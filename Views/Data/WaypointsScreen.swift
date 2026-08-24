import SwiftUI

struct WaypointsScreen: View {
    var body: some View {
        List {
            Section(header: Text("Điểm thực địa")) {
                ForEach(0..<5) { i in
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Điểm kiểm tra lô \(i+1)")
                                .font(.headline)
                            Text("Lâm Đồng - 23/08/2026")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            Section(header: Text("Tracklogs tuần tra")) {
                ForEach(0..<3) { i in
                    HStack {
                        Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                            .foregroundColor(.red)
                        VStack(alignment: .leading) {
                            Text("Tuyến tuần tra ngày \(i+20)/08")
                                .font(.headline)
                            Text("Quãng đường: 4.5km")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle("Dữ liệu tuần tra")
    }
}
