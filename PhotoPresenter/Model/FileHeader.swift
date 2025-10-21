//
//  FileHeader.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-20.
//

import Foundation

class FileHeader: ObservableObject, Codable, Hashable {
    var version: String
    var fileType: FileType

    // MARK: - Initialiseur
    init(version: String = "0.01.0001", fileType: FileType) {
        self.version = version
        self.fileType = fileType
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case version
        case fileType
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        fileType = try container.decode(FileType.self, forKey: .fileType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(fileType, forKey: .fileType)
    }

    // MARK: - Hashable
    static func == (lhs: FileHeader, rhs: FileHeader) -> Bool {
        lhs.version == rhs.version && lhs.fileType == rhs.fileType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(version)
        hasher.combine(fileType)
    }
}
