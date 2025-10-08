//
//  FileInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-26.
//

import Foundation
import AppKit  // Nécessaire pour NSImage

public struct FileInfo {
    let filename: String
    let directoryIndex: Int
    let nsImage: NSImage
    let width: Int
    let height: Int
}
