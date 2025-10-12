//
//  FileSetBySize.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import Foundation

// class representing a map of sets of files collected by size
@Observable
class FileSetBySize
{
    private(set) var fileSetsBySize: [Int: [MediaFile]] = [:]
    
    // MARK: - Subscript Access
    
    /// Direct subscript access - returns copy of array for safety
    subscript (size: Int) -> [MediaFile]? {
        get {
            fileSetsBySize[size]
        }
        set {
            fileSetsBySize[size] = newValue
        }
    }
    
    // MARK: - Efficient Mutations
    
    /// Appends a file to the set for its size - no unnecessary copying
    func append(_ file: MediaFile) {
        let size = file.fileSize
        // Using default parameter is more efficient - avoids copy-on-write overhead
        fileSetsBySize[size, default: []].append(file)
    }
    
    /// Appends multiple files - more efficient than calling append repeatedly
    func append<S: Sequence>(contentsOf files: S) where S.Element == MediaFile {
        for file in files {
            fileSetsBySize[file.fileSize, default: []].append(file)
        }
    }
    
    /// Removes all files from the collection
    func removeAll() {
        fileSetsBySize.removeAll()
    }
    
    /// Replaces all contents with another FileSetBySize - O(1) operation
    func replaceAll(with other: FileSetBySize) {
        print("replaceAll called: replacing \(self.totalFileCount) files with \(other.totalFileCount) files")
        fileSetsBySize = other.fileSetsBySize
        print("After replaceAll: now have \(self.totalFileCount) files")
    }
    
    // MARK: - Efficient Read Access (no array copying)
    
    /// Returns count of files for a given size without copying the array
    func count(for size: Int) -> Int {
        fileSetsBySize[size]?.count ?? 0
    }
    
    /// Checks if any files exist for a given size
    func contains(size: Int) -> Bool {
        fileSetsBySize[size] != nil
    }
    
    /// Returns all unique file sizes in the collection
    var allSizes: [Int] {
        Array(fileSetsBySize.keys)
    }
    
    /// Returns sorted array of sizes (useful for iteration)
    var sortedSizes: [Int] {
        // print( "number of keys: \(fileSetsBySize.count)" )
        // print( "keys: \(fileSetsBySize.keys)" )
        return fileSetsBySize.keys.sorted()
    }
    
    /// Iterates over files of a given size without copying the array
    func forEach(for size: Int, _ body: (MediaFile) throws -> Void) rethrows {
        if let files = fileSetsBySize[size] {
            try files.forEach(body)
        }
    }
    
    /// Total count of all files across all sizes
    var totalFileCount: Int {
        fileSetsBySize.values.reduce(0) { $0 + $1.count }
    }
    
    /// Returns only sizes that have multiple files (potential duplicates)
    var sizesWithMultipleFiles: [Int] {
        fileSetsBySize.filter { $0.value.count > 1 }.map { $0.key }
    }
    
    /// Returns only sizes that have only one file (definiately unique)
    var sizesWithOnlyOneFile: [Int] {
        fileSetsBySize.filter { $0.value.count == 1 }.map { $0.key }
    }


    private func getChecksumSizes( size: Int ) -> [Int]
    {
        // Create a list of Int sizes for checksums, logarithmically spaced
        var checksumSizes: [Int] = []
        
        let minChunk = 128
        let maxSize = size + minChunk
        
        // We want to start at 128 and go up to maxSize, using logarithmic spacing
        if maxSize <= minChunk * 2
        {
            checksumSizes = [minChunk, maxSize].filter { $0 <= maxSize }
        }
        else
        {
            let stepCount = 5
            let logMin = log(Double(minChunk))
            let logMax = log(Double(maxSize))
            // At least 5 steps, more as size increases
            for i in 0..<stepCount
            {
                let fraction = Double(i) / Double(stepCount - 1)
                let value = max( exp(logMin + fraction * (logMax - logMin)), Double(minChunk) )
                let roundedValue = (Int(value) / minChunk) * minChunk  // round to nearest 128 bytes
                if roundedValue <= maxSize
                {
                    if checksumSizes.last != roundedValue
                    {
                        checksumSizes.append(roundedValue)
                    }
                }
            }
            // Make sure maxSize is included
            if let last = checksumSizes.last, last < maxSize
            {
                checksumSizes.append(maxSize)
            }
        }
        return checksumSizes
    }


    // get bytes needed to determine uniqueness of all files in all sets
    // return a map of file sizes and the bytes needed to ensure uniqueness
    public func getBytesNeededForUniqueness(currentLevel: @escaping (Int) -> Void = { _ in }, 
                                           maxLevel: @escaping (Int) -> Void = { _ in },
                                           shouldCancel: @escaping () -> Bool = { false }) -> [Int:Int]
    {
        // map to be returned.
        var bytesNeeded: [Int:Int] = [:]

        // Mark files as unique where there is only one file for that size
        for (_, files) in fileSetsBySize where files.count == 1 {
            files.first!.isUnique = true
        }

        // Get all sizes that need processing (sizes with multiple files)
        let sizesToProcess: [Int] = fileSetsBySize.filter { $0.value.count > 1 }.map { $0.key }
        let totalSizes: Int = sizesToProcess.count
        
        // Update max level on main thread
        DispatchQueue.main.async {
            maxLevel(totalSizes)
            currentLevel(0)
        }
        
        var processedCount = 0

        // for each size of file
        for fileSize in sizesToProcess
        {
            // Check for cancellation
            if shouldCancel() {
                print("Processing cancelled at size \(fileSize)")
                break
            }

            // if the set has more than one file...
            let filesAtSize = fileSetsBySize[fileSize]!
            let fileCount = filesAtSize.count
            let uniquePathCount = Set(filesAtSize.map { $0.fileUrl.path() }).count
            print("Processing size \(fileSize) with \(fileCount) files (\(uniquePathCount) unique paths)")
            
            // Warn if there are duplicate file objects
            if fileCount != uniquePathCount {
                print("  WARNING: \(fileCount - uniquePathCount) duplicate file objects detected!")
            }
            
            let checksumSizes: [Int] = getChecksumSizes(size: fileSize)
            var checksumSizeHandled: Int = 0
            // for every checksum size
            for checksumSize in checksumSizes
            {
                // Check for cancellation
                if shouldCancel() {
                    break
                }
                
                // Create a fresh set for each checksum size
                var uniqueChecksums: Set<Data> = []
                
                // print( "checksumSize == \(checksumSize)" )
                // iterate until the files for this size == the size of the set of unique checksums
                for file in fileSetsBySize[fileSize]!
                {
                    let checksumData = file.computeChecksum(size: checksumSize).data(using: .utf8)!
                    uniqueChecksums.insert(checksumData)
                }
                checksumSizeHandled = checksumSize
                // stop if the number of uniqueChecksums == the number of files
                if uniqueChecksums.count == fileSetsBySize[fileSize]!.count
                {
                    print( "Size \(fileSize): Found uniqueness at \(checksumSize) bytes for \(fileSetsBySize[fileSize]!.count) files" )
                    bytesNeeded[fileSize] = checksumSize
                    // break out of for loop
                    break
                }
            } // for checksumSizes
            
            // Check if we never found uniqueness
            if bytesNeeded[fileSize] == nil
            {
                let filesAtSize = fileSetsBySize[fileSize]!
                let uniquePaths = Set(filesAtSize.map { $0.fileUrl.path() })
                
                print( "Size \(fileSize): WARNING - Could not distinguish all files even at maximum checksum size: \(checksumSizeHandled)" )
                print( "  Total file objects: \(filesAtSize.count), Unique paths: \(uniquePaths.count)" )
                
                // Check for duplicate file objects (same path appearing multiple times)
                if filesAtSize.count != uniquePaths.count {
                    print( "  ERROR: Found \(filesAtSize.count - uniquePaths.count) duplicate file objects in the array!" )
                }
                
                 // print the checksums for and the paths to the duplicate files
                 for file in filesAtSize
                 {
                     file.isUnique = false
                     print(
                        "\tSize: \(fileSize), \t\(file.checksums.max(by: <)!)  :  \(file.fileUrl.path())"
                     )
                 }
            }
            
            // Update progress after processing each size
            processedCount += 1
            DispatchQueue.main.async {
                currentLevel(processedCount)
            }
        } // for each size
        return bytesNeeded
    }


    public func extensions() -> [String]
    {
        // return a sorted list of extensions from all files in all sizes
        var allExtensions: Set<String> = []
        for (_, fileSet) in self.fileSetsBySize
        {
            for file in fileSet
            {
                if let fileExtension = URL(fileURLWithPath: file.fileUrl.path).pathExtension.split(separator: ".").last
                {
                    allExtensions.insert(String(fileExtension))
                }
            }
        }
        return allExtensions.sorted(by: <)
    }
}
