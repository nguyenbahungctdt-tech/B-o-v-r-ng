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
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
