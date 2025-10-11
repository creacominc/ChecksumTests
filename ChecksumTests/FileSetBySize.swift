//
//  FileSetBySize.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import Foundation

// class representing a map of sets of files collected by size
class FileSetBySize: Codable
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
        fileSetsBySize.keys.sorted()
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
}
