//
//  ContentView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-04.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View
{
    @State var sourceURL: URL?
    @State var folderSelected: Bool = false
    @State var sourceEnabled: Bool = true
//    let numberOfChecksumSizes: Int = 6
//    @State var thresholds: [Double] = [
//        512,
//        8192,
//        1048576,
//        268435456,
//        17179869184
//    ]

    var body: some View
    {
        VStack()
        {
            // folder picker
            FolderSelectionView(
                sourceURL: $sourceURL,
                folderSelected: $folderSelected,
                sourceEnabled: $sourceEnabled
            )

            // folder stats
            FolderStatsView( sourceURL: sourceURL )

//            // checksum sizes
//            MultiThumbSlider(
//                values: $thresholds,
//                bounds: 512...17179869184, // 512 bytes to 16 GB
//                minSeparation: 64,         // Smaller separation for log scale
//                step: nil                  // No stepping for smooth log scale
//            )
//            Text(thresholds.map { MultiThumbSlider.formatBytes($0) }.joined(separator: ", "))
//                .monospaced()
//                .font(.caption)
//
//            // process button
//            HStack
//            {
//                Button("Process")
//                {
//                    
//                }
//                .disabled( !processEnabled )
//                Spacer()
//            }
//            // progress bar
//            Text("TBD progress bar")
//            // results
//            Text("TBD results")
        }
        .padding( )
        Spacer()
    }
}

#Preview {
    ContentView()
}
