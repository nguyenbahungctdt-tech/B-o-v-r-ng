import SwiftUI

struct SatelliteInfoView: View {
    var satellitesVisible: Int = 0
    var satellitesUsed: Int = 0
    var accuracy: Double = 0.0
    var altitude: Double = 0.0

    var statusColor: Color {
        if accuracy <= 5.0 { return .green }
        if accuracy <= 15.0 { return .orange }
        return .red
    }

    var body: some View {
        HStack(spacing: 15) {
            HStack(spacing: 4) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.blue)
                Text("Vệ tinh: \(satellitesUsed)/\(satellitesVisible)")
            }

            HStack(spacing: 4) {
                Image(systemName: accuracy > 15 ? "exclamationmark.triangle.fill" : "scope")
                    .foregroundColor(statusColor)
                Text(String(format: "Sai số: ±%.1fm", accuracy))
                    .foregroundColor(statusColor)
            }

            HStack(spacing: 4) {
                Image(systemName: "mountain.2.fill")
                    .foregroundColor(.green)
                Text(String(format: "Cao: %.0fm", altitude))
            }

            Spacer()

            Image(systemName: "icloud.circle.fill")
                .foregroundColor(.green)
        }
        .font(.system(size: 11, weight: .black))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.95))
        .cornerRadius(12, corners: [.topLeft, .topRight])
        .shadow(radius: 2)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct CompassView: View {
    var azimuth: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 50, height: 50)
                .shadow(radius: 2)

            Image(systemName: "location.north.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.red)
                .rotationEffect(.degrees(-azimuth))
        }
    }
}
