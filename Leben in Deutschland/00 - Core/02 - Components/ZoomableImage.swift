//
//  ZoomableImage.swift
//  Leben in Deutschland
//
//  Component for displaying zoomable images using iOS 26 SwiftUI best practices
//

import SwiftUI

struct ZoomableImage: View {
    let imageName: String
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    var body: some View {
        GeometryReader { geometry in
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let newScale = lastScale * value
                            scale = min(max(newScale, minScale), maxScale)
                        }
                        .onEnded { _ in
                            lastScale = scale
                            
                            // Snap back to min scale if below threshold
                            if scale < minScale {
                                resetZoom(geometry: geometry)
                            } else {
                                // Constrain offset when zoom ends
                                constrainOffset(geometry: geometry)
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            // Only allow dragging when zoomed in
                            guard scale > minScale else { return }
                            
                            let maxOffsetX = (geometry.size.width * (scale - 1)) / 2
                            let maxOffsetY = (geometry.size.height * (scale - 1)) / 2
                            
                            offset = CGSize(
                                width: min(max(lastOffset.width + value.translation.width, -maxOffsetX), maxOffsetX),
                                height: min(max(lastOffset.height + value.translation.height, -maxOffsetY), maxOffsetY)
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
        }
    }
    
    private func resetZoom(geometry: GeometryProxy) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            scale = minScale
            lastScale = minScale
            offset = .zero
            lastOffset = .zero
        }
    }
    
    private func constrainOffset(geometry: GeometryProxy) {
        let maxOffsetX = (geometry.size.width * (scale - 1)) / 2
        let maxOffsetY = (geometry.size.height * (scale - 1)) / 2
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = CGSize(
                width: min(max(offset.width, -maxOffsetX), maxOffsetX),
                height: min(max(offset.height, -maxOffsetY), maxOffsetY)
            )
            lastOffset = offset
        }
    }
}

