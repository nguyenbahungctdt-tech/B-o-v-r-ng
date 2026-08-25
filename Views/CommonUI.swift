import SwiftUI

struct ForestryIcon: View {
    let type: String
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            switch type {
            case "tree":
                TreeShape()
                    .fill(color)
                    .frame(width: size, height: size)
            case "notebook":
                NotebookShape()
                    .fill(color)
                    .frame(width: size * 0.8, height: size)
            case "flag":
                FlagShape()
                    .fill(color)
                    .frame(width: size, height: size)
            case "alert":
                TriangleAlertShape()
                    .fill(color)
                    .frame(width: size, height: size)
            case "camera":
                Image(systemName: "camera.fill")
                    .resizable()
                    .frame(width: size, height: size * 0.8)
                    .foregroundColor(color)
            default:
                Circle()
                    .fill(color)
                    .frame(width: size * 0.6, height: size * 0.6)
            }
        }
    }
}

struct TreeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let h = rect.height
        let w = rect.width
        path.addRect(CGRect(x: w * 0.45, y: h * 0.7, width: w * 0.1, height: h * 0.2))
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.3))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.3))
        path.closeSubpath()
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.2))
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.55))
        path.closeSubpath()
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.45))
        path.addLine(to: CGPoint(x: 0, y: h * 0.8))
        path.addLine(to: CGPoint(x: w, y: h * 0.8))
        path.closeSubpath()
        return path
    }
}

struct NotebookShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let h = rect.height
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 4, height: 4))
        for i in 0..<4 {
            let y = h * 0.2 + CGFloat(i) * h * 0.2
            path.addEllipse(in: CGRect(x: 4, y: y, width: 3, height: 3))
        }
        return path
    }
}

struct FlagShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let h = rect.height
        let w = rect.width
        path.addRect(CGRect(x: w * 0.2, y: 0, width: 2, height: h))
        path.move(to: CGPoint(x: w * 0.2, y: h * 0.1))
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.3))
        path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.5))
        path.closeSubpath()
        return path
    }
}

struct TriangleAlertShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let h = rect.height
        let w = rect.width
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
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
