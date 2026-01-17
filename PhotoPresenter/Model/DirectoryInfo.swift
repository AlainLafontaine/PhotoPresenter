//
//  DirectoryInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-01-16.
//

import SwiftUI

struct DirectoryInfo: Identifiable {
    let id: UUID
    var isChecked: Bool
    let path: String
    var fileInfos: [FileDirectoryInfo]
    
    init(
        id: UUID = UUID(),
        isChecked: Bool = false,
        path: String,
        fileInfos: [FileDirectoryInfo] = []
    ) {
        self.id = id
        self.isChecked = isChecked
        self.path = path
        self.fileInfos = fileInfos
    }
}
