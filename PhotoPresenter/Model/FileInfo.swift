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
    @Published public var isFavorite: Bool

               public var nsImage: NSImage?

    // MARK: - Initializer

    public init(filename: String, directoryIndex: Int, width: Int, height: Int, isFavorite: Bool = false, nsImage: NSImage? = nil) {
        self.filename = filename
        self.directoryIndex = directoryIndex
        self.width = width
        self.height = height
        self.isFavorite = isFavorite
        self.nsImage = nsImage
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case filename
        case directoryIndex
        case width
        case height
        case isFavorite
        // nsImage is intentionally excluded
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let filename = try container.decode(String.self, forKey: .filename)
        let directoryIndex = try container.decode(Int.self, forKey: .directoryIndex)
        let width = try container.decode(Int.self, forKey: .width)
        let height = try container.decode(Int.self, forKey: .height)
        let isFavorite = (try? container.decode(Bool.self, forKey: .isFavorite)) ?? false
        self.init(filename: filename, directoryIndex: directoryIndex, width: width, height: height, isFavorite: isFavorite)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(filename, forKey: .filename)
        try container.encode(directoryIndex, forKey: .directoryIndex)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(isFavorite, forKey: .isFavorite)
        // nsImage intentionally not encoded
    }

    // MARK: - Hashable

    public static func == (lhs: FileInfo, rhs: FileInfo) -> Bool {
        lhs.filename == rhs.filename &&
        lhs.directoryIndex == rhs.directoryIndex &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height &&
        lhs.isFavorite == rhs.isFavorite
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(filename)
        hasher.combine(directoryIndex)
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(isFavorite)
    }
}
