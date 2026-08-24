import SwiftUI

struct DailyJournalFormView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var date = Date()
    @State private var content = ""
    @State private var notes = ""
    @State private var weather = ""
    @State private var patrolTeam = ""
    @State private var patrolCompartment = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Thông tin chung")) {
                    DatePicker("Ngày tuần tra", selection: $date, displayedComponents: .date)
                    TextField("Tiểu khu/Khoảnh", text: $patrolCompartment)
                    TextField("Tình hình thời tiết", text: $weather)
                }

                Section(header: Text("Đoàn tuần tra")) {
                    TextField("Thành phần tham gia", text: $patrolTeam)
                }

                Section(header: Text("Nội dung tuần tra")) {
                    TextEditor(text: $content)
                        .frame(height: 150)
                }

                Section(header: Text("Ghi chú thêm")) {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }

                Button(action: save) {
                    HStack {
                        Spacer()
                        Text("Lưu nhật ký tuần tra")
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(Color.blue)
            }
            .navigationTitle("Nhật ký tuần tra")
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
