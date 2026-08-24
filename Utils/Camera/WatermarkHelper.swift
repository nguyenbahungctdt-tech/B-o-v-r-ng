import UIKit
import CoreGraphics

struct WatermarkSettings: Codable {
    var showInfo: Bool = true
    var position: String = "BOTTOM_LEFT"
    var showOfficer: Bool = true
    var showTime: Bool = true
    var showAddress: Bool = true
    var showWgs84: Bool = true
    var showVn2000: Bool = true
    var showAltitude: Bool = true
    var showAccuracy: Bool = true
    var labelColorHex: String = "#FFD700"
    var labelSize: CGFloat = 12
}

class WatermarkHelper {
    static let shared = WatermarkHelper()

    func drawWatermark(
        image: UIImage,
        userName: String,
        time: String,
        address: String,
        wgs84: String,
        vn2000: String,
        altitude: Double,
        accuracy: Double,
        settings: WatermarkSettings
    ) -> UIImage {
        guard settings.showInfo else { return image }

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)

        let result = renderer.image { context in
            // Draw original image
            image.draw(at: .zero)

            let width = image.size.width
            let height = image.size.height

            let margin = width / 40
            let baseFontSize = width / (40 - (settings.labelSize - 11))

            let paintColor = UIColor(hex: settings.labelColorHex) ?? .yellow

            // Build text blocks
            var lines: [NSAttributedString] = []

            if settings.showOfficer {
                lines.append(NSAttributedString(string: userName.uppercased(), attributes: [
                    .font: UIFont.boldSystemFont(ofSize: baseFontSize * 1.1),
                    .foregroundColor: UIColor(hex: "#4ADE80") ?? .green
                ]))
            }

            if settings.showTime {
                lines.append(createIconText(icon: "clock", text: time, size: baseFontSize, color: .white))
            }

            if settings.showAddress {
                lines.append(createIconText(icon: "mappin.and.ellipse", text: address, size: baseFontSize, color: .white))
            }

            if settings.showWgs84 {
                lines.append(createIconText(icon: "network", text: wgs84, size: baseFontSize, color: .white))
            }

            if settings.showVn2000 {
                lines.append(createIconText(icon: "number", text: vn2000, size: baseFontSize, color: paintColor))
            }

            if settings.showAccuracy || settings.showAltitude {
                var info = ""
                if settings.showAccuracy { info += "±\(String(format: "%.1f", accuracy))m " }
                if settings.showAltitude { info += "H: \(String(format: "%.0f", altitude))m" }
                lines.append(NSAttributedString(string: info, attributes: [
                    .font: UIFont.boldSystemFont(ofSize: baseFontSize),
                    .foregroundColor: paintColor
                ]))
            }

            // Footer
            lines.append(NSAttributedString(string: "Ứng dụng Bảo vệ rừng - Đại Thành", attributes: [
                .font: UIFont.systemFont(ofSize: baseFontSize * 0.8),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]))

            // Calculate box size
            let lineSpacing: CGFloat = 8
            var totalHeight: CGFloat = 0
            var maxWidth: CGFloat = 0
            for line in lines {
                let size = line.size()
                totalHeight += size.height + lineSpacing
                maxWidth = max(maxWidth, size.width)
            }

            let boxWidth = maxWidth + margin * 2
            let boxHeight = totalHeight + margin * 2

            // Background box
            let boxRect: CGRect
            switch settings.position {
            case "TOP_LEFT": boxRect = CGRect(x: margin, y: margin, width: boxWidth, height: boxHeight)
            case "TOP_RIGHT": boxRect = CGRect(x: width - boxWidth - margin, y: margin, width: boxWidth, height: boxHeight)
            case "BOTTOM_RIGHT": boxRect = CGRect(x: width - boxWidth - margin, y: height - boxHeight - margin, width: boxWidth, height: boxHeight)
            default: boxRect = CGRect(x: margin, y: height - boxHeight - margin, width: boxWidth, height: boxHeight)
            }

            context.cgContext.setFillColor(UIColor.black.withAlphaComponent(0.6).cgColor)
            context.cgContext.fill(boxRect)

            // Draw lines
            var currentY = boxRect.minY + margin
            for line in lines {
                line.draw(at: CGPoint(x: boxRect.minX + margin, y: currentY))
                currentY += line.size().height + lineSpacing
            }
        }

        return result
    }

    private func createIconText(icon: String, text: String, size: CGFloat, color: UIColor) -> NSAttributedString {
        let attachment = NSTextAttachment()
        if let image = UIImage(systemName: icon)?.withTintColor(color) {
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -size/4, width: size, height: size)
        }

        let attributedString = NSMutableAttributedString(attachment: attachment)
        attributedString.append(NSAttributedString(string: " " + text, attributes: [
            .font: UIFont.systemFont(ofSize: size),
            .foregroundColor: color
        ]))

        return attributedString
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.remove(at: cString.startIndex) }
        if cString.count != 6 && cString.count != 8 { return nil }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        if cString.count == 6 {
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.init(
                red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x000000FF) / 255.0,
                alpha: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            )
        }
    }
}
