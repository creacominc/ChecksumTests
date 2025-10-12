//
//  FileExtensionsHandledView.swift
//  ChecksumTests
//
//  Created by Harold Tomlinson on 2025-10-12.
//

import SwiftUI

struct FileExtensionsHandledView: View
{
    // [in] fileSetBySize - files grouped by size
    @Binding var fileSetBySize: FileSetBySize

    var body: some View
    {
        let extensions: [String] = fileSetBySize.extensions()
        let itemsPerRow = 8
        let numberOfRows = (extensions.count + itemsPerRow - 1) / itemsPerRow
        
        // list of extensions in the FileSetBySize, 8 per row
        VStack
        {
            ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                HStack
                {
                    ForEach(0..<itemsPerRow, id: \.self) { columnIndex in
                        let index = rowIndex * itemsPerRow + columnIndex
                        if index < extensions.count
                        {
                            Text(extensions[index])
                        }
                        else
                        {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

#Preview
{
    @Previewable @State var fileSetBySize: FileSetBySize = FileSetBySize()
    FileExtensionsHandledView(
        fileSetBySize: $fileSetBySize
    )
}
