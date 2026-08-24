import SwiftUI

struct PatrolLogFormView: View {
    @Environment(\.presentationMode) var presentationMode

    // 1. Group: Thông tin chung
    @State private var violationField = "Lâm nghiệp"
    @State private var incidentType = "Phá rừng trái pháp luật (Điều 23)"
    @State private var leaderName = ""
    @State private var violationTime = Date()
    @State private var violationLocation = ""

    // 2. Group: Đối tượng vi phạm
    @State private var violatorName = ""
    @State private var violatorIdCard = ""
    @State private var violatorPhone = ""
    @State private var violatorAddress = ""

    // 3. Group: Tang vật & Xử lý
    @State private var confiscatedTools = ""
    @State private var relatedPersons = ""
    @State private var onSiteAction = "Lập biên bản tại chỗ và thu giữ tang vật"
    @State private var onSiteRecordings = ""
    @State private var notes = ""

    let violationFields = ["Lâm nghiệp", "Đất đai"]
    let forestryIncidents = [
        "Phá rừng trái pháp luật (Điều 23)",
        "Khai thác rừng tự nhiên trái pháp luật (Điều 16)",
        "Vi phạm quy định về bảo vệ động vật rừng (Điều 24)",
        "Vận chuyển lâm sản trái pháp luật (Điều 25)",
        "Tàng trữ, mua bán, chế biến lâm sản trái pháp luật (Điều 26)",
        "Vi phạm quy định về phòng cháy và chữa cháy rừng (Điều 20)",
        "Vi phạm các quy định chung của Nhà nước về bảo vệ rừng (Điều 19)",
        "Phá hủy công trình bảo vệ và phát triển rừng (Điều 22)",
        "Khác"
    ]
    let landIncidents = [
        "Lấn đất hoặc chiếm đất (Điều 13)",
        "Hủy hoại đất (Điều 14)",
        "Cản trở, gây khó khăn cho việc sử dụng đất của người khác (Điều 15)",
        "Vi phạm quy định về quản lý mốc địa giới đơn vị hành chính (Điều 26)",
        "Khác"
    ]

    var body: some View {
        NavigationView {
            Form {
                // Section 1: Vị trí hiện trường (Header like Android)
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("VỊ TRÍ HIỆN TRƯỜNG")
                                .font(.system(size: 12, weight: .black))
                        }
                        .foregroundColor(.green)

                        Text("VN2000: X=1,321,450, Y=456,781")
                            .font(.headline)

                        HStack {
                            Text("±2.5m")
                                .padding(.horizontal, 8)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                            Text("H=1250m")
                            Spacer()
                            Text("18 SV")
                        }
                        .font(.caption.bold())
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("THÔNG TIN CHUNG").font(.caption.bold()).foregroundColor(.green)) {
                    Picker("Lĩnh vực vi phạm", selection: $violationField) {
                        ForEach(violationFields, id: \.self) { Text($0) }
                    }

                    Picker("Sự vụ phát hiện", selection: $incidentType) {
                        let list = (violationField == "Lâm nghiệp") ? forestryIncidents : landIncidents
                        ForEach(list, id: \.self) { Text($0) }
                    }

                    TextField("Cán bộ tổ trưởng", text: $leaderName)
                    DatePicker("Thời gian vi phạm", selection: $violationTime)
                    TextField("Địa điểm (Chi tiết lô/khoảnh)", text: $violationLocation)
                }

                Section(header: Text("ĐỐI TƯỢNG VI PHẠM").font(.caption.bold()).foregroundColor(.green)) {
                    TextField("Họ và tên", text: $violatorName)
                    TextField("Số CCCD/CMND", text: $violatorIdCard)
                    TextField("Số điện thoại", text: $violatorPhone)
                    TextField("Địa chỉ thường trú / tạm trú", text: $violatorAddress)
                }

                Section(header: Text("TANG VẬT & BIỆN PHÁP").font(.caption.bold()).foregroundColor(.green)) {
                    TextField("Tang vật, phương tiện tạm giữ", text: $confiscatedTools)
                    TextField("Cá nhân liên quan", text: $relatedPersons)
                    TextField("Biện pháp xử lý tại chỗ", text: $onSiteAction)
                    TextEditor(text: $onSiteRecordings)
                        .frame(height: 80)
                        .overlay(Text(onSiteRecordings.isEmpty ? "Ghi nhận hiện trường..." : "").foregroundColor(.gray).padding(8), alignment: .topLeading)
                    TextEditor(text: $notes)
                        .frame(height: 60)
                        .overlay(Text(notes.isEmpty ? "Ghi chú bổ sung..." : "").foregroundColor(.gray).padding(8), alignment: .topLeading)
                }

                Section {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("CHỤP ẢNH HIỆN TRƯỜNG")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Nhật ký sự vụ")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("LƯU MÁY") { presentationMode.wrappedValue.dismiss() }.font(.system(size: 12, weight: .bold)),
                trailing: Button(action: {}) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("BÁO CÁO")
                    }
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .cornerRadius(8)
                }
            )
        }
    }
}
