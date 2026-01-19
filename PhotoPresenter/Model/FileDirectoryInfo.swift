//
//  FileDirectoryInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-01-16.
//

import SwiftUI

struct FileDirectoryInfo: Identifiable, Codable, Hashable {
    
    let id: UUID
    let filename: String
    let width: Int
    let height: Int
    let ratio: Double
    
    init(
        id: UUID = UUID(),
        filename: String,
        width: Int,
        height: Int,
        ratio: Double
    ) {
        self.id = id
        self.filename = filename
        self.width = width
        self.height = height
        self.ratio = ratio
    }
}
