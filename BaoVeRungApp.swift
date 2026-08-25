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
    @State private var isLoggedIn = false // State management like Android

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainContainerView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
        }
        .accentColor(Color(red: 46/255, green: 125/255, blue: 50/255)) // Green forestry color
    }
}

struct MapView: View {
    @State private var azimuth: Double = 0.0
    @State private var isLeftExpanded = true
    @State private var isRightExpanded = true
    @State private var showMapSource = false
    @State private var showCoordConverter = false
    @State private var showCamera = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                MapLibreView()
                    .edgesIgnoringSafeArea(.all)

                // 1. LEFT SIDEBAR (Utilities)
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: { isLeftExpanded.toggle() }) {
                        Image(systemName: isLeftExpanded ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.4).clipShape(Circle()))
                    }

                    if isLeftExpanded {
                        VStack(spacing: 12) {
                            Button(action: { showMapSource = true }) {
                                Image(systemName: "layers.fill")
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                            }

                            Button(action: {}) {
                                Image(systemName: "map.fill")
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                            }

                            Button(action: { showCoordConverter = true }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                            }

                            Button(action: {}) {
                                Image(systemName: "icloud.and.arrow.down.fill")
                                    .padding(10)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                            }
                        }
                        .transition(.move(edge: .leading))
                    }
                }
                .padding(.leading, 12)
                .padding(.top, 60)
                .frame(maxWidth: .infinity, alignment: .topLeading)

                // 2. RIGHT SIDEBAR (Zoom & GPS)
                VStack(alignment: .trailing, spacing: 10) {
                    Button(action: { isRightExpanded.toggle() }) {
                        Image(systemName: isRightExpanded ? "chevron.right.circle.fill" : "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.4).clipShape(Circle()))
                    }

                    if isRightExpanded {
                        VStack(spacing: 12) {
                            CompassView(azimuth: azimuth)

                            VStack(spacing: 1) {
                                Button(action: {}) {
                                    Image(systemName: "plus")
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                }
                                Divider().frame(width: 40)
                                Button(action: {}) {
                                    Image(systemName: "minus")
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 2)

                            Button(action: {}) {
                                Image(systemName: "location.fill")
                                    .frame(width: 40, height: 40)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                            }
                        }
                        .transition(.move(edge: .trailing))
                    }
                }
                .padding(.trailing, 12)
                .padding(.top, 60)

                // 3. TOP LEFT COORDINATE INFO (VN2000)
                VStack(alignment: .leading, spacing: 2) {
                    Text("VN2000 (Lâm Đồng)")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(4)

                    Group {
                        Text("X: 1,321,450.2")
                        Text("Y: 456,780.8")
                    }
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.yellow)
                    .shadow(color: .black, radius: 1)

                    HStack(spacing: 8) {
                        Text("±2.5m")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 4)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(2)
                        Text("Cao: 1250m")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1)
                    }
                }
                .padding(.leading, 12)
                .padding(.top, 240) // Below left sidebar
                .frame(maxWidth: .infinity, alignment: .topLeading)

                // 4. BOTTOM FLOATING ACTION BUTTON (SURVEY)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.green)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }

                // 5. BOTTOM SATELLITE STATUS BAR
                VStack {
                    Spacer()
                    SatelliteInfoView(satellitesVisible: 18, satellitesUsed: 12, accuracy: 2.5, altitude: 1250)
                }
            }
            .navigationTitle("Bản đồ Lâm nghiệp")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: { showCamera = true }) {
                Image(systemName: "camera.fill")
                    .foregroundColor(.white)
            })
            // Support iOS 15.5+ by removing iOS 16 specific modifiers or using availability
            .actionSheet(isPresented: $showMapSource) {
                ActionSheet(title: Text("Chọn lớp nền"), buttons: [
                    .default(Text("Google Satellite")),
                    .default(Text("Google Hybrid")),
                    .default(Text("Esri World Imagery")),
                    .default(Text("Google Terrain")),
                    .default(Text("OpenStreetMap")),
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
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            SettingsScreen()
        }
    }
}
