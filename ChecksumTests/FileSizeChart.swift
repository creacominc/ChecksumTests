//
//  FileSizeChart.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import SwiftUI
import Charts

struct FileSizeChartDataPoint: Identifiable {
    let id = UUID()
    let threshold: Int
    let fileCount: Int
    let thresholdFormatted: String
}

struct FileSizeChart: View {
    let thresholds: [Int]
    let tester: Tester?
    
    private var chartData: [FileSizeChartDataPoint] {
        guard let tester = tester else { return [] }
        
        // For each threshold, count files with size <= threshold
        return thresholds.map { threshold in
            let count = tester.countFilesAtOrBelowThreshold(threshold)
            return FileSizeChartDataPoint(
                threshold: threshold,
                fileCount: count,
                thresholdFormatted: MultiThumbSlider.formatBytes(Double(threshold))
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("File Size Distribution")
                .font(.headline)
                .padding(.bottom, 4)
            
            if tester != nil && !chartData.isEmpty {
                Text("Shows cumulative count of files ≤ each threshold")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                Chart {
                    ForEach(chartData) { dataPoint in
                        LineMark(
                            x: .value("Threshold", log10(Double(dataPoint.threshold))),
                            y: .value("File Count", dataPoint.fileCount)
                        )
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Threshold", log10(Double(dataPoint.threshold))),
                            y: .value("File Count", dataPoint.fileCount)
                        )
                        .annotation(position: .top) {
                            Text("\(dataPoint.fileCount)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        if let logValue = value.as(Double.self) {
                            let actualValue = pow(10, logValue)
                            AxisValueLabel {
                                Text(MultiThumbSlider.formatBytes(actualValue))
                                    .font(.caption2)
                            }
                            AxisGridLine()
                            AxisTick()
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: 200)
            } else {
                Text("Select a folder to see file size distribution")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    FileSizeChart(
        thresholds: [512, 8192, 1048576, 268435456, 17179869184],
        tester: nil
    )
}
