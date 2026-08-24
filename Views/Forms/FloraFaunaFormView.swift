import SwiftUI

struct FloraFaunaFormView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var appearanceDescription = ""
    @State private var features = ""
    @State private var count = ""
    @State private var habitatType = "Rừng tự nhiên"
    @State private var temperature = ""
    @State private var humidity = ""
    @State private var specimens = ""
    @State private var notes = ""

    let habitats = ["Rừng tự nhiên", "Rừng trồng", "Tràng cỏ, cây bụi", "Đất nông nghiệp", "Khu dân cư"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mô tả đối tượng")) {
                    TextField("Tên/Mô tả loài", text: $appearanceDescription)
                    TextField("Đặc điểm nhận dạng", text: $features)
                    TextField("Số lượng/Mật độ", text: $count)
                }

                Section(header: Text("Môi trường sống")) {
                    Picker("Loại sinh cảnh", selection: $habitatType) {
                        ForEach(habitats, id: \.self) { h in
                            Text(h)
                        }
                    }
                    HStack {
                        TextField("Nhiệt độ (°C)", text: $temperature)
                            .keyboardType(.decimalPad)
                        TextField("Độ ẩm (%)", text: $humidity)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Ghi nhận khác")) {
                    TextField("Mẫu vật thu thập", text: $specimens)
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }

                Button(action: save) {
                    HStack {
                        Spacer()
                        Text("Lưu ghi nhận Động thực vật")
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(Color.green)
            }
            .navigationTitle("Động thực vật rừng")
            .navigationBarItems(leading: Button("Hủy") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func save() {
        // CoreData saving logic
        presentationMode.wrappedValue.dismiss()
    }
}
