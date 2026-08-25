import SwiftUI

struct ForestryIcon: View {
    let type: String
    let color: Color
    let size: CGFloat

    var body: some View {
        switch type {
        case "notebook":
            Image(systemName: "book.closed.fill")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(color)
        case "tree":
            Image(systemName: "leaf.fill")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(color)
        default:
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(color)
        }
    }
}

struct CompassView: View {
    let azimuth: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 40, height: 40)

            Image(systemName: "arrow.up")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.red)
                .rotationEffect(.degrees(azimuth))
        }
        .background(Color.white)
        .clipShape(Circle())
        .shadow(radius: 2)
    }
}
