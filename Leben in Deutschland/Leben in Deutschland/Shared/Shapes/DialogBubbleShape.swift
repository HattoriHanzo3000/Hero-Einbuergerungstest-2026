import SwiftUI

// MARK: - Dialog Bubble Shape (left tail)
struct DialogBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let cornerRadius: CGFloat = 16
        let tailWidth: CGFloat = 12
        let tailHeight: CGFloat = 8
        let tailPosition: CGFloat = height * 0.33 // tail at 1/3 height

        // Start at top-left corner (after tail offset)
        path.move(to: CGPoint(x: tailWidth + cornerRadius, y: 0))

        // Top edge to top-right corner
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: width - cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)

        // Right edge to bottom-right corner
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        path.addArc(center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)

        // Bottom edge to bottom-left (before tail)
        path.addLine(to: CGPoint(x: tailWidth + cornerRadius, y: height))
        path.addArc(center: CGPoint(x: tailWidth + cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)

        // Left edge with tail
        path.addLine(to: CGPoint(x: tailWidth, y: tailPosition + tailHeight))
        path.addLine(to: CGPoint(x: tailWidth/2, y: tailPosition + tailHeight/2))
        path.addLine(to: CGPoint(x: 0, y: tailPosition))
        path.addLine(to: CGPoint(x: tailWidth/2, y: tailPosition - tailHeight/2))
        path.addLine(to: CGPoint(x: tailWidth, y: tailPosition - tailHeight))
        path.addLine(to: CGPoint(x: tailWidth, y: cornerRadius))
        path.addArc(center: CGPoint(x: tailWidth + cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)

        path.closeSubpath()
        return path
    }
}


