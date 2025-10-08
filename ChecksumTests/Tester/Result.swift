//
//  Result.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-07.
//

/**
 * result data
 * - size:  size of checksum data
 * - count:  number of files smaller than this size
 * - time:  average time per file
 */

class Result
{
    private var size: Int = 0
    private var count: Int = 0
    private var time: Double = 0.0

    init(size: Int, count: Int, time: Double)
    {
        self.size = size
        self.count = count
        self.time = time
    }

    func getSizeFormatted() -> String
    {
        MultiThumbSlider.formatBytes( Double(size) )
    }

    func getSize() -> Int {
        return size
    }
    
    func getTime() -> Double {
        return time
    }
    
    func getCount() -> Int {
        return count
    }
}
