//
//  FolderStatsView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import SwiftUI

struct FolderStatsView: View
{
    // [in] URL to be set when the user selects a path
    var sourceURL: URL?
    
    // [internal] Analyzer to handle folder statistics
    @State private var analyzer = FolderAnalyzer()
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            if let url = sourceURL
            {
                Text("Folder: \(url.path())")
                    .font(.headline)

                if analyzer.isAnalyzing
                {
                    ProgressView("Analyzing folder...")
                }
                else
                {
                    Text("Files: \(analyzer.fileCount)")
                    Text("Total Size: \(formatBytes(analyzer.totalSize))")
                    // Add more stats display here as needed
                }
            }
            else
            {
                Text("No folder selected")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onChange(of: sourceURL)
        { oldValue, newValue in
            // This closure is called whenever sourceURL changes
            if let url = newValue
            {
                analyzer.analyzeFolderStats(url: url)
            }
            else
            {
                // Reset stats when URL is cleared
                analyzer.reset()
            }
        }
        .onAppear
        {
            // Also analyze on first appearance if URL is already set
            if let url = sourceURL
            {
                analyzer.analyzeFolderStats(url: url)
            }
        }
    }

    // MARK: - Private Methods
    private func formatBytes(_ bytes: Int64) -> String
    {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview("None Selected")
{
    @Previewable @State var sourceURL: URL? = nil
    FolderStatsView( sourceURL: sourceURL )
}

#Preview("Selected")
{
    @Previewable @State var sourceURL: URL = URL(
        filePath: "~/Downloads"
    )
    
    FolderStatsView( sourceURL: sourceURL )
}
