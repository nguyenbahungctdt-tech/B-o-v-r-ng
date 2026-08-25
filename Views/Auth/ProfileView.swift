import SwiftUI

struct ProfileView: View {
    @State private var officerName = "Nguyễn Bá Hưng"
    @State private var email = "nguyenbahung.ctdt@gmail.com"
    @State private var phone = "0986407464"
    @State private var unit = "Công ty TNHH MTV ĐTPT ĐẠI THÀNH"
    @State private var department = "Phòng QL,SD&PTR"
    @State private var expiryDate = "2027-01-02"
    @State private var permissions = "FULL"

    var body: some View {
        ZStack(alignment: .top) {
            // Background Gradient Header
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 46/255, green: 125/255, blue: 50/255), Color(red: 102/255, green: 153/255, blue: 102/255).opacity(0.8), .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            .edgesIgnoringSafeArea(.top)

            ScrollView {
                VStack(spacing: 20) {
                    // Logo Header like Android
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 105, height: 100)
                                .shadow(radius: 5)

                            Image(systemName: "leaf.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 65, height: 65)
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                        }

                        VStack(spacing: 2) {
                            Text("BẢO VỆ RỪNG")
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(.white)
                                .tracking(2)

                            Text("Công ty TNHH MTV ĐTPT Đại Thành")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.top, 30)

                    // Profile Card
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Spacer()
                            Text("PHIÊN ĐĂNG NHẬP HOẠT ĐỘNG")
                                .font(.system(size: 10, weight: .black))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                                .cornerRadius(8)
                            Spacer()
                        }

                        Text(officerName)
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 5)

                        VStack(alignment: .leading, spacing: 10) {
                            ProfileInfoRow(label: "Họ tên:", value: officerName)
                            ProfileInfoRow(label: "Gmail:", value: email)
                            ProfileInfoRow(label: "Số điện thoại:", value: phone)
                            ProfileInfoRow(label: "Đơn vị:", value: unit)
                            ProfileInfoRow(label: "Bộ phận:", value: department)

                            HStack {
                                Text("Quyền hạn:")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.gray)
                                Text(permissions)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                            }
                        }

                        Divider()
                            .padding(.vertical, 10)

                        HStack {
                            Text("Hạn sử dụng:")
                                .font(.system(size: 14, weight: .bold))
                            Spacer()
                            Text(expiryDate)
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                        }

                        VStack(spacing: 12) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "arrow.clockwise.icloud.fill")
                                    Text("ĐỒNG BỘ DỮ LIỆU")
                                        .fontWeight(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 46/255, green: 125/255, blue: 50/255))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.top, 10)

                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "clock.arrow.2.circlepath")
                                    Text("LÀM MỚI LỊCH SỬ")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                                .foregroundColor(.gray)
                            }
                        }

                        Button(action: {}) {
                            Text("Đăng xuất tài khoản")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 10)
                        }
                    }
                    .padding(25)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
    }
}
