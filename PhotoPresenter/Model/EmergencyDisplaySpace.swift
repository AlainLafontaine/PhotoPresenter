//
//  EmergencyDisplaySpace.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-24.
//

import Foundation

public class EmergencyDisplaySpace: ObservableObject, Codable, Hashable {
    @Published public var filename: String

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case filename
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filename = try container.decode(String.self, forKey: .filename)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(filename, forKey: .filename)
    }

    // MARK: - Hashable

    public static func == (lhs: EmergencyDisplaySpace, rhs: EmergencyDisplaySpace) -> Bool {
        lhs.filename == rhs.filename
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(filename)
    }

    // MARK: - Initializer

    public init(filename: String) {
        self.filename = filename
    }
}
