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
     *  Define a  file collection as follows:
     *  A file collection is a set of files where an integer value is the key.
     *  The integer value is the earlier of the creation and modification times in seconds 
     * since the epoch modded by the seconds in 1 month.  This allows us to collect files 
     * in the same element of the set that are within the same time period of 1 month (roughtly)
     * and to search for files within a 6 month window by iterating through the set.
     *  The value of the set is a file object which contains the file name, creation date,
     *  modification date, file type, size, and checksums.
     */
    private var fileCollection: [Double: [File]] = [:]



    /**
     * Initialize the Tester with a source URL
     * - Parameter sourceURL: The URL of the source directory
     */
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        //resetStats()
        getNumberOfFiles()
    }
    
    /**
     * Reset the file count statistics
     */
    private func resetStats() {
        fileCount = 0.0
        fileCountByType = [:]
        // Initialize counts for each file type
        for fileType in File.FileType.allCases {
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
    
    /**
     * Get the total number of files and breakdown by file type in the source directory
     * This method sets the internal fileCount and fileCountByType properties
     */
    private func getNumberOfFiles()
    {
        guard let sourceURL = sourceURL else {
            print("No source URL set")
            return
        }
        
        // Reset stats before counting
        resetStats()
        
        do
        {
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(
                at: sourceURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            // for each file in the folder ...
            while let fileURL = enumerator?.nextObject() as? URL
            {
                let resourceValues = try fileURL.resourceValues(
                    forKeys: [.isRegularFileKey]
                )
                if resourceValues.isRegularFile == true
                {
                    // create the file object
                    do
                    {
                        let file = try File( url: fileURL )
                        // if the file key is not found in the fileCollection
                        if self.fileCollection[file.key()] == nil
                        {
                            self.fileCollection[file.key()] = [file]
                        }
                        else
                        {
                            self.fileCollection[file.key()]?.append( file )
                        }
                        self.fileCount += 1
                        let type: String = file.type()
                        fileCountByType[type] = (fileCountByType[type] ?? 0) + 1
                    }
                    catch
                    {
                        print("Failed to create File for \(fileURL.path): \(error.localizedDescription)")
                    }
                }
            }
        }
        catch
        {
            print("Error scanning directory: \(error.localizedDescription)")
        }
    }

    public func process()
    {
        // for each file
        // get the creation and modification dates and keep the earlier one
        // save the earlier of the two dates as a unix time mod the seconds in 6 months

        // for each file
    }
    
}


