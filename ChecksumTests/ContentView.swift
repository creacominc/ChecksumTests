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
    @State var bestResults : ResultSet = ResultSet()
    // last results
    @State var lastResults : ResultSet = ResultSet()
    @State var isProcessing: Bool = false

    var body: some View {
        ZStack {
            VStack {
                // Folder picker
                FolderPickerView(
                    sourceURL: $sourceURL,
                    sourceEnabled: $sourceEnabled,
                    processEnabled: $processEnabled,
                    statusText: $statusText,
                    totalFiles: $totalFiles,
                    fileCountByType: $fileCountByType,
                    onFolderSelected: { newTester in
                        tester = newTester
                    }
                )
                
                // Folder stats
                FolderStatsView(
                    totalFiles: Int(totalFiles),
                    fileCountByType: fileCountByType
                )
                
                // Threshold selector
                ThresholdSelectorView(thresholds: $thresholds)
                
                // File size distribution chart
                FileSizeChart(thresholds: thresholds, tester: tester)
                
                // Process button
                ProcessControlView(
                    processEnabled: $processEnabled,
                    onProcess: handleProcess
                )
                
                // Progress bar
                ProgressBarView(progress: progress)
                
                // Results charts
                ResultsChartsView(
                    bestResults: bestResults,
                    lastResults: lastResults
                )
                
                // Spacers
                Spacer()
                Spacer()
                
                // Status text
                Text(statusText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            
            // Busy overlay
            if isProcessing {
                BusyOverlayView()
            }
        }
    }
    
    private func handleProcess() {
        guard let tester = tester else { return }
        
        // Save last result to best if it's better
        if !lastResults.isEmpty &&
            (bestResults.isEmpty || lastResults.totalTime < bestResults.totalTime) {
            statusText = "Copying last to best."
            bestResults = lastResults
        }
        
        // Enter busy state and run processing off the main thread
        isProcessing = true
        sourceEnabled = false
        processEnabled = false
        statusText = "Processing files..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            let results: ResultSet = tester.process(
                thresholds: thresholds
            ) { progressValue, statusMessage in
                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.progress = progressValue
                    self.statusText = statusMessage
                }
            }
            
            DispatchQueue.main.async {
                // Update UI after processing completes
                self.lastResults = results
                self.statusText = "Processing complete. Found \(Int(totalFiles)) files."
                self.isProcessing = false
                self.sourceEnabled = true
                self.processEnabled = true
            }
        }
    }
}

#Preview {
    ContentView()
}
