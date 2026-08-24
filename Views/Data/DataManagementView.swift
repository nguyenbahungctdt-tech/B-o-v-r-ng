import SwiftUI

struct DataManagementView: View {
    @State private var selectedTab = 0
    let tabs = ["THEO NGÀY", "HÌNH ẢNH", "ĐIỂM", "TRACKLOG", "ĐƯỜNG", "VÙNG", "SỰ VỤ", "ĐỘNG THỰC VẬT", "TÁC ĐỘNG TN", "HẰNG NGÀY"]

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable Tab Header like Android
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: { selectedTab = index }) {
                            VStack(spacing: 8) {
                                Text(tabs[index])
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(selectedTab == index ? .green : .gray)

                                Rectangle()
                                    .fill(selectedTab == index ? .green : .clear)
                                    .frame(height: 2)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 2)

            // List Content
            List {
                if selectedTab == 0 { // THEO NGÀY
                    Section(header: HStack {
                        Text("NGÀY 24/08/2026 (5 mục)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.green)
                        Spacer()
                        Button("BÁO CÁO NGÀY") {}
                            .font(.system(size: 10, weight: .bold))
                    }) {
                        DataCardView(title: "Phá rừng trái pháp luật", type: "patrol", color: .red)
                        DataCardView(title: "Tuyến tuần tra lô 1", type: "track", color: .orange)
                        DataCardView(title: "Ảnh hiện trường cây đổ", type: "image", color: .blue)
                    }
                } else {
                    Text("Danh sách \(tabs[selectedTab]) sẽ hiển thị ở đây...")
                        .foregroundColor(.gray)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("QUẢN LÝ DỮ LIỆU")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataCardView: View {
    let title: String
    let type: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // Icon based on type
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    if type == "patrol" {
                        ForestryIcon(type: "notebook", color: .red, size: 25)
                    } else if type == "track" {
                        Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                            .foregroundColor(.orange)
                    } else {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.blue)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 14, weight: .black))
                        Spacer()
                        Image(systemName: "icloud.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }

                    Text("VN2000: X=1,321,450, Y=456,781")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)

                    HStack {
                        Text("CHI TIẾT")
                        Text("DẪN ĐƯỜNG")
                        Text("BÁO CÁO")
                    }
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.green)
                    .padding(.top, 4)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
