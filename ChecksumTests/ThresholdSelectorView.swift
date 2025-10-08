//
//  ThresholdSelectorView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import SwiftUI

struct ThresholdSelectorView: View {
    @Binding var thresholds: [Int]
    
    var body: some View {
        VStack {
            MultiThumbSlider(
                values: $thresholds,
                bounds: 512...17179869184, // 512 bytes to 16 GB
                minSeparation: 64,         // Smaller separation for log scale
                step: nil                  // No stepping for smooth log scale
            )
            Text(
                thresholds.map { MultiThumbSlider.formatBytes(Double($0))
                }.joined(separator: ", "))
                .monospaced()
                .font(.caption)
        }
    }
}

#Preview {
    ThresholdSelectorView(
        thresholds: .constant([
            512,
            8192,
            1048576,
            268435456,
            17179869184
        ])
    )
    .padding()
}
