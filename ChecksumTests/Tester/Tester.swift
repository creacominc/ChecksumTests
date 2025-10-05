//
//  Tester.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-04.
//

import Foundation


/**
 * Tester - represents a process for testing two folders for duplicates
 *
 * - Find all the media files (photo, audio, video) in a source folder and create a collection of file objects;
 * - Group the file objects into years to allow for sharding of the larger set of files in the target folder;
 * - Initial use of this will be to determine the fastest way of finding unique files by comparing times for
 * testing using various sizes of checksums and measuring the rate of distinction.
 *
 */
class Tester
{
    private var sourceURL: URL?
    private var fileCount: Double = 0.0
    private var fileCountByType: [String: Int] = [:]
    
    /**
     * Initialize the Tester with a source URL
     * - Parameter sourceURL: The URL of the source directory
     */
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        resetStats()
    }
    
    /**
     * Reset the file count statistics
     */
    private func resetStats() {
        fileCount = 0.0
        fileCountByType = [:]
        // Initialize counts for each file type
        for fileType in FileType.allCases {
            fileCountByType[fileType.rawValue] = 0
        }
    }
    
    /**
     * Get the current file count
     */
    func getFileCount() -> Double {
        return fileCount
    }
    
    /**
     * Get the current file count by type
     */
    func getFileCountByType() -> [String: Int] {
        return fileCountByType
    }
    
    // File type categories
    enum FileType: String, CaseIterable {
        case photo = "photo"
        case audio = "audio"
        case video = "video"
        case other = "other"
        
        var fileExtensions: [String] {
            switch self {
            case .photo:
                return ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif",
                        "heic", "heif", "webp", "raw", "cr2", "nef", "arw",
                        "rw2"]
            case .audio:
                return ["mp3", "wav", "aac", "flac", "ogg", "m4a", "wma", "aiff", "au"]
            case .video:
                return ["mp4", "avi", "mov", "wmv", "flv", "webm", "mkv",
                        "m4v", "3gp", "ogv", "dng", "braw"]
            case .other:
                return []
            }
        }
    }
    
    /**
     * Get the total number of files and breakdown by file type in the source directory
     * This method sets the internal fileCount and fileCountByType properties
     */
    func getNumberOfFiles() {
        guard let sourceURL = sourceURL else {
            print("No source URL set")
            return
        }
        
        // Reset stats before counting
        resetStats()
        
        do {
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(at: sourceURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])
            
            while let fileURL = enumerator?.nextObject() as? URL {
                let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                
                if resourceValues.isRegularFile == true {
                    fileCount += 1
                    
                    let fileExtension = fileURL.pathExtension.lowercased()
                    var categorized = false
                    
                    // Check each file type
                    for fileType in FileType.allCases where fileType != .other {
                        if fileType.fileExtensions.contains(fileExtension) {
                            fileCountByType[fileType.rawValue] = (fileCountByType[fileType.rawValue] ?? 0) + 1
                            categorized = true
                            break
                        }
                    }
                    
                    // If not categorized, add to "other"
                    if !categorized {
                        fileCountByType[FileType.other.rawValue] = (fileCountByType[FileType.other.rawValue] ?? 0) + 1
                    }
                }
            }
        } catch {
            print("Error scanning directory: \(error.localizedDescription)")
        }
    }
}


