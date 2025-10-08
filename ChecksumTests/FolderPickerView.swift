//
//  FolderPickerView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import SwiftUI

struct FolderPickerView: View {
    @Binding var sourceURL: URL?
    @Binding var sourceEnabled: Bool
    @Binding var processEnabled: Bool
    @Binding var statusText: String
    @Binding var totalFiles: Double
    @Binding var fileCountByType: [String: Int]
    var onFolderSelected: ((Tester) -> Void)?
    
    var body: some View {
        HStack {
            Button("Source") {
                // create file open dialog to select a folder
                let panel = NSOpenPanel()
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                panel.allowsMultipleSelection = false
                panel.canCreateDirectories = false
                panel.message = "Select test directory containing media files"
                if panel.runModal() == .OK, let url = panel.url {
                    sourceURL = url
                    // Initialize Tester with the selected URL
                    let tester = Tester(sourceURL: url)
                    processEnabled = true
                    statusText = "Source directory selected. Click Process to analyze files."
                    // Update UI with results
                    totalFiles = tester.getFileCount()
                    fileCountByType = tester.getFileCountByType()
                    onFolderSelected?(tester)
                }
            }
            .disabled(!sourceEnabled)
            Text(sourceURL?.absoluteString ?? "Select Source Folder")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    FolderPickerView(
        sourceURL: .constant(nil),
        sourceEnabled: .constant(true),
        processEnabled: .constant(false),
        statusText: .constant("Select a source directory"),
        totalFiles: .constant(0.0),
        fileCountByType: .constant([:]),
        onFolderSelected: nil
    )
}

#Preview("With URL") {
    FolderPickerView(
        sourceURL: .constant(URL(string: "file:///Users/test/Documents")),
        sourceEnabled: .constant(false),
        processEnabled: .constant(true),
        statusText: .constant("Source directory selected"),
        totalFiles: .constant(100.0),
        fileCountByType: .constant(["photo": 50, "video": 30]),
        onFolderSelected: nil
    )
}
