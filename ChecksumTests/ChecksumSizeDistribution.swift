//
//  ChecksumSizeDistribution.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import SwiftUI

struct ChecksumSizeDistribution: View
{
    // [in] sourceURL - to detect when a new folder is selected
    var sourceURL: URL?
    // [in] processEnabled - true when there is data to process
    @Binding var processEnabled: Bool
    // [in] fileSetBySize - files grouped by size
    @Binding var fileSetBySize: FileSetBySize
    // [in/out] progress tracking
    @Binding var currentLevel: Int
    @Binding var maxLevel: Int
    
    // State to hold the results
    @State private var bytesNeededBySize: [Int:Int] = [:]
    // Track whether processing is running
    @State private var isProcessing: Bool = false
    // Cancellation flag
    @State private var shouldCancel: Bool = false
    // Sorting state
    @State private var sortColumn: SortColumn = .fileSize
    @State private var sortAscending: Bool = true
    
    enum SortColumn {
        case fileSize
        case bytesNeeded
    }
    
    // Helper function to get sorted data
    private func sortedData() -> [(Int, Int)] {
        let dataArray = bytesNeededBySize.map { ($0.key, $0.value) }
        
        switch sortColumn {
        case .fileSize:
            return dataArray.sorted { 
                sortAscending ? $0.0 < $1.0 : $0.0 > $1.0
            }
        case .bytesNeeded:
            return dataArray.sorted { 
                sortAscending ? $0.1 < $1.1 : $0.1 > $1.1
            }
        }
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            // process/stop button
            HStack
            {
                Button(isProcessing ? "Stop" : "Process")
                {
                    if isProcessing {
                        // Stop processing
                        shouldCancel = true
                    } else {
                        // Start processing
                        shouldCancel = false
                        isProcessing = true
                        // Clear previous results when starting new processing
                        bytesNeededBySize = [:]
                        
                        // Process on background thread to keep UI responsive
                        DispatchQueue.global(qos: .userInitiated).async {
                            // bytes needed for uniqueness as a percent of size
                            let results = fileSetBySize.getBytesNeededForUniqueness(
                                currentLevel: { level in
                                    self.currentLevel = level
                                },
                                maxLevel: { max in
                                    self.maxLevel = max
                                },
                                shouldCancel: {
                                    return self.shouldCancel
                                }
                            )
                            
                            // Update results on main thread
                            DispatchQueue.main.async {
                                if !self.shouldCancel {
                                    // Only update results if not cancelled
                                    self.bytesNeededBySize = results
                                    print("Processing completed. Results count: \(results.count)")
                                    if results.isEmpty {
                                        print("No results found - all files may be unique or identical")
                                    }
                                } else {
                                    print("Processing was cancelled")
                                }
                                self.isProcessing = false
                                self.shouldCancel = false
                            }
                        }
                    }
                }
                .disabled( !processEnabled && !isProcessing )
                Spacer()
            }
            
            // Status message
            if !isProcessing && bytesNeededBySize.isEmpty && currentLevel > 0 {
                Text("Processing completed. No duplicate files found or all duplicates are identical.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
            
            // Display table if we have results
            if !bytesNeededBySize.isEmpty
            {
                VStack(alignment: .leading, spacing: 5)
                {
                    Text("Bytes Needed for Uniqueness by Size")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    // Table header
                    HStack
                    {
                        Button(action: {
                            if sortColumn == .fileSize {
                                sortAscending.toggle()
                            } else {
                                sortColumn = .fileSize
                                sortAscending = true
                            }
                        }) {
                            HStack {
                                Text("File Size (bytes)")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                if sortColumn == .fileSize {
                                    Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            if sortColumn == .bytesNeeded {
                                sortAscending.toggle()
                            } else {
                                sortColumn = .bytesNeeded
                                sortAscending = true
                            }
                        }) {
                            HStack {
                                Text("Bytes Needed")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                if sortColumn == .bytesNeeded {
                                    Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    
                    // Table rows
                    ScrollView
                    {
                        VStack(spacing: 0)
                        {
                            ForEach(sortedData(), id: \.0)
                            {
                                item in
                                HStack
                                {
                                    Text("\(item.0)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(item.1)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.05))
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                    .border(Color.gray.opacity(0.3), width: 1)
                }
            }
        }
        .onChange(of: sourceURL) { oldValue, newValue in
            // Clear results when a new folder is selected
            if oldValue != newValue {
                // Cancel any processing in progress
                if isProcessing {
                    shouldCancel = true
                }
                bytesNeededBySize = [:]
                currentLevel = 0
                maxLevel = 0
            }
        }
    }
}

#Preview
{
    @Previewable @State var sourceURL: URL? = nil
    @Previewable @State var processEnabled: Bool = true
    @Previewable @State var fileSetBySize: FileSetBySize = FileSetBySize()
    @Previewable @State var currentLevel: Int = 0
    @Previewable @State var maxLevel: Int = 100

    ChecksumSizeDistribution( sourceURL: sourceURL
                              , processEnabled: $processEnabled
                              , fileSetBySize: $fileSetBySize
                              , currentLevel: $currentLevel
                              , maxLevel: $maxLevel )
}
