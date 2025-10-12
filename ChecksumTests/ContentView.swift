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
    @State var currentLevel: Int = 0
    @State var maxLevel: Int = 0

    var body: some View
    {
        VStack()
        {
            // folder picker
            FolderSelectionView(
                sourceURL: $sourceURL,
                folderSelected: $folderSelected,
                sourceEnabled: $sourceEnabled,
                fileSetBySize: $fileSetBySize
            )

            // folder stats
            FolderStatsView( sourceURL: sourceURL
                             , updateDistribution: $updateDistribution
                             , fileSetBySize: $fileSetBySize )
            FileSizeDistributionView( fileSetBySize: $fileSetBySize
                                      , updateDistribution: $updateDistribution
                                      , processEnabled: $processEnabled
            )

            // ChecksumSizeDistribution
            ChecksumSizeDistribution( sourceURL: sourceURL
                                      , processEnabled: $processEnabled
                                      , fileSetBySize: $fileSetBySize
                                      , currentLevel: $currentLevel
                                      , maxLevel: $maxLevel )

            // progress bar
            ProgressBarView( currentLevel: $currentLevel,
                             maxLevel: $maxLevel )


            // file extensions handled
            FileExtensionsHandledView( fileSetBySize: $fileSetBySize )
        }
        .padding( )
        Spacer()
    }
}

#Preview {
    ContentView()
}
