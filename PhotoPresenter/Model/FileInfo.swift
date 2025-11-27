//
//  FileInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-26.
//

import Foundation
import AppKit
import Combine

public class FileInfo: ObservableObject, Codable, Hashable {
    
    @Published public var filename: String
    @Published public var directoryIndex: Int
    @Published public var width: Int
    @Published public var height: Int
              
               public var nsImage: NSImage?

    // MARK: - Initializer

    public init(filename: String, directoryIndex: Int, width: Int, height: Int, nsImage: NSImage? = nil) {
        self.filename = filename
        self.directoryIndex = directoryIndex
        self.width = width
        self.height = height
        self.nsImage = nsImage
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case filename
        case directoryIndex
        case width
        case height
        // nsImage is intentionally excluded
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let filename = try container.decode(String.self, forKey: .filename)
        let directoryIndex = try container.decode(Int.self, forKey: .directoryIndex)
        let width = try container.decode(Int.self, forKey: .width)
        let height = try container.decode(Int.self, forKey: .height)
        self.init(filename: filename, directoryIndex: directoryIndex, width: width, height: height)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(filename, forKey: .filename)
        try container.encode(directoryIndex, forKey: .directoryIndex)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        // nsImage intentionally not encoded
    }

    // MARK: - Hashable

    public static func == (lhs: FileInfo, rhs: FileInfo) -> Bool {
        lhs.filename == rhs.filename &&
        lhs.directoryIndex == rhs.directoryIndex &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(filename)
        hasher.combine(directoryIndex)
        hasher.combine(width)
        hasher.combine(height)
    }
}
