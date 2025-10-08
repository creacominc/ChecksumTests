//
//  ResultSet.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-07.
//

/**
 * set of results
 * total time
 * file count
 *
 */

struct ResultSet
{

    var results: [Result]
    var totalTime: Double
    var fileCount: Int

    init()
    {
        results = []
        totalTime = 0.0
        fileCount = 0
    }
    
    var isEmpty: Bool {
        return results.isEmpty
    }
    
    func sorted(by areInIncreasingOrder: (Result, Result) -> Bool) -> [Result] {
        return results.sorted(by: areInIncreasingOrder)
    }
    
}
