import SwiftUI
import AVFoundation

struct CameraCaptureView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var camera = CameraModel()

    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)

            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: { camera.toggleFlash() }) {
                        Image(systemName: camera.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .foregroundColor(camera.isFlashOn ? .yellow : .white)
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                .padding()

                Spacer()

                // Watermark Preview Overlay
                VStack(alignment: .leading, spacing: 2) {
                    Text("NGUYÊN VĂN A")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    Text(Date(), style: .date)
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                    Text("VN2000: X=1,321,450, Y=456,781")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.yellow)
                }
                .padding(8)
                .background(Color.black.opacity(0.5))
                .cornerRadius(4)
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .padding()

                HStack {
                    Spacer()
                    Button(action: { camera.takePic() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 80, height: 80)
                        }
                    }
                    Spacer()
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
    }
}

class CameraModel: ObservableObject {
    @Published var isFlashOn = false
    @Published var session = AVCaptureSession()

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success { self.setup() }
            }
        default: break
        }
    }

    func setup() {
        // Basic camera setup logic
    }

    func toggleFlash() { isFlashOn.toggle() }
    func takePic() { /* Capture logic */ }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        // Link AVCaptureVideoPreviewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
