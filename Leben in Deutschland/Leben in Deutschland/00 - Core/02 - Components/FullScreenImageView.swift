//
//  FullScreenImageView.swift
//  Leben in Deutschland
//
//  Full-screen zoomable image overlay with tap-to-dismiss and close button.
//

import SwiftUI

/// Presents an image asset in full-screen with zoom, tap-to-dismiss, and close button.
struct FullScreenImageView: View {
    let assetName: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    HapticManager.shared.lightImpact()
                    onDismiss()
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onDismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.9))
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                }
                Spacer()
            }
            
            ZoomableImage(imageName: assetName)
                .padding(.horizontal, 20)
                .padding(.vertical, 60)
        }
        .transition(.opacity)
    }
}
