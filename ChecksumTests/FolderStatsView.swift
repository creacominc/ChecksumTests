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

    // [inout] updateDistribution - set this when updated
    @Binding var updateDistribution: Bool

    // [internal] Analyzer to handle folder statistics
    @State private var analyzer = FolderAnalyzer()

    // file set by size from the contentView
    @Binding var fileSetBySize: FileSetBySize

    var body: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            if let url = sourceURL
            {
                // Folder path text field
                Text("Folder: \(url.path())")
                    .font(.headline)

                if analyzer.isAnalyzing
                {
                    ProgressView("Analyzing folder...")
                }
                else
                {
                    // Folder stats
                    Text("Files: \(analyzer.fileCount)")
                    Text("Total Size: \(formatBytes(analyzer.totalSize))")
                    Text(
                        "Number of Sizes with only one file: \(fileSetBySize.sizesWithOnlyOneFile.count)"
                    )
                    Text(
                        "Number of sizes with multiple files: \(fileSetBySize.sizesWithMultipleFiles.count)"
                    )
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
            updateDistribution = false
            
            // If URL changed, ensure we start fresh
            if oldValue != newValue {
                // Reset analyzer to clear any in-progress state
                // This allows a new analysis to start immediately
                if analyzer.isAnalyzing {
                    print("Resetting analyzer due to URL change from \(oldValue?.path ?? "nil") to \(newValue?.path ?? "nil")")
                }
                analyzer.reset()
            }
            
            // This closure is called whenever sourceURL changes
            if let url = newValue
            {
                analyzer.analyzeFolderStats(url: url, into: fileSetBySize) {
                    // This completion handler is called when analysis is done
                    updateDistribution = true
                }
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
    @Previewable @State var fileSetBySize = FileSetBySize()
    @Previewable @State var updateDistribution = false
    
    FolderStatsView(sourceURL: sourceURL
                    , updateDistribution: $updateDistribution
                    , fileSetBySize: $fileSetBySize
    )
}

#Preview("Selected")
{
    @Previewable @State var sourceURL: URL? = URL(filePath: "~/Downloads")
    @Previewable @State var fileSetBySize = FileSetBySize()
    @Previewable @State var updateDistribution = false

    FolderStatsView(sourceURL: sourceURL
                    , updateDistribution: $updateDistribution
                    , fileSetBySize: $fileSetBySize
    )
}
