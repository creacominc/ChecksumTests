//
//  File.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-04.
//

import Foundation
import AppKit
import CryptoKit

class File
{
    /**
     * The File class represents a file object which contains the file name, creation date,
     * modification date, file type, size, and checksums
     *
     * - Parameter fileName: The name of the file
     * - Parameter creationDate: The creation date of the file
     * - Parameter modificationDate: The modification date of the file
     * - Parameter fileType: The type of the file
     * - Parameter size: The size of the file
     */
    private var fileName: String
    private var fileExtension: String
    private var fileType: FileType = .other
    private var m_size: Int
    
    private var creationDate: Date
    private var modificationDate: Date
    private var dateSinceEpochMod: Double
    private var checksums: [ Int: String ] = [:]
    private var checksumsCompleted : Bool = false

    init( url: URL ) throws
    {
        self.fileName = url.path
        self.fileExtension = url.pathExtension.lowercased()
        
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let size = attributes[.size] as? Int else {
            throw FileError.invalidFileSize
        }
        self.m_size = size
        
        
        self.fileType = FileType.other
        for fileType in FileType.allCases where fileType != .other
        {
            if fileType.fileExtensions.contains(fileExtension)
            {
                self.fileType = fileType
                break
            }
        }
        
        self.creationDate = attributes[.creationDate] as! Date
        self.modificationDate = attributes[.modificationDate] as! Date
        // using the earlier of the creation and modification dates, save the date as seconds since the epoch / seconds in 1 month
        self.dateSinceEpochMod = min(creationDate.timeIntervalSince1970.rounded(.down),
                                     modificationDate.timeIntervalSince1970.rounded(.down)).rounded(.down) / 2_629_746
        self.checksums = [:]
        self.checksumsCompleted = false
    } // init
    
    
    public func key() -> Double
    {
        return dateSinceEpochMod
    }
    
    public func type() -> String
    {
        return fileType.rawValue
    }
    
    // File type categories
    public enum FileType: String, CaseIterable
    {
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
     * return true if checksum is performed.
     */
    public func checksum( size: Int ) -> Bool
    {
        // return false if no further checksums are needed.
        guard self.checksumsCompleted == false else { return false }
        // read 'size' bytes of the file and compute a checksum
        guard let file : FileHandle = FileHandle(forReadingAtPath: fileName) else {
            print( "checksum:  failed to get file handle.  fileName = \(fileName)")
            return false
        }
        // print( "checksum:  size = \(size),  file size = \(self.size)")
        file.seek(toFileOffset: 0)
        let data : Data = file.readData(ofLength: size)
        // compute checksum using SHA256
        let hash = SHA256.hash(data: data)
        let checksum = hash.compactMap { String(format: "%02x", $0) }.joined()
        self.checksums[size] = checksum
        // mark the checksums as completed if the checksum size exceeds the file size
        self.checksumsCompleted = ( size > self.m_size )
        file.closeFile()
        return true
    }
    
    public func name() -> String
    {
        return self.fileName
    }

    public func size() -> Int
    {
        return self.m_size
    }
    
}

enum FileError: Error, LocalizedError
{
    case invalidFileSize
    case invalidCreationDate
    case invalidModificationDate
    case fileNotFound
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .invalidFileSize:
            return "Invalid file size"
        case .invalidCreationDate:
            return "Invalid creation date"
        case .invalidModificationDate:
            return "Invalid modification date"
        case .fileNotFound:
            return "File not found"
        case .permissionDenied:
            return "Permission denied"
        }
    }
}
