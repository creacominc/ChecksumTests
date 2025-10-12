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
    private var currentAnalysisURL: URL?
    
    func analyzeFolderStats(url: URL, into fileSetBySize: FileSetBySize, completion: (() -> Void)? = nil)
    {
        // Prevent concurrent analyses
        guard !isAnalyzing else {
            print("Analysis already in progress for: \(currentAnalysisURL?.path ?? "unknown"), skipping request for: \(url.path)")
            return
        }
        
        isAnalyzing = true
        currentAnalysisURL = url
        fileCount = 0
        totalSize = 0
        fileSizeDistribution = [:]
        
        print("=== Starting folder analysis for: \(url.path) ===")
        
        // Perform analysis on background queue (Swift 6 requirement)
        DispatchQueue.global(qos: .userInitiated).async
        {
            var count = 0
            var size: Int64 = 0
            let mediaFiles = FileSetBySize()  // Temporary collection for background thread
            var pathsSeen = Set<String>()  // Track paths we've already added
            
            do
            {
                // create a file manager to iterate over files
                let fileManager = FileManager.default
                // create the enumerator on the file manager using the url
                if let enumerator = fileManager.enumerator(
                    at: url,
                    includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey, .isDirectoryKey, .contentTypeKey],
                    options: [.skipsHiddenFiles]
                )
                {
                    for case let fileURL as URL in enumerator
                    {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey, .fileSizeKey, .contentTypeKey])

                        // Check if this is a directory - potentially a CinemaDNG folder
                        if let isDirectory = resourceValues.isDirectory, isDirectory {
                            // Check if this looks like a CinemaDNG folder
                            if self.isCinemaDNGFolder(url: fileURL, fileManager: fileManager) {
                                print("Skipping CinemaDNG folder: \(fileURL.lastPathComponent)")
                                enumerator.skipDescendants()
                            }
                            continue
                        }

                        // Only process regular files (not directories)
                        guard let isRegularFile = resourceValues.isRegularFile, isRegularFile else {
                            continue
                        }
                        // Check if file is a media file (audio, video, or image)
                        var isMediaFile: Bool = false
                        if let contentType = resourceValues.contentType
                        {
                            isMediaFile = contentType.conforms(to: .audio) ||
                                        contentType.conforms(to: .video) ||
                                        contentType.conforms(to: .image)
                        }
                        // Fallback: Check file extension for common media formats
                        let mediaExtensions = [
                                            "jpg", "braw", "mov", "rw2", "mp4", "dng", "r3d", 
                                            "crm", "cr3", "cr2", "crw", "raw", 
                                            "jpeg", "png", "gif", "heic", "tif", "tiff", 
                                            "nef", "arw", "orf",
                                            "avi", "mkv", "m4v", "mpg", "mpeg",
                                            "mp3", "wav", "aac", "m4a", "flac",
                                            "heif", "webp"
                                             ]
                        let ext = fileURL.pathExtension.lowercased()
                        isMediaFile = isMediaFile || mediaExtensions.contains(ext)

                        if isMediaFile, let fileSize = resourceValues.fileSize
                        {
                            let filePath = fileURL.path
                            
                            // Check if we've already seen this path
                            if pathsSeen.contains(filePath) {
                                print("WARNING: FileManager returned duplicate path: \(filePath)")
                            } else {
                                pathsSeen.insert(filePath)
                                count += 1
                                size += Int64(fileSize)
                                // Create MediaFile and add to temporary collection
                                let mediaFile = MediaFile(fileUrl: fileURL, fileSize: fileSize)
                                mediaFiles.append(mediaFile)
                            }
                        }
                    }
                }
                
                // Update properties and fileSetBySize on main thread
                DispatchQueue.main.async {
                    // Verify URL hasn't changed during analysis
                    guard self.currentAnalysisURL == url else {
                        print("=== Analysis for \(url.path) discarded - URL changed during analysis ===")
                        self.isAnalyzing = false
                        self.currentAnalysisURL = nil
                        return
                    }
                    
                    self.fileCount = count
                    self.totalSize = size
                    print("Analyzed:  count = \(count),  size = \(size)")
                    print("=== Calling replaceAll with \(mediaFiles.totalFileCount) files ===")

                    // Replace entire collection - O(1) operation, no copying
                    fileSetBySize.replaceAll(with: mediaFiles)
                    
                    print("=== After replaceAll, fileSetBySize has \(fileSetBySize.totalFileCount) files ===")
                    
                    self.isAnalyzing = false
                    self.currentAnalysisURL = nil
                    
                    // Call completion handler after analysis is done
                    completion?()
                }
            } catch {
                print("Error analyzing folder: \(error)")
                DispatchQueue.main.async {
                    self.isAnalyzing = false
                    self.currentAnalysisURL = nil
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
        currentAnalysisURL = nil
    }
    
    // MARK: - Private Helper Methods
    
    /// Detects if a folder is a CinemaDNG folder by checking for characteristic file patterns
    private func isCinemaDNGFolder(url: URL, fileManager: FileManager) -> Bool {
        do {
            // Get the contents of the directory (non-recursively)
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            // Look for .dng files with sequential numbering pattern
            let dngFiles = contents.filter { $0.pathExtension.lowercased() == "dng" }
            
            // If we have multiple .dng files, check if they follow the pattern
            if dngFiles.count > 3 {
                // Check if files have the pattern: prefix_NNNNNN.dng
                let hasSequentialPattern = dngFiles.allSatisfy { fileURL in
                    let fileName = fileURL.deletingPathExtension().lastPathComponent
                    // Check if the file name ends with _NNNNNN (underscore followed by 6 digits)
                    let pattern = /^.+_\d{6}$/
                    return fileName.wholeMatch(of: pattern) != nil
                }
                
                if hasSequentialPattern {
                    print("Detected CinemaDNG folder pattern in: \(url.lastPathComponent)")
                    return true
                }
            }
            
            return false
        } catch {
            // If we can't read the directory, don't skip it
            return false
        }
    }
}

