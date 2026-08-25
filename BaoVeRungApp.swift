import SwiftUI
import FirebaseCore
import CoreLocation

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
    @StateObject var preferences = UserPreferences.shared
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainContainerView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(locationManager)
                    .environmentObject(preferences)
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
    @EnvironmentObject var preferences: UserPreferences
    @State private var azimuth: Double = 0.0
    @State private var isLeftExpanded = true
    @State private var isRightExpanded = true
    @State private var isJournalExpanded = true
    @State private var showMapSource = false
    @State private var showCoordConverter = false
    @State private var showCamera = false
    @State private var isCoordInfoExpanded = true
    @State private var isFABMenuExpanded = false
    @State private var showAddWaypoint = false

    @State private var mapCenter: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 11.9404, longitude: 108.4378)
    @State private var jumpToCoordinate: CLLocationCoordinate2D?
    @State private var zoomLevel: Double = 14.0
    @State private var styleURL: String = "https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}"

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                MapLibreView(centerCoordinate: $jumpToCoordinate, mapCenter: $mapCenter, zoomLevel: $zoomLevel, styleURL: $styleURL)
                    .edgesIgnoringSafeArea(.all)

                // 1. TOP STATUS BAR (Vệ tinh, Sai số, Đám mây)
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

                // 2. LEFT SIDEBAR (Utilities & Journals)
                VStack(alignment: .leading, spacing: 15) {
                    // Utility Group
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: { isLeftExpanded.toggle() }) {
                            Image(systemName: isLeftExpanded ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.3).clipShape(Circle()))
                        }

                        if isLeftExpanded {
                            VStack(spacing: 12) {
                                SidebarButton(icon: "chevron.left") // Back
                                SidebarButton(icon: "layers.fill", action: { showMapSource = true })
                                SidebarButton(icon: "map.fill")
                                SidebarButton(icon: "arrow.triangle.2.circlepath", action: { showCoordConverter = true })
                                SidebarButton(icon: "icloud.and.arrow.down.fill")
                            }
                            .transition(.move(edge: .leading))
                        }
                    }

                    // Journal Shortcuts
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: { isJournalExpanded.toggle() }) {
                            Image(systemName: isJournalExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.3).clipShape(Circle()))
                        }

                        if isJournalExpanded {
                            VStack(spacing: 12) {
                                SidebarButton(icon: "calendar", color: .blue) // Hằng ngày
                                SidebarButton(icon: "doc.text.fill", color: .red) // Sự vụ
                                SidebarButton(icon: "leaf.fill", color: .green) // Động thực vật
                                SidebarButton(icon: "exclamationmark.triangle.fill", color: .orange) // Tác động TN
                            }
                            .transition(.move(edge: .leading))
                        }
                    }
                }
                .padding(.leading, 12)
                .padding(.top, 95)
                .frame(maxWidth: .infinity, alignment: .topLeading)

                // 3. RIGHT SIDEBAR (Controls)
                VStack(alignment: .trailing, spacing: 10) {
                    Button(action: { isRightExpanded.toggle() }) {
                        Image(systemName: isRightExpanded ? "chevron.right.circle.fill" : "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3).clipShape(Circle()))
                    }

                    if isRightExpanded {
                        VStack(spacing: 12) {
                            SidebarButton(icon: "gearshape.fill")
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
                                    jumpToCoordinate = loc.coordinate
                                }
                            })
                        }
                        .transition(.move(edge: .trailing))
                    }
                }
                .padding(.trailing, 12)
                .padding(.top, 95)

                // 4. BOTTOM INFO CARD (7 Lines)
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            let sys = CoordinateConverter.shared.systems.first { $0.id == preferences.activeCoordSystemId } ?? CoordinateConverter.shared.systems[0]
                            Text(sys.name)
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))
                            Spacer()
                            Image(systemName: isCoordInfoExpanded ? "chevron.down" : "chevron.up")
                        }
                        .onTapGesture { withAnimation { isCoordInfoExpanded.toggle() } }

                        if isCoordInfoExpanded {
                            let loc = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                            let currentVn = CoordinateConverter.shared.wgs84ToVn2000(lat: loc.latitude, lon: loc.longitude, cm: preferences.vn2000CentralMeridian, zd: preferences.vn2000ZoneDegrees)

                            let center = mapCenter ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                            let centerVn = CoordinateConverter.shared.wgs84ToVn2000(lat: center.latitude, lon: center.longitude, cm: preferences.vn2000CentralMeridian, zd: preferences.vn2000ZoneDegrees)

                            Text("X: \(String(format: "%.1f", currentVn.x))  Y: \(String(format: "%.1f", currentVn.y))")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.black)

                            Text("Vị trí WGS84: \(String(format: "%.6f", loc.latitude)), \(String(format: "%.6f", loc.longitude))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))

                            Text("Tâm X: \(String(format: "%.1f", centerVn.x))  Y: \(String(format: "%.1f", centerVn.y))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.gray)

                            HStack(spacing: 12) {
                                let acc = locationManager.location?.horizontalAccuracy ?? 0
                                Text("±\(String(format: "%.1f", acc))m")
                                    .font(.system(size: 9, weight: .black))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(accColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)

                                let alt = locationManager.location?.altitude ?? 0
                                let vAcc = locationManager.location?.verticalAccuracy ?? 0
                                Text("Cao: \(String(format: "%.1f", alt))m (±\(String(format: "%.0f", vAcc))m)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)

                                Text("Zoom: \(String(format: "%.1f", zoomLevel))")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 102/255, green: 153/255, blue: 102/255))
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(18)
                    .shadow(radius: 5)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 25)
                }

                // 5. FAB MENU (+)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 0) {
                            if isFABMenuExpanded {
                                VStack(spacing: 20) {
                                    FABMenuItem(icon: "ruler", text: "Đo khoảng cách", color: .blue)
                                    FABMenuItem(icon: "ruler.fill", text: "Đo diện tích", color: .green)
                                    FABMenuItem(icon: "camera.fill", text: "Chụp ảnh", color: .orange, action: { showCamera = true })
                                    FABMenuItem(icon: "record.circle", text: "Ghi Tracklog", color: .red)
                                    FABMenuItem(icon: "mappin.and.ellipse", text: "Thêm điểm", color: .purple, action: { showAddWaypoint = true })
                                }
                                .padding(.bottom, 15)
                            }

                            Button(action: { withAnimation { isFABMenuExpanded.toggle() } }) {
                                Image(systemName: isFABMenuExpanded ? "xmark" : "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color(red: 46/255, green: 125/255, blue: 50/255))
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 110)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddWaypoint) {
                AddWaypointView(currentGPS: locationManager.location?.coordinate, mapCenter: mapCenter)
            }
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

struct FABMenuItem: View {
    let icon: String
    let text: String
    let color: Color
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 2)

            Button(action: { action?() }) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 45, height: 45)
                    .background(color)
                    .clipShape(Circle())
                    .shadow(radius: 3)
            }
        }
        .transition(.scale.combined(with: .opacity))
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
