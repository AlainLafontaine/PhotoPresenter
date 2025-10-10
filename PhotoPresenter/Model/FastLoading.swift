//
//  fastLoadingSection.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-10.
//

import Foundation
import Combine

class FastLoading: ObservableObject, Codable, Hashable {
    @Published var lastRefresh: Date
    @Published var executionTime4Refresh: TimeInterval
    @Published var directories: [String]
    @Published var fileInfos: [FileInfo]

    // MARK: - Initializer

    init(
        lastRefresh: Date = Date(),
        executionTime4Refresh: TimeInterval = 0,
        directories: [String] = [],
        fileInfos: [FileInfo] = []
    ) {
        self.lastRefresh = lastRefresh
        self.executionTime4Refresh = executionTime4Refresh
        self.directories = directories
        self.fileInfos = fileInfos
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case lastRefresh
        case executionTime4Refresh
        case directories
        case fileInfos
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lastRefresh = try container.decode(Date.self, forKey: .lastRefresh)
        let executionTime4Refresh = try container.decode(TimeInterval.self, forKey: .executionTime4Refresh)
        let directories = try container.decode([String].self, forKey: .directories)
        let fileInfos = try container.decode([FileInfo].self, forKey: .fileInfos)
        self.init(
            lastRefresh: lastRefresh,
            executionTime4Refresh: executionTime4Refresh,
            directories: directories,
            fileInfos: fileInfos
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastRefresh, forKey: .lastRefresh)
        try container.encode(executionTime4Refresh, forKey: .executionTime4Refresh)
        try container.encode(directories, forKey: .directories)
        try container.encode(fileInfos, forKey: .fileInfos)
    }

    // MARK: - Hashable

    static func == (lhs: FastLoading, rhs: FastLoading) -> Bool {
        lhs.lastRefresh == rhs.lastRefresh &&
        lhs.executionTime4Refresh == rhs.executionTime4Refresh &&
        lhs.directories == rhs.directories &&
        lhs.fileInfos == rhs.fileInfos
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(lastRefresh)
        hasher.combine(executionTime4Refresh)
        hasher.combine(directories)
        hasher.combine(fileInfos)
    }
}
