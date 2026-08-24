import SwiftUI

struct NaturalImpactFormView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var cause = "Cháy rừng"
    @State private var otherCause = ""
    @State private var affectedArea = ""
    @State private var statusBefore = ""
    @State private var statusAfter = ""
    @State private var damage = ""
    @State private var occurrenceTime = Date()

    let causes = ["Cháy rừng", "Sạt lở đất", "Lũ lụt", "Sâu bệnh hại", "Khác"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nguyên nhân & Thời gian")) {
                    Picker("Nguyên nhân", selection: $cause) {
                        ForEach(causes, id: \.self) { c in
                            Text(c)
                        }
                    }
                    if cause == "Khác" {
                        TextField("Nguyên nhân khác", text: $otherCause)
                    }
                    DatePicker("Thời gian xảy ra", selection: $occurrenceTime)
                }

                Section(header: Text("Mức độ ảnh hưởng")) {
                    TextField("Diện tích ảnh hưởng (ha)", text: $affectedArea)
                        .keyboardType(.decimalPad)
                    TextField("Hiện trạng trước tác động", text: $statusBefore)
                    TextField("Hiện trạng sau tác động", text: $statusAfter)
                }

                Section(header: Text("Thiệt hại tài nguyên")) {
                    TextEditor(text: $damage)
                        .frame(height: 100)
                }

                Button(action: save) {
                    HStack {
                        Spacer()
                        Text("Lưu báo cáo tác động")
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(Color.orange)
            }
            .navigationTitle("Tác động tự nhiên")
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
