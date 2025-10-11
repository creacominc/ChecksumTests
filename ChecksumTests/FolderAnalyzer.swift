//
//  FolderAnalyzer.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import Foundation

/// Observable class to handle folder analysis on background thread
@Observable
class FolderAnalyzer
{
    var isAnalyzing: Bool = false
    var fileCount: Int = 0
    var totalSize: Int64 = 0
    var fileSizeDistribution: [String: Int] = [:]
    
    func analyzeFolderStats(url: URL)
    {
        isAnalyzing = true
        fileCount = 0
        totalSize = 0
        fileSizeDistribution = [:]
        
        // Perform analysis on background queue (Swift 6 requirement)
        DispatchQueue.global(qos: .userInitiated).async {
            var count = 0
            var size: Int64 = 0
            
            do {
                let fileManager = FileManager.default
                
                if let enumerator = fileManager.enumerator(
                    at: url,
                    includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
                    options: [.skipsHiddenFiles]
                )
                {
                    for case let fileURL as URL in enumerator
                    {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
                        
                        if let isRegularFile = resourceValues.isRegularFile, isRegularFile {
                            count += 1
                            
                            if let fileSize = resourceValues.fileSize {
                                size += Int64(fileSize)
                            }
                        }
                    }
                }
                
                // Update properties on main thread
                DispatchQueue.main.async {
                    self.fileCount = count
                    self.totalSize = size
                    self.isAnalyzing = false
                }
            } catch {
                print("Error analyzing folder: \(error)")
                DispatchQueue.main.async {
                    self.isAnalyzing = false
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

