//
//  ContentView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-04.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View {
    @State var sourceURL: URL?
    @State var sourceEnabled: Bool = true
    @State var processEnabled: Bool = false
    @State var tester: Tester?
    let numberOfChecksumSizes: Int = 6
    @State var thresholds: [Double] = [
        512,
        8192,
        1048576,
        268435456,
        17179869184
    ]
    @State var statusText: String = "Select a source directory"
    @State var totalFiles: Double = 0.0
    @State var currentFileNumber: Double = 0.0
    @State var fileCountByType: [String: Int] = [:]

    var body: some View
    {
        VStack()
        {
            // folder picker
            HStack
            {
                Button("Source")
                {
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
                        tester = Tester(sourceURL: url)
                        processEnabled = true
                        statusText = "Source directory selected. Click Process to analyze files."
                        // Reset file counts until Process is clicked
                        totalFiles = 0.0
                        fileCountByType = [:]
                    }
                }
                .disabled( !sourceEnabled )
                Text( sourceURL?.absoluteString ?? "Select Source Folder" )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            // folder stats
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Files: \(Int(totalFiles))")
                    .font(.headline)
                
                if !fileCountByType.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
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
                    .padding(.leading, 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // checksum sizes
            MultiThumbSlider(
                values: $thresholds,
                bounds: 512...17179869184, // 512 bytes to 16 GB
                minSeparation: 64,         // Smaller separation for log scale
                step: nil                  // No stepping for smooth log scale
            )
            Text(thresholds.map { MultiThumbSlider.formatBytes($0) }.joined(separator: ", "))
                .monospaced()
                .font(.caption)

            // process button
            HStack
            {
                Button("Process")
                {
                    guard let tester = tester else { return }
                    
                    statusText = "Analyzing files..."
                    tester.getNumberOfFiles()
                    
                    // Update UI with results
                    totalFiles = tester.getFileCount()
                    fileCountByType = tester.getFileCountByType()
                    
                    statusText = "Analysis complete. Found \(Int(totalFiles)) files."
                }
                .disabled( !processEnabled )
                Spacer()
            }
            // progress bar using a range based on the number of files
            ProgressView(value: currentFileNumber, total: totalFiles)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            // results
            Text("TBD results")
            // Spacer
            Spacer()
            // Status Box
            Text( statusText )
                .frame( maxWidth: .infinity, alignment: .leading )
        }
        .padding( )
    }
}

#Preview {
    ContentView()
}
