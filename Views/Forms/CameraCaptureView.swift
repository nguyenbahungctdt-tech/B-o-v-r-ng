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
    @Published var output = AVCapturePhotoOutput()
    @Published var preview = AVCaptureVideoPreviewLayer()
    @Published var capturedImage: UIImage?
    @Published var isSaved = false

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
        do {
            self.session.beginConfiguration()
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            if self.session.canAddInput(input) { self.session.addInput(input) }
            if self.session.canAddOutput(self.output) { self.session.addOutput(self.output) }
            self.session.commitConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }

    func toggleFlash() { isFlashOn.toggle() }

    func takePic() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        self.output.capturePhoto(with: settings, delegate: PhotoReceiver(parent: self))
    }
}

class PhotoReceiver: NSObject, AVCapturePhotoCaptureDelegate {
    var parent: CameraModel
    init(parent: CameraModel) { self.parent = parent }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { print(error.localizedDescription); return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        if let image = UIImage(data: imageData) {
            // Apply Watermark
            let watermarked = WatermarkHelper.shared.drawWatermark(
                image: image,
                userName: "Nguyen Van A",
                time: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium),
                address: "Dang xac dinh...",
                wgs84: "11.9404, 108.4378",
                vn2000: "X: 1321450, Y: 456781",
                altitude: 1250,
                accuracy: 2.5,
                settings: WatermarkSettings()
            )
            DispatchQueue.main.async {
                self.parent.capturedImage = watermarked
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.preview.session = camera.session
        camera.preview.videoGravity = .resizeAspectFill
        camera.preview.frame = view.frame
        view.layer.addSublayer(camera.preview)

        DispatchQueue.global(qos: .background).async {
            camera.session.startRunning()
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
