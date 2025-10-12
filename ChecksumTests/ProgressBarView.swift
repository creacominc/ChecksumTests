//
//  ProgressBarView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import SwiftUI

struct ProgressBarView: View
{
    @Binding var currentLevel: Int
    @Binding var maxLevel: Int

    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            // Progress bar
            ProgressView(value: progress, total: 1.0) {
                Text("Processing")
                    .font(.caption)
            } currentValueLabel: {
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.caption)
            }
            .progressViewStyle(.linear)
            
            // File counter
            if maxLevel > 0 {
                Text("Processing: \(currentLevel) of \(maxLevel) file sizes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var progress: Double {
        guard maxLevel > 0 else { return 0 }
        return Double(currentLevel) / Double(maxLevel)
    }
}

#Preview
{
    @Previewable @State var currentLevel: Int = 42
    @Previewable @State var maxLevel: Int = 100

    ProgressBarView( currentLevel: $currentLevel,
                     maxLevel: $maxLevel )
}
