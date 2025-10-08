//
//  BusyOverlayView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import SwiftUI

struct BusyOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Processing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(radius: 10)
            )
        }
    }
}

#Preview {
    ZStack {
        // Background content to show overlay effect
        VStack {
            Text("Main Content")
                .font(.largeTitle)
            Text("This is the main app content")
        }
        
        BusyOverlayView()
    }
}
