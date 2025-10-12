//
//  FileSelectionView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import SwiftUI
internal import System

struct FolderSelectionView: View
{
    // [out] URL to be set when the user selects a path
    @Binding var sourceURL: URL?
    // [out] indicates that a folder was selected
    @Binding var folderSelected: Bool
    // [in] controls the enablement of the Source button
    @Binding var sourceEnabled: Bool
    // [inout] fileSetBySize - reset files grouped by size
    @Binding var fileSetBySize: FileSetBySize

    var body: some View
    {
        HStack
        {
            Button("Source")
            {
                // reset fileSetBySize
                fileSetBySize.removeAll()
                // create file open dialog to select a folder
                let panel = NSOpenPanel()
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                panel.allowsMultipleSelection = false
                panel.canCreateDirectories = false
                panel.message = "Select test directory containing media files"
                if panel.runModal() == .OK, let url = panel.url {
                    sourceURL = url
                    folderSelected = true
                }
                else
                {
                    sourceURL = nil
                    folderSelected = false
                }
            }
            .disabled( !sourceEnabled )
            Text( sourceURL?.absoluteString ?? "Select Source Folder" )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


#Preview("Specified")
{
    @Previewable @State var sourceURL: URL? = URL(
        filePath: "~/Desktop"
    )
    @Previewable @State var folderSelected: Bool = false
    @Previewable @State var sourceEnabled: Bool = true
    @Previewable @State var fileSetBySize: FileSetBySize = FileSetBySize()
    
    // path specified and enabled
    FolderSelectionView( sourceURL: $sourceURL,
                         folderSelected: $folderSelected,
                         sourceEnabled: $sourceEnabled,
                         fileSetBySize: $fileSetBySize )
    
}

#Preview("Default")
{
    @Previewable @State var sourceURL: URL? = nil
    @Previewable @State var folderSelected: Bool = false
    @Previewable @State var sourceEnabled: Bool = true
    @Previewable @State var fileSetBySize: FileSetBySize = FileSetBySize()

    // (default) no file, enabled
    FolderSelectionView( sourceURL: $sourceURL,
                         folderSelected: $folderSelected,
                         sourceEnabled: $sourceEnabled,
                         fileSetBySize: $fileSetBySize )
}

#Preview("Disabled")
{
    @Previewable @State var sourceURL: URL? = nil
    @Previewable @State var folderSelected: Bool = false
    // disabled selection
    @Previewable @State var sourceEnabled: Bool = false
    @Previewable @State var fileSetBySize: FileSetBySize = FileSetBySize()

    // no file, disabled
    FolderSelectionView( sourceURL: $sourceURL,
                         folderSelected: $folderSelected,
                         sourceEnabled: $sourceEnabled,
                         fileSetBySize: $fileSetBySize )
}

