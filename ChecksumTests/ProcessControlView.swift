//
//  ProcessControlView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import SwiftUI

struct ProcessControlView: View {
    @Binding var processEnabled: Bool
    var onProcess: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onProcess) {
                Text("Process")
            }
            .disabled(!processEnabled)
            Spacer()
        }
    }
}

#Preview {
    ProcessControlView(
        processEnabled: .constant(true),
        onProcess: { print("Process button tapped") }
    )
    .padding()
}

#Preview("Disabled") {
    ProcessControlView(
        processEnabled: .constant(false),
        onProcess: { print("Process button tapped") }
    )
    .padding()
}
