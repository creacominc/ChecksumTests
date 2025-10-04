//
//  ContentView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-04.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View {
    @State var sourceURL: URL?
    @State var targetURL: URL?
    @State var sourceEnabled: Bool = true
    @State var targetEnabled: Bool = false
    let numberOfChecksumSizes: Int = 6
    @State var checksumSizes: [UInt] = [1, 2, 16, 256, 1024, 65536]

    var body: some View
    {
        VStack()
        {
            // folder picker
            HStack
            {
                Button("Source")
                {
                    // create file open dialog to select a folder
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = false
                    panel.message = "Select test directory containing media files"
                    if panel.runModal() == .OK, let url = panel.url {
                        sourceURL = url
                        targetEnabled = true
                    }
                }
                .disabled( !sourceEnabled )
                Text( sourceURL?.absoluteString ?? "Select Source Folder" )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            // checksum sizes
            HStack
            {
                
            }
            // process button
            HStack
            {
                Button("Process")
                {
                    
                }
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
