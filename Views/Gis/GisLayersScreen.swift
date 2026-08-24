import SwiftUI

struct GisLayer: Identifiable {
    let id = UUID()
    var name: String
    var type: String
    var isVisible: Bool
    var opacity: Double
}

struct GisLayersScreen: View {
    @State private var layers = [
        GisLayer(name: "Hiện trạng rừng 2024", type: "TAB", isVisible: true, opacity: 0.8),
        GisLayer(name: "Quy hoạch 3 loại rừng", type: "SHP", isVisible: true, opacity: 0.6),
        GisLayer(name: "Lô rừng sản xuất", type: "KML", isVisible: false, opacity: 1.0)
    ]

    var body: some View {
        List {
            ForEach($layers) { $layer in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: layer.type == "MBTILES" ? "square.grid.2x2.fill" : "map.fill")
                            .foregroundColor(.green)

                        Text(layer.name)
                            .font(.headline)

                        Spacer()

                        Toggle("", isOn: $layer.isVisible)
                            .labelsHidden()
                    }

                    if layer.isVisible {
                        HStack {
                            Text("Độ mờ: \(Int(layer.opacity * 100))%")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Slider(value: $layer.opacity, in: 0...1)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .onDelete { indexSet in
                layers.remove(atOffsets: indexSet)
            }
            .onMove { from, to in
                layers.move(fromOffsets: from, toOffset: to)
            }
        }
        .navigationTitle("Lớp dữ liệu GIS")
        .toolbar {
            EditButton()
            Button(action: {}) {
                Image(systemName: "plus")
            }
        }
    }
}
