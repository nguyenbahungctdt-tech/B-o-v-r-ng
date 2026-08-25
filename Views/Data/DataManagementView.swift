import SwiftUI

struct DataManagementView: View {
    @State private var selectedTab = 0
    let tabs = ["THEO NGÀY", "HÌNH ẢNH", "ĐIỂM", "TRACKLOG", "ĐƯỜNG (VỆT)", "VÙNG", "SỰ VỤ", "ĐỘNG THỰC VẬT", "TÁC ĐỘNG TN", "HẰNG NGÀY"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. Horizontal Scrollable Tab Header
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            VStack(spacing: 8) {
                                Text(tabs[index])
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(selectedTab == index ? Color(red: 46/255, green: 125/255, blue: 50/255) : .gray)

                                Rectangle()
                                    .fill(selectedTab == index ? Color(red: 46/255, green: 125/255, blue: 50/255) : Color.clear)
                                    .frame(height: 2)
                            }
                            .onTapGesture { selectedTab = index }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 2)

                // 2. List Content
                ScrollView {
                    VStack(spacing: 15) {
                        // Date Header like Android image
                        HStack {
                            Text("NGÀY 24/08/2026 (2 mục)")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "paperplane.fill")
                                Text("BÁO CÁO NGÀY")
                            }
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(red: 46/255, green: 125/255, blue: 50/255))
                            .cornerRadius(6)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)

                        // Sample Cards
                        DataCard(title: "Ảnh 03", coords: "VN2000: X=492005, Y=1388810")
                        DataCard(title: "Ảnh 02", coords: "VN2000: X=491943, Y=1388735")
                    }
                    .padding(.vertical)
                }
                .background(Color(red: 245/255, green: 245/255, blue: 245/255))
            }
            .navigationTitle("QUẢN LÝ DỮ LIỆU THỰC ĐỊA")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DataCard: View {
    let title: String
    let coords: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 15) {
                // Preview Image with overlay border
                ZStack {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 85, height: 85)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)

                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: 85, height: 85)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.system(size: 17, weight: .black))
                            .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: "cloud.fill")
                                .foregroundColor(.gray.opacity(0.5))
                            Image(systemName: "eye.fill")
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
                        .font(.system(size: 16))
                    }

                    Text(coords)
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(8)

                    // 6 Format Dots like Android
                    HStack(spacing: 8) {
                        Text("Định dạng:")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)

                        let colors: [Color] = [.blue, .red, .green, .yellow, .purple, .orange]
                        ForEach(0..<colors.count, id: \.self) { i in
                            Circle()
                                .fill(colors[i])
                                .frame(width: 24, height: 24)
                                .shadow(radius: 1)
                        }
                    }
                    .padding(.top, 2)
                }
            }

            Divider().background(Color.gray.opacity(0.2))

            // Action Row
            HStack(spacing: 20) {
                ActionLabel(icon: "pencil", text: "SỬA")
                ActionLabel(icon: "info.circle", text: "CHI TIẾT")

                Image(systemName: "envelope.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 18))

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "location.north.fill")
                    Text("DẪN ĐƯỜNG")
                }
                .font(.system(size: 11, weight: .black))
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color(red: 46/255, green: 125/255, blue: 50/255))
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: .green.opacity(0.2), radius: 3, x: 0, y: 2)
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct ActionLabel: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.system(size: 11, weight: .black))
        .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
    }
}
