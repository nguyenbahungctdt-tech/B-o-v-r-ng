import SwiftUI

struct LoginView: View {
    var onLoginSuccess: () -> Void
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var unit = "Công ty TNHH MTV ĐTPT ĐẠI THÀNH"
    @State private var department = "Ban Giám Đốc"
    @State private var activationKey = ""
    @State private var isOffline = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    let units = ["Công ty TNHH MTV ĐTPT ĐẠI THÀNH", "Khác"]
    let departments = ["Ban Giám Đốc", "Phòng QL,SD&PTR", "Phân Trường I", "Phân Trường II", "Phân Trường III", "Phân Trường IV", "Phân Trường V", "Phân Trường VI", "Khác"]

    var body: some View {
        ZStack(alignment: .top) {
            // 1. Forest Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color(red: 46/255, green: 125/255, blue: 50/255), Color.green.opacity(0.7), .white]), startPoint: .top, endPoint: .bottom)
                .frame(height: 350)
                .edgesIgnoringSafeArea(.top)

            ScrollView {
                VStack(spacing: 25) {
                    // 2. App Logo
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 110, height: 110)
                                .shadow(radius: 10)

                            Image(systemName: "leaf.fill") // Placeholder for app_icon_forestry
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70, height: 70)
                                .foregroundColor(.green)
                        }

                        VStack(spacing: 4) {
                            Text("BẢO VỆ RỪNG")
                                .font(.system(size: 26, weight: .black))
                                .foregroundColor(.white)
                                .tracking(2)

                            Text("Công ty TNHH MTV ĐTPT Đại Thành")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.top, 40)

                    // 3. Registration Form
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ĐĂNG KÝ THÔNG TIN CÁN BỘ")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.green)

                        VStack(spacing: 12) {
                            LoginTextField(icon: "person.fill", placeholder: "Họ tên cán bộ thực hiện", text: $name)
                            LoginTextField(icon: "envelope.fill", placeholder: "Địa chỉ Gmail", text: $email)
                            LoginTextField(icon: "phone.fill", placeholder: "Số điện thoại liên lạc", text: $phone)
                                .keyboardType(.numberPad)

                            // Unit Picker
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Đơn vị công tác", systemImage: "building.2.fill")
                                    .font(.caption.bold())
                                    .foregroundColor(.green)
                                Picker("Đơn vị", selection: $unit) {
                                    ForEach(units, id: \.self) { Text($0) }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }

                            // Department Picker
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Bộ phận / Phân trường", systemImage: "forest.fill")
                                    .font(.caption.bold())
                                    .foregroundColor(.green)
                                Picker("Bộ phận", selection: $department) {
                                    ForEach(departments, id: \.self) { Text($0) }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(10)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }

                            LoginTextField(icon: "key.fill", placeholder: "Mã kích hoạt ứng dụng", text: $activationKey)
                        }

                        if let error = errorMessage {
                            Text(error)
                                .font(.caption.bold())
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }

                        Button(action: performLogin) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "icloud.and.arrow.up.fill")
                                    Text("KÍCH HOẠT VÀ ĐĂNG KÝ")
                                        .fontWeight(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isLoading ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading)
                        .padding(.top, 10)

                        Button(action: {
                            isOffline = true
                            onLoginSuccess()
                        }) {
                            HStack {
                                Image(systemName: "wifi.slash")
                                Text("Dùng thử ngoại tuyến")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.gray)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(radius: 5)

                    // 4. Footer
                    VStack {
                        Text("Hệ thống quản lý dữ liệu Bảo vệ rừng - Đại Thành")
                            .font(.system(size: 12, weight: .bold))
                        Text("Tác giả: Nguyễn Bá Hưng - 0983.407.464")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func performLogin() {
        guard !name.isEmpty, !email.isEmpty, !activationKey.isEmpty else {
            errorMessage = "Vui lòng điền đầy đủ thông tin!"
            return
        }

        isLoading = true
        errorMessage = nil

        let userInfo = [
            "name": name,
            "email": email,
            "phone": phone,
            "unit": unit,
            "dept": department
        ]

        Task {
            let result = await CloudSyncRepository.shared.verifyActivationKey(
                key: activationKey,
                deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "ios-device",
                userInfo: userInfo
            )

            DispatchQueue.main.async {
                isLoading = false
                if result.isValid {
                    // Update global personnel info
                    Task {
                        await CloudSyncRepository.shared.updatePersonnelInfo(
                            user: userInfo,
                            registrationKey: activationKey,
                            permissions: result.permissions,
                            canSync: result.canSync
                        )
                    }
                    onLoginSuccess()
                } else {
                    errorMessage = result.message ?? "Lỗi xác thực không xác định"
                }
            }
        }
    }
}

struct LoginTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
