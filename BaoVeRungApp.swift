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
    @State private var azimuth: Double = 0.0
    @State private var isLeftExpanded = true
    @State private var isRightExpanded = true
    @State private var showMapSource = false
    @State private var showCoordConverter = false
    @State private var showCamera = false
    @State private var isCoordInfoExpanded = true

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                MapLibreView()
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
                            Text("Sai số: ±14,0m")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.6))
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

                // 2. LEFT SIDEBAR (Mũi tên Back, Lớp, Nguồn, Đồng bộ, Tải)
                VStack(alignment: .leading, spacing: 10) {
                    Button(action: { isLeftExpanded.toggle() }) {
                        Image(systemName: isLeftExpanded ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3).clipShape(Circle()))
                    }

                    if isLeftExpanded {
                        VStack(spacing: 12) {
                            SidebarButton(icon: "arrow.left") // Back to Main
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

                // 3. RIGHT SIDEBAR (Cài đặt, Đo đạc, Zoom, La bàn, Định vị)
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
                            SidebarButton(icon: "plus")
                            SidebarButton(icon: "minus")

                            // Compass Button with SV count circle
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

                            SidebarButton(icon: "arrow.up")
                            SidebarButton(icon: "scope", color: .green)
                        }
                        .transition(.move(edge: .trailing))
                    }
                }
                .padding(.trailing, 12)
                .padding(.top, 95)

                // 4. BOTTOM INFO CARD (Hệ tọa độ & Tọa độ 7 dòng)
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
                            Text("X: 485462,0  Y: 1377310,0")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.black)

                            Text("Vị trí WGS84: 12,454235, 107,618052")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 46/255, green: 125/255, blue: 50/255))

                            Text("Tâm X: 485304,1  Y: 1380235,9")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)

                            HStack(spacing: 15) {
                                Text("±14,0m")
                                    .font(.system(size: 10, weight: .black))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(4)

                                Text("Cao: 733,0m")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)

                                Text("Zoom: 14,2")
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
                        .padding(.bottom, 100) // Above Tab Bar
                    }
                }
            }
            .navigationBarHidden(true)
            .actionSheet(isPresented: $showMapSource) {
                ActionSheet(title: Text("Chọn lớp nền"), buttons: [
                    .default(Text("Google Satellite")),
                    .default(Text("Google Hybrid")),
                    .default(Text("Esri World Imagery")),
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
