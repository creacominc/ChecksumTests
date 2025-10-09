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
    @State var flushCachesBeforeProcessing: Bool = true

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
                
                // Process button and cache flush option
                VStack(spacing: 8) {
                    ProcessControlView(
                        processEnabled: $processEnabled,
                        onProcess: handleProcess
                    )
                    
                    Toggle("Flush disk caches before processing (requires admin)", isOn: $flushCachesBeforeProcessing)
                        .font(.caption)
                        .toggleStyle(.checkbox)
                }
                
                // Progress bar
                ProgressBarView(progress: progress)

                // Reset Best Button
                HStack {
                    Button("Reset Best")
                    {
                        self.bestResults = ResultSet()
                    }
                    Spacer()
                }

                // Results charts
                ResultsChartsView(
                    bestResults: self.bestResults,
                    lastResults: self.lastResults
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
    
    /// Flush disk caches using the purge command (requires admin privileges)
    private func flushDiskCaches(completion: @escaping (Bool) -> Void) {
        let script = """
        do shell script "purge" with administrator privileges
        """
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let success = process.terminationStatus == 0
            if success {
                print("Disk caches flushed successfully")
            } else {
                print("Failed to flush disk caches (status: \(process.terminationStatus))")
            }
            completion(success)
        } catch {
            print("Error running purge command: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    private func handleProcess() {
        guard let tester = tester else { return }
        
        // Save last result to best if it's better
        if !self.lastResults.isEmpty &&
            (self.bestResults.isEmpty || self.lastResults.totalTime < self.bestResults.totalTime) {
            statusText = "Copying last to best."
            self.bestResults = self.lastResults
        }
        
        // Enter busy state
        isProcessing = true
        sourceEnabled = false
        processEnabled = false
        
        // Flush caches if requested, then start processing
        if flushCachesBeforeProcessing {
            statusText = "Flushing disk caches..."
            DispatchQueue.global(qos: .userInitiated).async {
                self.flushDiskCaches { success in
                    if success {
                        DispatchQueue.main.async {
                            self.statusText = "Disk caches flushed. Starting processing..."
                        }
                        // Wait a moment for the system to settle
                        Thread.sleep(forTimeInterval: 1.0)
                    } else {
                        DispatchQueue.main.async {
                            self.statusText = "Failed to flush caches. Continuing anyway..."
                        }
                        Thread.sleep(forTimeInterval: 1.0)
                    }
                    self.startProcessing(tester: tester)
                }
            }
        } else {
            statusText = "Processing files..."
            DispatchQueue.global(qos: .userInitiated).async {
                self.startProcessing(tester: tester)
            }
        }
    }
    
    private func startProcessing(tester: Tester) {
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

#Preview {
    ContentView()
}
