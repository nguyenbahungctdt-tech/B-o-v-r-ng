import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Safe initialization: Only configure if the REAL plist exists and is valid
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
       let dict = NSDictionary(contentsOfFile: path),
       let projectID = dict["PROJECT_ID"] as? String,
       !projectID.contains("baoverung-xxxx") { // Check if it's not my dummy ID
        FirebaseApp.configure()
        print("Firebase configured successfully.")
    } else {
        print("Skipping Firebase configuration: Valid GoogleService-Info.plist not found.")
    }
    return true
  }
}

@main
struct BaoVeRungApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    @StateObject var locationManager = LocationManager()
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainContainerView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(locationManager)
            } else {
                LoginView(onLoginSuccess: {
                    isLoggedIn = true
                })
            }
        }
    }
}

struct MainContainerView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Label("BẢN ĐỒ", systemImage: "map.fill")
                }
                .tag(0)

            GisLayersScreen()
                .tabItem {
                    Label("LỚP GIS", systemImage: "layers.fill")
                }
                .tag(1)

            DataManagementView()
                .tabItem {
                    Label("DỮ LIỆU", systemImage: "folder.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("CÀI ĐẶT", systemImage: "gearshape.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("HỒ SƠ", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .accentColor(Color(red: 46/255, green: 125/255, blue: 50/255))
    }
}

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var azimuth: Double = 0.0
    @State private var isLeftExpanded = true
    @State private var isRightExpanded = true
    @State private var showMapSource = false
    @State private var showCoordConverter = false
    @State private var showCamera = false
    @State private var isCoordInfoExpanded = true

    @State private var mapCenter: CLLocationCoordinate2D?
    @State private var zoomLevel: Double = 14.0
    @State private var styleURL: String = "https://demotiles.maplibre.org/style.json"

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                MapLibreView(centerCoordinate: $mapCenter, zoomLevel: $zoomLevel, styleURL: $styleURL)
                    .edgesIgnoringSafeArea(.all)

                // 1. TOP STATUS BAR
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Vệ tinh: 15/27")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(20)

                        HStack(spacing: 4) {
                            Image(systemName: "scope")
                            let acc = locationManager.location?.horizontalAccuracy ?? 0
                            Text("Sai số: ±\(String(format: "%.1f", acc))m")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(accColor)
                        .cornerRadius(20)

                        Spacer()

                        Image(systemName: "cloud.fill")
                            .foregroundColor(.orange)
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.top, 50)

                    Spacer()
                }

                // 2. LEFT SIDEBAR
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: { isLeftExpanded.toggle() }) {
                        Image(systemName: isLeftExpanded ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3).clipShape(Circle()))
                    }

                    if isLeftExpanded {
                        VStack(spacing: 12) {
                            SidebarButton(icon: "arrow.left")
                            SidebarButton(icon: "layers.fill", action: { showMapSource = true })
                            SidebarButton(icon: "map.fill")
                            SidebarButton(icon: "arrow.triangle.2.circlepath", action: { showCoordConverter = true })
                            SidebarButton(icon: "icloud.and.arrow.down.fill")
                        }
                        .transition(.move(edge: .leading))
                    }
                }
                .padding(.leading, 12)
                .padding(.top, 95)
                .frame(maxWidth: .infinity, alignment: .topLeading)

                // 3. RIGHT SIDEBAR
                VStack(alignment: .trailing, spacing: 10) {
                    Button(action: { isRightExpanded.toggle() }) {
                        Image(systemName: isRightExpanded ? "chevron.right.circle.fill" : "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3).clipShape(Circle()))
                    }

                    if isRightExpanded {
                        VStack(spacing: 12) {
                            SidebarButton(icon: "chevron.right")
                            SidebarButton(icon: "plus", action: { zoomLevel = min(zoomLevel + 1, 20) })
                            SidebarButton(icon: "minus", action: { zoomLevel = max(zoomLevel - 1, 1) })

                            ZStack(alignment: .topTrailing) {
                                SidebarButton(icon: "safari.fill", color: .orange)
                                Text("27/15")
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(3)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 5, y: -5)
                            }

                            SidebarButton(icon: "arrow.up", action: { azimuth = 0 })
                            SidebarButton(icon: "scope", color: .green, action: {
                                if let loc = locationManager.location {
                                    mapCenter = loc.coordinate
                                }
                            })
                        }
                        .transition(.move(edge: .trailing))
                    }
                }
                .padding(.trailing, 12)
                .padding(.top, 95)

                // 4. BOTTOM INFO CARD
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("VN2000 / TM-3 kinh tuyến trục 107.75 + Lâm Đồng")
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                            Spacer()
                            Image(systemName: isCoordInfoExpanded ? "chevron.up" : "chevron.down")
                        }
                        .onTapGesture { isCoordInfoExpanded.toggle() }

                        if isCoordInfoExpanded {
                            let loc = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                            let vn = CoordinateConverter.shared.wgs84ToVn2000(lat: loc.latitude, lon: loc.longitude, cm: 107.75, zd: 3)

                            Text("X: \(String(format: "%.1f", vn.x))  Y: \(String(format: "%.1f", vn.y))")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.black)

                            Text("Vị trí WGS84: \(String(format: "%.6f", loc.latitude)), \(String(format: "%.6f", loc.longitude))")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))

                            Text("Tâm X: \(String(format: "%.1f", vn.x))  Y: \(String(format: "%.1f", vn.y))")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)

                            HStack(spacing: 15) {
                                let acc = locationManager.location?.horizontalAccuracy ?? 0
                                Text("±\(String(format: "%.1f", acc))m")
                                    .font(.system(size: 10, weight: .black))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(accColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)

                                Text("Cao: \(String(format: "%.1f", locationManager.location?.altitude ?? 0))m")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)

                                Text("Zoom: \(String(format: "%.1f", zoomLevel))")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(red: 102/255, green: 153/255, blue: 102/255))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                }

                // 5. FAB (+)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color(red: 46/255, green: 125/255, blue: 50/255))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .actionSheet(isPresented: $showMapSource) {
                ActionSheet(title: Text("Chọn lớp nền"), buttons: [
                    .default(Text("Google Satellite")) { styleURL = "https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}" },
                    .default(Text("Google Hybrid")) { styleURL = "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}" },
                    .default(Text("Esri World Imagery")) { styleURL = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}" },
                    .default(Text("OpenStreetMap")) { styleURL = "https://tile.openstreetmap.org/{z}/{x}/{y}.png" },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showCoordConverter) {
                CoordinateConverterView()
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraCaptureView()
            }
        }
    }

    private var accColor: Color {
        let acc = locationManager.location?.horizontalAccuracy ?? 100
        return acc < 15 ? .green : (acc < 50 ? .orange : .red)
    }
}

struct SidebarButton: View {
    let icon: String
    var color: Color = .black
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .frame(width: 42, height: 42)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.1), radius: 2)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            SettingsScreen()
        }
    }
}
