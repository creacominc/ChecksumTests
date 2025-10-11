//
//  FolderAnalyzer.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import Foundation
internal import UniformTypeIdentifiers

/// Observable class to handle folder analysis on background thread
@Observable
class FolderAnalyzer
{
    var isAnalyzing: Bool = false
    var fileCount: Int = 0
    var totalSize: Int64 = 0
    var fileSizeDistribution: [String: Int] = [:]
    
    func analyzeFolderStats(url: URL, into fileSetBySize: FileSetBySize, completion: (() -> Void)? = nil)
    {
        isAnalyzing = true
        fileCount = 0
        totalSize = 0
        fileSizeDistribution = [:]
        
        // Perform analysis on background queue (Swift 6 requirement)
        DispatchQueue.global(qos: .userInitiated).async
        {
            var count = 0
            var size: Int64 = 0
            let mediaFiles = FileSetBySize()  // Temporary collection for background thread
            
            do
            {
                // create a file manager to iterate over files
                let fileManager = FileManager.default
                // create the enumerator on the file manager using the url
                if let enumerator = fileManager.enumerator(
                    at: url,
                    includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey, .contentTypeKey],
                    options: [.skipsHiddenFiles]
                )
                {
                    for case let fileURL as URL in enumerator
                    {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey, .contentTypeKey])
                        
                        // Only process regular files (not directories)
                        guard let isRegularFile = resourceValues.isRegularFile, isRegularFile else {
                            continue
                        }
                        
                        // Check if file is a media file (audio, video, or image)
                        if let contentType = resourceValues.contentType
                        {
                            let isMediaFile = contentType.conforms(to: .audio) ||
                                              contentType.conforms(to: .video) ||
                                              contentType.conforms(to: .image)
                            
                            if isMediaFile, let fileSize = resourceValues.fileSize
                            {
                                count += 1
                                size += Int64(fileSize)
                                // print("Analyzing: \(fileURL.path()) - \(fileSize) bytes,   count = \(count),  size = \(size)")
                                // Create MediaFile and add to temporary collection
                                let mediaFile = MediaFile(fileName: fileURL.path(), fileSize: fileSize)
                                mediaFiles.append(mediaFile)
                            }
                        }
                    }
                }
                
                // Update properties and fileSetBySize on main thread
                DispatchQueue.main.async {
                    self.fileCount = count
                    self.totalSize = size
                    print("Analyzed:  count = \(count),  size = \(size)")

                    // Replace entire collection - O(1) operation, no copying
                    fileSetBySize.replaceAll(with: mediaFiles)
                    
                    self.isAnalyzing = false
                    
                    // Call completion handler after analysis is done
                    completion?()
                }
            } catch {
                print("Error analyzing folder: \(error)")
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    completion?()
                }
            }
        }
    }
    
    func reset()
    {
        fileCount = 0
        totalSize = 0
        fileSizeDistribution = [:]
    }
}

