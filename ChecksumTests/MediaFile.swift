//
//  MediaFile.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-11.
//

import Foundation
import CryptoKit

// a class representing a media file to be analysed.
class MediaFile
{
    let fileUrl: URL
    let fileSize: Int
    var isUnique: Bool = false
    var checksums: [Int: String] = [:]
    
    init(fileUrl: URL, fileSize: Int)
    {
        self.fileUrl = fileUrl
        self.fileSize = fileSize
    }
    
    public func computeChecksum( size: Int ) -> String
    {
        do
        {
            let fileHandle = try FileHandle( forReadingFrom: fileUrl )
            defer { try? fileHandle.close() }
            if let data = try fileHandle.read(upToCount: size)
            {
                checksums[size] = SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
            }
        }
        catch(let e)
        {
            print("Error: \(e)")
        }
        return checksums[size, default: ""]
    }

    
}
