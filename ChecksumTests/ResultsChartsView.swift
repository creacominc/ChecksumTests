//
//  ResultsChartsView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-08.
//

import SwiftUI
import Charts

struct ResultsChartsView: View
{
    let bestResults: ResultSet
    let lastResults: ResultSet
    
    var body: some View
    {
        if !lastResults.isEmpty || !bestResults.isEmpty
        {
            VStack {
                // Times Chart
                Chart {
                    // Plot bestResults times
                    ForEach(Array(bestResults.results.enumerated()), id: \.offset) { index, result in
                        LineMark(
                            x: .value("Threshold", result.getSize()),
                            y: .value("Time", result.getTime()),
                            series: .value("Series", "Best")
                        )
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                        .symbol {
                            Image(systemName: "diamond.fill")
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Plot lastResults times
                    ForEach(Array(lastResults.results.enumerated()), id: \.offset) { index, result in
                        LineMark(
                            x: .value("Threshold", result.getSize()),
                            y: .value("Time", result.getTime()),
                            series: .value("Series", "Last")
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                        .symbol {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self), intValue > 0 {
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
            } // VStack
        } // lastResults.isEmpty
        else
        {
            Text("No results yet - click Process to analyze files")
                .foregroundColor(.secondary)
                .padding()
        } // lastResults.isEmpty
    } // body
}

#Preview {
    ResultsChartsView(
        bestResults: ResultSet(),
        lastResults: ResultSet()
    )
    .frame(height: 500)
}

#Preview("With Data") {
    // Create sample data for preview
    let sampleBest: ResultSet = {
        var resultSet = ResultSet()
        resultSet.results = [
            Result(size: 512, count: 100, time: 0.5),
            Result(size: 8192, count: 95, time: 0.8),
            Result(size: 1048576, count: 80, time: 1.2),
            Result(size: 268435456, count: 50, time: 2.5)
        ]
        resultSet.totalTime = 4.0
        return resultSet
    }()
    
    let sampleLast: ResultSet = {
        var resultSet = ResultSet()
        resultSet.results = [
            Result(size: 512, count: 100, time: 0.6),
            Result(size: 8192, count: 95, time: 0.9),
            Result(size: 1048576, count: 80, time: 1.4),
            Result(size: 268435456, count: 50, time: 2.8)
        ]
        resultSet.totalTime = 4.7
        return resultSet
    }()
    
    ResultsChartsView(
        bestResults: sampleBest,
        lastResults: sampleLast
    )
    .frame(height: 500)
    .padding()
}
