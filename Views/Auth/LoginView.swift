import SwiftUI

struct LoginView: View {
    var onLoginSuccess: () -> Void
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var unitSelection = "Công ty TNHH MTV ĐTPT ĐẠI THÀNH"
    @State private var otherUnit = ""
    @State private var department = "Phòng QL,SD&PTR"
    @State private var activationKey = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    let units = ["Công ty TNHH MTV ĐTPT ĐẠI THÀNH", "Khác"]
    let departments = [
        "Ban Giám Đốc",
        "Phòng QL,SD&PTR",
        "Phân Trường I",
        "Phân Trường II",
        "Phân Trường III",
        "Phân Trường IV",
        "Phân Trường V",
        "Phân Trường VI",
        "Khác"
    ]

    var body: some View {
        ZStack(alignment: .top) {
            // 1. Forest Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 46/255, green: 125/255, blue: 50/255),
                    Color(red: 102/255, green: 153/255, blue: 102/255).opacity(0.8),
                    .white
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 380)
            .edgesIgnoringSafeArea(.top)

            ScrollView {
                VStack(spacing: 20) {
                    // 2. App Logo & Title
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 115, height: 110)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                            Image(systemName: "leaf.fill") // Placeholder for R.drawable.app_icon_forestry
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                        }

                        VStack(spacing: 2) {
                            Text("BẢO VỆ RỪNG")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(.white)
                                .tracking(2)

                            Text("- ĐẠI THÀNH -")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.95))
                                .padding(.top, -5)
                        }
                    }
                    .padding(.top, 40)

                    // 3. Main Registration Card
                    VStack(alignment: .leading, spacing: 18) {
                        Text("ĐĂNG KÝ THÔNG TIN CÁN BỘ")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                            .padding(.bottom, 5)

                        Group {
                            LoginField(icon: "person.fill", placeholder: "Họ tên cán bộ thực hiện", text: $name, hint: "Gợi ý: Nguyễn Bá Hưng")
                            LoginField(icon: "envelope.fill", placeholder: "Địa chỉ Gmail", text: $email, hint: "Gợi ý: nguyenbahung.ctdt@gmail.com")
                            LoginField(icon: "phone.fill", placeholder: "Số điện thoại liên lạc", text: $phone, hint: "Gợi ý: 0986407464", keyboardType: .numberPad)
                        }

                        // Unit Picker with "Other" logic
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                                    .frame(width: 20)
                                Text("Đơn vị công tác")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)
                                Spacer()
                                Picker("", selection: $unitSelection) {
                                    ForEach(units, id: \.self) { Text($0) }
                                }
                                .pickerStyle(.menu)
                                .font(.system(size: 14, weight: .bold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))

                            Text("Gợi ý: Công ty TNHH MTV ĐTPT ĐẠI THÀNH")
                                .font(.system(size: 10))
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.leading, 12)
                        }

                        if unitSelection == "Khác" {
                            LoginField(icon: "building.2.fill", placeholder: "Nhập tên đơn vị công tác", text: $otherUnit, hint: "")
                        }

                        // Department Picker
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "forest.fill")
                                    .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                                    .frame(width: 20)
                                Text("Bộ phận công tác")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)
                                Spacer()
                                Picker("", selection: $department) {
                                    ForEach(departments, id: \.self) { Text($0) }
                                }
                                .pickerStyle(.menu)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }

                        LoginField(icon: "key.fill", placeholder: "Mã kích hoạt ứng dụng", text: $activationKey, hint: "Nhập Key do quản trị cấp")

                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                        }

                        // Buttons
                        VStack(spacing: 12) {
                            Button(action: performLogin) {
                                HStack {
                                    if isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: "icloud.and.arrow.up.fill")
                                        Text("KÍCH HOẠT VÀ ĐĂNG KÝ")
                                            .fontWeight(.black)
                                            .tracking(1)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 46/255, green: 125/255, blue: 50/255))
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                            .disabled(isLoading)

                            Button(action: { onLoginSuccess() }) {
                                Text("Dùng thử ngoại tuyến")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(25)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 10)
                    .padding(.horizontal, 20)

                    // 4. Footer
                    VStack(spacing: 4) {
                        Text("Hệ thống quản lý dữ liệu Bảo vệ rừng - Đại Thành")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                        Text("Tác giả: Nguyễn Bá Hưng - 0983.407.464")
                            .font(.system(size: 11))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.vertical, 30)
                }
            }
        }
    }

    private func performLogin() {
        guard !name.isEmpty, !email.isEmpty, !activationKey.isEmpty else {
            errorMessage = "Vui lòng nhập đầy đủ thông tin!"
            return
        }

        isLoading = true
        errorMessage = nil

        let finalUnit = unitSelection == "Khác" ? otherUnit : unitSelection
        let userInfo = ["name": name, "email": email, "phone": phone, "unit": finalUnit, "dept": department]

        Task {
            let result = await CloudSyncRepository.shared.verifyActivationKey(
                key: activationKey,
                deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "ios-device",
                userInfo: userInfo
            )

            await MainActor.run {
                isLoading = false
                if result.isValid {
                    onLoginSuccess()
                } else {
                    errorMessage = result.message ?? "Lỗi xác thực!"
                }
            }
        }
    }
}

struct LoginField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let hint: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                    .frame(width: 20)

                TextField(placeholder, text: $text)
                    .font(.system(size: 15, weight: .medium))
                    .keyboardType(keyboardType)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.15), lineWidth: 1))

            if !hint.isEmpty {
                Text(hint)
                    .font(.system(size: 10))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.leading, 10)
            }
        }
    }
}
