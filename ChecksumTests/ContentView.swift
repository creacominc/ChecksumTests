//
//  ContentView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-04.
//

import SwiftUI

struct ContentView: View
{
    @State var sourceURL: URL?
    @State var folderSelected: Bool = false
    @State var sourceEnabled: Bool = true
    @State var fileSetBySize = FileSetBySize()
    @State var updateDistribution: Bool = false
    @State var processEnabled: Bool = false

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
            FolderStatsView( sourceURL: sourceURL
                             , updateDistribution: $updateDistribution
                             , fileSetBySize: $fileSetBySize )
            FileSizeDistributionView( fileSetBySize: $fileSetBySize
                                      , updateDistribution: $updateDistribution
                                      , processEnabled: $processEnabled
            )

            // process button
            HStack
            {
                Button("Process")
                {
                    
                }
                .disabled( !processEnabled )
                Spacer()
            }
            // progress bar
            Text("TBD progress bar")
            // results
            Text("TBD results")
        }
        .padding( )
        Spacer()
    }
}

#Preview {
    ContentView()
}
