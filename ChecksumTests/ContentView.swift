//
//  ContentView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-04.
//

import SwiftUI
import Charts
internal import UniformTypeIdentifiers

struct ContentView: View {
    @State var sourceURL: URL?
    @State var sourceEnabled: Bool = true
    @State var processEnabled: Bool = false
    @State var tester: Tester?
    @State var thresholds: [Int] = [
        512,
        8192,
        1048576,
        268435456,
        17179869184
    ]
    @State var statusText: String = "Select a source directory"
    @State var totalFiles: Double = 0.0
    @State var progress: Double = 0.0
    @State var fileCountByType: [String: Int] = [:]
    // best results
    @State var bestResults : [Int:Double] = [:]
    // last results
    @State var lastResults : [Int:Double] = [:]
    @State var isProcessing: Bool = false

    var body: some View
    {
        ZStack {
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
                        guard let tester = tester else {
                            statusText = "Failed to create tester object"
                            return
                        }
                        processEnabled = true
                        statusText = "Source directory selected. Click Process to analyze files."
                        // Update UI with results
                        totalFiles = tester.getFileCount()
                        fileCountByType = tester.getFileCountByType()
                    }
                }
                .disabled( !sourceEnabled )
                Text( sourceURL?.absoluteString ?? "Select Source Folder" )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            // folder stats
            HStack(spacing: 24) {
                Text("Total Files: \(Int(totalFiles))")
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
            // checksum sizes
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

            // process button
            HStack
            {
                Button("Process")
                {
                    guard let tester = tester else { return }
                    // save last result
                    if let lastFirst = lastResults.first?.value, let bestFirst = bestResults.first?.value, lastFirst < bestFirst
                    {
                        bestResults = lastResults
                    }
                    // Enter busy state and run processing off the main thread
                    isProcessing = true
                    sourceEnabled = false
                    processEnabled = false
                    statusText = "Processing files..."

                    DispatchQueue.global(qos: .userInitiated).async {
                        var localProgress: Double = 0.0
                        var localStatus: String = statusText
                        let results = tester.process( progress: &localProgress, thresholds: thresholds, statusText: &localStatus )

                        DispatchQueue.main.async {
                            // Update UI after processing completes
                            self.progress = localProgress
                            self.lastResults = results
                            self.statusText = "Processing complete. Found \(Int(totalFiles)) files."
                            self.isProcessing = false
                            self.sourceEnabled = true
                            self.processEnabled = true
                        }
                    }
                }
                .disabled( !processEnabled )
                Spacer()
            }
            // progress bar using a range based on the number of files
            ProgressView( value: progress, total: 100.0 )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            // results
            if !lastResults.isEmpty || !bestResults.isEmpty {
                Chart {
                    // Plot lastResults (excluding first member which is total time)
                    ForEach(Array(lastResults.sorted(by: { $0.key < $1.key })).dropFirst(), id: \.key) { item in
                        LineMark(
                            x: .value("Threshold", item.key),
                            y: .value("Time", item.value)
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                    .interpolationMethod(.catmullRom)
                    .symbol {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.blue)
                    }
                    
                    // Plot bestResults (excluding first member which is total time)
                    ForEach(Array(bestResults.sorted(by: { $0.key < $1.key })).dropFirst(), id: \.key) { item in
                        LineMark(
                            x: .value("Threshold", item.key),
                            y: .value("Time", item.value)
                        )
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                    .interpolationMethod(.catmullRom)
                    .symbol {
                        Image(systemName: "diamond.fill")
                            .foregroundColor(.red)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self), intValue>0 {
                                Text(MultiThumbSlider.formatBytes(Double(intValue)))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXScale(type: .log)
                .chartYAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(String(format: "%.3f", doubleValue))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            } else {
                Text("No results yet - click Process to analyze files")
                    .foregroundColor(.secondary)
                    .padding()
            }
            // Spacer
            Spacer()
            // Status Box
            Text( statusText )
                .frame( maxWidth: .infinity, alignment: .leading )
            }
            .padding( )

            // Busy overlay
            if isProcessing {
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
}

#Preview {
    ContentView()
}
