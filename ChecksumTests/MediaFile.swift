//
//  MediaFile.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import Foundation

// a class representing a media file to be analysed.
class MediaFile: Codable
{
    let fileName: String
    let fileSize: Int
    
    init(fileName: String, fileSize: Int)
    {
        self.fileName = fileName
        self.fileSize = fileSize
    }
}
