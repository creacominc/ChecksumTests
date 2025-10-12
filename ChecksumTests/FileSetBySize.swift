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
        fileSetsBySize = other.fileSetsBySize
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
        var bytesNeeded: [Int:Int] = [:]

        // Get all sizes that need processing (sizes with multiple files)
        let sizesToProcess = fileSetsBySize.filter { $0.value.count > 1 }.map { $0.key }
        let totalSizes = sizesToProcess.count
        
        // Update max level on main thread
        DispatchQueue.main.async {
            maxLevel(totalSizes)
            currentLevel(0)
        }
        
        var processedCount = 0

        // for each size
        for size in sizesToProcess
        {
            // Check for cancellation
            if shouldCancel() {
                print("Processing cancelled at size \(size)")
                break
            }
            
            // if the set has more than one file...
            // create a set for the checksums
            var uniqueChecksums: Set<Data> = []
            let checksumSizes: [Int] = getChecksumSizes(size: size)
            // for every size
            for checksumSize in checksumSizes
            {
                // Check for cancellation
                if shouldCancel() {
                    break
                }
                
                // print( "checksumSize == \(checksumSize)" )
                // iterate until the files for this size == the size of the set of unique checksums
                for file in fileSetsBySize[size]!
                {
                    let checksumData = file.computeChecksum(size: checksumSize).data(using: .utf8)!
                    uniqueChecksums.insert(checksumData)
                }
                // stop if the number of uniqueChecksums == the number of files
                if uniqueChecksums.count == fileSetsBySize[size]!.count
                {
                    print( "uniqueChecksums.count == fileSetsBySize[size]!.count == \(fileSetsBySize[size]!.count)" )
                    bytesNeeded[size] = checksumSize
                    // break out of for loop
                    break
                }
            } // for checksumSizes
            
            // Update progress after processing each size
            processedCount += 1
            DispatchQueue.main.async {
                currentLevel(processedCount)
            }
        } // for each size
        return bytesNeeded
    }
    
}
