//
//  FileHeader.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-20.
//

import Foundation

class FileHeader: ObservableObject, Codable, Hashable {
    // MARK: - Properties

    var id: UUID?
    var version: String
    var fileType: FileType

    // MARK: - Initializer

    init(id: UUID? = UUID(), version: String = "0.01.0002", fileType: FileType) {
        self.id = id
        self.version = version
        self.fileType = fileType
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, version, fileType
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        version = try container.decode(String.self, forKey: .version)
        fileType = try container.decode(FileType.self, forKey: .fileType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(version, forKey: .version)
        try container.encode(fileType, forKey: .fileType)
    }

    // MARK: - Hashable

    static func == (lhs: FileHeader, rhs: FileHeader) -> Bool {
        lhs.id == rhs.id &&
        lhs.version == rhs.version &&
        lhs.fileType == rhs.fileType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(version)
        hasher.combine(fileType)
    }
}
