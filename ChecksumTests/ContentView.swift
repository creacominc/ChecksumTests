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

    var body: some View {
        VStack() {
            HStack {
                Button("Source") {
                    // create file open dialog to select a folder
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = false
//                    panel.allowedContentTypes = [
//                        // photo
//                        .jpeg, .png, .tiff, .rawImage,
//                        // audio
//                        .wav, .aiff, .mp3,
//                        // video
//                        .avi, .movie,
//                    ]
                    panel.message = "Select source directory containing media files"
                    if panel.runModal() == .OK, let url = panel.url {
                        sourceURL = url
                        targetEnabled = true
                    }
                }
                .disabled( !sourceEnabled )
                Text( sourceURL?.absoluteString ?? "Select Source Folder" )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Button("Target") {
                    // create file open dialog to select a folder
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = false
                    panel.message = "Select target directory containing media files"
                    if panel.runModal() == .OK, let url = panel.url {
                        targetURL = url
                    }
                }
                .disabled( !targetEnabled )
                Text( targetURL?.absoluteString ?? "Select Target Folder" )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding( )
        Spacer()
    }
}

#Preview {
    ContentView()
}
