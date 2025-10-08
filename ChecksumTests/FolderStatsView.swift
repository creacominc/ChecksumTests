//
//  FolderStatsView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import SwiftUI

struct FolderStatsView: View {
    let totalFiles: Int
    let fileCountByType: [String: Int]
    
    var body: some View {
        HStack(spacing: 24) {
            Text("Total Files: \(totalFiles)")
                .font(.headline)
            
            if !fileCountByType.isEmpty {
                ForEach(["photo", "audio", "video", "other"], id: \.self) { fileType in
                    if let count = fileCountByType[fileType], count > 0 {
                        HStack {
                            Text("\(fileType.capitalized):")
                                .font(.caption)
                            Text("\(count)")
                                .font(.caption)
                                .monospaced()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    FolderStatsView(
        totalFiles: 0,
        fileCountByType: [:]
    )
}

#Preview("With Files") {
    FolderStatsView(
        totalFiles: 150,
        fileCountByType: [
            "photo": 80,
            "audio": 20,
            "video": 45,
            "other": 5
        ]
    )
    .padding()
}
