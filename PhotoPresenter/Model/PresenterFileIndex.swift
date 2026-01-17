//
//  PresenterFileInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-01-16.
//

import Foundation

class PresenterFileIndex: Codable, Hashable {

    var fileHeader: FileHeader
    var fileInfos: [FileDirectoryInfo]

    init(fileHeader: FileHeader, fileInfos: [FileDirectoryInfo]) {
        self.fileHeader = fileHeader
        self.fileInfos = fileInfos
    }

    // MARK: - Hashable

    static func == (lhs: PresenterFileIndex, rhs: PresenterFileIndex) -> Bool {
        lhs.fileHeader == rhs.fileHeader &&
        lhs.fileInfos == rhs.fileInfos
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(fileHeader)
        hasher.combine(fileInfos)
    }
}
