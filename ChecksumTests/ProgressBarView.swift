//
//  ProgressBarView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    
    var body: some View {
        ProgressView(value: progress, total: 100.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
}

#Preview {
    ProgressBarView(progress: 0.0)
}

#Preview("Partial Progress") {
    ProgressBarView(progress: 45.0)
}

#Preview("Complete") {
    ProgressBarView(progress: 100.0)
}
