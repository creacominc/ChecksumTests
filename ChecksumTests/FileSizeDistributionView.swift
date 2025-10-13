//
//  FileSizeDistributionView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import SwiftUI
import Charts

// a graph of the number of files in each file size
struct FileSizeDistributionView: View
{

    // [inout] fileSetBySize - files grouped by size
    @Binding var fileSetBySize: FileSetBySize

    // [inout] updateDistribution - set this when updated
    @Binding var updateDistribution: Bool
    
    // Chart type selection
    @State private var useLineChart: Bool = false

    // set to true when ready to process
    @Binding var processEnabled: Bool

    // Auxiliary for formatting byte sizes (KB, MB, ...)
    func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }


    var body: some View
    {
        // Show a bar chart of file counts by file size, using human-readable size labels

        // Create size bins for better visualization when there are many unique sizes
        let sizes = fileSetBySize.sortedSizes
        let data: [(size: String, count: Int, sortKey: Int)]
        
        if sizes.count > 20 {
            // Use size bins when there are too many unique sizes
            data = createSizeBins(from: fileSetBySize)
            print( "Created \(data.count) size bins" )
            // log minimum and maximum sizes:
            print( "min size: \(fileSetBySize.sortedSizes.first ?? 0)")
            print( "max size: \(fileSetBySize.sortedSizes.last ?? 0)")
        } else {
            // Show individual sizes when there are few unique sizes
            data = sizes.map { size in
                (size: formatBytes(size), count: fileSetBySize.count(for: size), sortKey: size)
            }
            // print( "Showing \(data.count) size bars" )
        }

        return VStack(alignment: .leading)
        {
            // Chart type toggle
            HStack {
                Text("File Size Distribution")
                    .font(.headline)
                Spacer()
                Toggle("Line Chart", isOn: $useLineChart)
                    .toggleStyle(SwitchToggleStyle())
                    .font(.caption)
            }
            
            if data.isEmpty
            {
                Text("No files to display").foregroundColor(.secondary)
            }
            else
            {
                Chart(data.sorted(by: { $0.sortKey < $1.sortKey }), id: \.size)
                { item in
                    if useLineChart {
                        LineMark(
                            x: .value("Size", item.size),
                            y: .value("File Count", item.count)
                        )
                        .foregroundStyle(Color.accentColor)
                        .symbol(Circle())
                    } else {
                        BarMark(
                            x: .value("Size", item.size),
                            y: .value("File Count", item.count)
                        )
                        .foregroundStyle(Color.accentColor)
                        .annotation(position: .top) {
                            Text("\(item.count)")
                                .font(.caption2)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 2)
                                .background(Color.clear)
                        }
                    }
                }
                .chartXAxisLabel("File Size")
                .chartYAxisLabel("File Count")
                .frame(height: 200)
                .id(updateDistribution)

                // Show min/max labels below the chart, formatted
                HStack
                {
                    if let min = sizes.min(), let max = sizes.max()
                    {
                        Text("Min: \(formatBytes(min))").font(.caption)
                        Spacer()
                        Text("Max: \(formatBytes(max))").font(.caption)
                        if sizes.count > 20
                        {
                            Spacer()
                            Text("(\(sizes.count) unique sizes, showing bins)").font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            } // data is not empty
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onChange(of: updateDistribution) { oldValue, newValue in
            // Enable processing when analysis is complete and there's data
            // Disable processing when analysis is in progress (updateDistribution = false)
            if newValue {
                // Analysis is complete - enable if we have data
                processEnabled = fileSetBySize.totalFileCount > 0
            } else {
                // Analysis is in progress or URL changed - disable
                processEnabled = false
            }
        }
        .onAppear {
            // Set initial state based on current data
            processEnabled = updateDistribution && fileSetBySize.totalFileCount > 0
        }
    }
    
    // MARK: - Private Methods
    
    /// Creates size bins for better visualization when there are many unique file sizes
    private func createSizeBins(from fileSetBySize: FileSetBySize) -> [(size: String, count: Int, sortKey: Int)]
    {
        let sizes = fileSetBySize.sortedSizes
        guard var minSize: Int = sizes.min(), var maxSize: Int = sizes.max() else {
            return []
        }
        
        minSize = max( 128, minSize )
        maxSize = max( 128, maxSize )
        // Use logarithmic binning for better distribution across orders of magnitude
        let logMin = log10(Double(minSize))
        let logMax = log10(Double(maxSize))
        let numBins = 20 // Number of bins for distribution visualization
        
        // If the range is too small for meaningful log bins, use linear binning
        if logMax - logMin < 1.0 {
            let binSize = Double(maxSize - minSize) / Double(numBins)
            var bins: [String: Int] = [:]
            
            for size in sizes {
                let binIndex = Int(Double(size - minSize) / binSize)
                let actualBinIndex = min(binIndex, numBins - 1)
                
                let binStart = minSize + Int(Double(actualBinIndex) * binSize)
                let binEnd = minSize + Int(Double(actualBinIndex + 1) * binSize)
                
                let binLabel = "\(formatBytes(binStart)) - \(formatBytes(binEnd))"
                bins[binLabel, default: 0] += fileSetBySize.count(for: size)
            }
            
            return bins.compactMap { (label, count) in
                count > 0 ? (size: label, count: count, sortKey: extractSortKey(from: label)) : nil
            }.sorted { $0.sortKey < $1.sortKey }
        }
        
        // Logarithmic binning
        let binSize = (logMax - logMin) / Double(numBins)
        var bins: [String: Int] = [:]
        
        for size in sizes {
            let logSize = log10(Double( max(size,128) ))
            let binIndex = Int((logSize - logMin) / binSize)
            let actualBinIndex = min(binIndex, numBins - 1) // Ensure we don't exceed bounds
            
            // Calculate bin boundaries
            let binStart = pow(10, logMin + Double(actualBinIndex) * binSize)
            let binEnd = pow(10, logMin + Double(actualBinIndex + 1) * binSize)
            
            let binLabel = "\(formatBytes(Int(binStart))) - \(formatBytes(Int(binEnd)))"
            bins[binLabel, default: 0] += fileSetBySize.count(for: size)
        }
        
        // Filter out empty bins and sort
        return bins.compactMap { (label, count) in
            count > 0 ? (size: label, count: count, sortKey: extractSortKey(from: label)) : nil
        }.sorted { $0.sortKey < $1.sortKey }
    }
    
    /// Extracts the numeric sort key from a formatted size label like "5.3 MB - 5.4 MB"
    private func extractSortKey(from label: String) -> Int {
        // Extract the first number from the label (e.g., "5.3" from "5.3 MB - 5.4 MB")
        let components = label.components(separatedBy: " ")
        if let firstComponent = components.first,
           let sizeValue = Double(firstComponent) {
            // Convert to bytes for consistent sorting
            if label.contains("KB") {
                return Int(sizeValue * 1024)
            } else if label.contains("MB") {
                return Int(sizeValue * 1024 * 1024)
            } else if label.contains("GB") {
                return Int(sizeValue * 1024 * 1024 * 1024)
            } else {
                return Int(sizeValue)
            }
        }
        return 0
    }
}

#Preview
{
    @Previewable @State var fileSetBySize: FileSetBySize = FileSetBySize()
    @Previewable @State var updateDistribution: Bool = false
    @Previewable @State var processEnabled: Bool = false

    FileSizeDistributionView( fileSetBySize: $fileSetBySize
                              , updateDistribution: $updateDistribution
                              , processEnabled: $processEnabled
    )
}
