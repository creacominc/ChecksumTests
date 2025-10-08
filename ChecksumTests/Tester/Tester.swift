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
        getNumberOfFiles()
    }
    
    /**
     * Reset the file count statistics
     */
    private func resetStats() {
        self.fileCount = 0.0
        self.fileCountByType = [:]
        // Initialize counts for each file type
        for fileType in File.FileType.allCases {
            self.fileCountByType[fileType.rawValue] = 0
        }
        self.fileCollection = [:]
    }
    
    /**
     * Get the current file count
     */
    func getFileCount() -> Double {
        return self.fileCount
    }
    
    /**
     * Get the current file count by type
     */
    func getFileCountByType() -> [String: Int] {
        return self.fileCountByType
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

    public func process( thresholds: [Int], progressCallback: @escaping (Double, String) -> Void ) -> ResultSet
    {
        progressCallback(0.0, "Processing")
        // reset all stats and file info:
        getNumberOfFiles()
        // start a timer for the overall process
        let startTime = Date()
        // results in the form of time per file and checksum size
        var resultSet : ResultSet = ResultSet()
        // for each checksum size
        for index : Int in thresholds.indices
        {
            let threshold : Int = thresholds[index]
            let statusText = "Processing \(MultiThumbSlider.formatBytes(Double(threshold)))"
            progressCallback(100.0 * Double(index) / Double(thresholds.count), statusText)
            
            // let nextThreshosld = (index + 1 < thresholds.count) ? thresholds[index + 1] : threshold
            // print( "Threshold: \(threshold)" )
            var fileCountByThreshold : Int = 0
            // files smaller or equal in size to this threshold - they need no larger threshold
            var filesSmallerThanThreadhold : Int = 0
            // start a timer for the checksum size
            let thresholdStartTime = Date()
            // compute the checksum using this size in bytes for each file
            var processedFiles = 0
            let totalFiles = fileCollection.values.reduce(0) { $0 + $1.count }
            
            for files: [File] in fileCollection.values
            {
                // print( "Files in this date group: \(files.count)" )
                for file in files
                {
                    filesSmallerThanThreadhold += (file.size() <= Int(threshold)) ? 1 : 0
                    // compute the checksum using this size in bytes for each file
                    let checked : Bool = file.checksum( size: Int(threshold) )
                    if checked
                    {
                        fileCountByThreshold += 1
                        // print( "File: \(file.key()), \(file.name()) checked" )
                    }
                    // update the progress periodically (every 100 files)
                    processedFiles += 1
                    if processedFiles % 100 == 0 {
                        let baseProgress = 100.0 * Double(index) / Double(thresholds.count)
                        let stepProgress = (100.0 / Double(thresholds.count)) * (Double(processedFiles) / Double(totalFiles))
                        progressCallback(baseProgress + stepProgress, statusText)
                    }
                } // files
            } // fileCollection.values
            // save the size and time in a map by size
            let thresholdEndTime : Date = Date()
            let thresholdTime : Double = thresholdEndTime.timeIntervalSince(thresholdStartTime)
            let thresholdTimePerFile : Double = thresholdTime / Double(fileCountByThreshold)
            print(
                "Threshold size: \(MultiThumbSlider.formatBytes(Double(threshold))),  time: \(thresholdTime) seconds for \(fileCountByThreshold) files,  average time per file: \(thresholdTimePerFile) seconds,  filesSmallerThanThreadhold: \(filesSmallerThanThreadhold)"
            )
            // update results
            resultSet.results.append(
                    Result(
                        size: threshold,
                        count: filesSmallerThanThreadhold,
                        time: thresholdTimePerFile
                    )
                )
        } // thresholds.indices
        // save the total time
        let endTime = Date()
        let totalTime = endTime.timeIntervalSince(startTime)
        resultSet.totalTime = totalTime
        resultSet.fileCount = fileCollection.values.count
        let finalStatus = "Total time: \(String(format: "%.2f", totalTime)) seconds"
        print(finalStatus)
        progressCallback(100.0, finalStatus)
        return resultSet
    }
    
}


