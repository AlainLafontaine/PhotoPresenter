//
//  LinkDirectoryToFileDirectoryInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-01-18.
//

import SwiftUI

struct LinkDirectoryToFileDirectoryInfo: Identifiable, Codable, Hashable  {
    let id: UUID
    let directoryIndex: Int
    var fileInfos: [FileDirectoryInfo]
    
    
    init(
        id: UUID = UUID(),
        directoryIndex: Int,
        fileInfos: [FileDirectoryInfo]
    ) {
        self.id = id
        self.directoryIndex = directoryIndex
        self.fileInfos = fileInfos
    }
}
