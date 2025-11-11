//
//  SpeechBubbleShape.swift
//  Leben in Deutschland
//
//  Rounded speech bubble with curved tail.
//

import SwiftUI

struct SpeechBubbleShape: InsettableShape {
    var cornerRadius: CGFloat
    var tailSize: CGSize
    var tailCurveRadius: CGFloat
    var tailOffset: CGFloat
    var mirrorHorizontally: Bool
    private var insetAmount: CGFloat = 0
    
    init(
        cornerRadius: CGFloat,
        tailSize: CGSize,
        tailCurveRadius: CGFloat,
        tailOffset: CGFloat,
        mirrorHorizontally: Bool = false
    ) {
        self.cornerRadius = cornerRadius
        self.tailSize = tailSize
        self.tailCurveRadius = tailCurveRadius
        self.tailOffset = tailOffset
        self.mirrorHorizontally = mirrorHorizontally
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        guard insetRect.width > 0, insetRect.height > 0 else { return path }
        
        let adjustedCornerRadius = max(cornerRadius - insetAmount, 0)
        let tailDirection: CGFloat = mirrorHorizontally ? 1 : -1
        
        let adjustedTailWidth = max(tailSize.width - insetAmount * 1.3, 4)
        let adjustedTailHeight = max(tailSize.height - insetAmount * 1.1, 6)
        
        let tailInsetX: CGFloat = adjustedTailWidth
        let bubbleRect = CGRect(
            x: mirrorHorizontally ? insetRect.minX : insetRect.minX + tailInsetX,
            y: insetRect.minY,
            width: insetRect.width - tailInsetX,
            height: insetRect.height
        )
        
        path.addRoundedRect(
            in: bubbleRect,
            cornerSize: CGSize(width: adjustedCornerRadius, height: adjustedCornerRadius)
        )
        
        let minTailY = bubbleRect.minY + adjustedCornerRadius + tailCurveRadius
        let maxTailY = bubbleRect.maxY - adjustedCornerRadius - tailCurveRadius
        let clampedTailMidY = min(max(minTailY, bubbleRect.midY + tailOffset), maxTailY)
        
        let tailStartY = clampedTailMidY - adjustedTailHeight / 2
        let tailEndY = clampedTailMidY + adjustedTailHeight / 2
        
        let startPoint = CGPoint(
            x: mirrorHorizontally ? bubbleRect.maxX : bubbleRect.minX,
            y: tailStartY
        )
        let tipPoint = CGPoint(
            x: startPoint.x + tailDirection * adjustedTailWidth,
            y: clampedTailMidY
        )
        let endPoint = CGPoint(
            x: mirrorHorizontally ? bubbleRect.maxX : bubbleRect.minX,
            y: tailEndY
        )
        
        let controlOffset = tailCurveRadius * tailDirection
        
        path.move(to: startPoint)
        path.addQuadCurve(
            to: tipPoint,
            control: CGPoint(
                x: startPoint.x + controlOffset,
                y: startPoint.y
            )
        )
        path.addQuadCurve(
            to: endPoint,
            control: CGPoint(
                x: endPoint.x + controlOffset,
                y: endPoint.y
            )
        )
        path.closeSubpath()
        
        return path
    }
}

