import SwiftUI
import UniformTypeIdentifiers

enum GisImportType: String, CaseIterable {
    case mbtiles = "MBTILES"
    case kml = "KML"
    case shp = "SHP"
    case tab = "TAB"
    case geojson = "GEOJSON"
    case raster = "RASTER"

    var displayName: String {
        switch self {
        case .mbtiles: return "Nền (MBTiles)"
        case .kml: return "Google Earth (KML)"
        case .shp: return "QGis (SHP)"
        case .tab: return "Mapinfo (TAB)"
        case .geojson: return "GeoJSON"
        case .raster: return "Ảnh (TIFF, JPG)"
        }
    }
}

struct GisLayerItem: Identifiable {
    let id = UUID()
    var name: String
    var type: String
    var path: String
    var isVisible: Bool
    var opacity: Double
}

struct GisLayersScreen: View {
    @State private var selectedCategory: GisImportType? = nil
    @State private var scannedFiles: [URL] = []
    @State private var layers: [GisLayerItem] = [
        GisLayerItem(name: "Bản đồ Quy hoạch SDD", type: "MBTILES", path: "default_map_SDD.mbtiles", isVisible: true, opacity: 1.0),
        GisLayerItem(name: "Bản đồ Hiện trạng rừng 2025", type: "MBTILES", path: "default_map_Kk2025.mbtiles", isVisible: true, opacity: 0.8)
    ]
    @State private var showFilePicker = false

    var body: some View {
        VStack(spacing: 0) {
            // 1. Horizontal Category Selector (6 Tabs)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(GisImportType.allCases, id: \.self) { type in
                        FilterChip(title: type.displayName, isSelected: selectedCategory == type) {
                            selectedCategory = (selectedCategory == type) ? nil : type
                            if let cat = selectedCategory {
                                scanForFiles(type: cat)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.white)

            // 2. Scanned Results / File Picker
            if let cat = selectedCategory {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("TỆP ĐÃ TÌM THẤY (\(scannedFiles.count))")
                            .font(.system(size: 12, weight: .black))
                        Spacer()
                        Button(action: { showFilePicker = true }) {
                            Label("Chọn tệp thủ công...", systemImage: "plus.circle.fill")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                    .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 0) {
                            if scannedFiles.isEmpty {
                                Text("Không tìm thấy tệp \(cat.rawValue) trong máy.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(scannedFiles, id: \.self) { url in
                                    FileRow(url: url) {
                                        addLayer(from: url, type: cat)
                                        selectedCategory = nil
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // 3. Active Layer List
            List {
                Section(header: Text("DANH SÁCH LỚP ĐANG MỞ").font(.system(size: 12, weight: .black)).foregroundColor(.green)) {
                    ForEach($layers) { $layer in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: layer.type == "MBTILES" ? "square.grid.2x2.fill" : "map.fill")
                                    .foregroundColor(.green)

                                VStack(alignment: .leading) {
                                    Text(layer.name)
                                        .font(.system(size: 15, weight: .bold))
                                    Text("\(layer.type) | Nhãn: Tắt")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                HStack(spacing: 15) {
                                    Image(systemName: "trash").foregroundColor(.red)
                                    Image(systemName: "scope").foregroundColor(.green)
                                    Image(systemName: "chevron.up")
                                    Image(systemName: "chevron.down")
                                    Toggle("", isOn: $layer.isVisible).labelsHidden()
                                }
                                .font(.system(size: 14))
                            }

                            if layer.isVisible {
                                HStack {
                                    Text("Độ mờ: \(Int(layer.opacity * 100))%")
                                        .font(.system(size: 10, weight: .bold))
                                        .frame(width: 80, alignment: .leading)
                                    Slider(value: $layer.opacity, in: 0...1)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete { layers.remove(atOffsets: $0) }
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("QUẢN LÝ LỚP BẢN ĐỒ (GIS)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilePicker) {
            DocumentPicker { url in
                addLayer(from: url, type: selectedCategory ?? .mbtiles)
            }
        }
    }

    private func scanForFiles(type: GisImportType) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exts = getExtensions(for: type)
        do {
            let files = try FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)
            scannedFiles = files.filter { url in
                exts.contains(url.pathExtension.lowercased())
            }
        } catch {
            print("Scan error: \(error)")
        }
    }

    private func getExtensions(for type: GisImportType) -> [String] {
        switch type {
        case .mbtiles: return ["mbtiles", "sqlite"]
        case .kml: return ["kml", "kmz"]
        case .shp: return ["shp"]
        case .tab: return ["tab", "mif"]
        case .geojson: return ["geojson", "json"]
        case .raster: return ["tif", "tiff", "jpg", "jpeg", "png"]
        }
    }

    private func addLayer(from url: URL, type: GisImportType) {
        let name = url.deletingPathExtension().lastPathComponent
        // Logic to verify sidecar files for SHP/TAB
        if type == .shp {
            // Check for .dbf, .shx, .prj
            let base = url.deletingPathExtension()
            let required = ["dbf", "shx", "prj"]
            for ext in required {
                let sidecar = base.appendingPathExtension(ext)
                if !FileManager.default.fileExists(atPath: sidecar.path) {
                    print("Missing sidecar file: .\(ext)")
                }
            }
        }

        let newLayer = GisLayerItem(name: name, type: type.rawValue, path: url.path, isVisible: true, opacity: 1.0)
        layers.insert(newLayer, at: 0)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(isSelected ? Color.green : Color.gray.opacity(0.2), lineWidth: 1))
        }
    }
}

struct FileRow: View {
    let url: URL
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text(url.lastPathComponent)
                        .font(.system(size: 13, weight: .bold))
                    Text(url.path)
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first { parent.onPick(url) }
        }
    }
}
