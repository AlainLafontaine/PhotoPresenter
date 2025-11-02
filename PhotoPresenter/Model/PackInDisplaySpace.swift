//
//  PackInDisplaySpace.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-31.
//

import Foundation

class PackInDisplaySpace: ObservableObject, Codable, Hashable {
    @Published var displaySpaceId: UUID
    @Published var viewSettings: [ViewSetting2]
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case displaySpaceId, viewSettings
    }
    
    // MARK: - Initializers
    init(displaySpaceId: UUID, viewSettings: [ViewSetting2]) {
        self.displaySpaceId = displaySpaceId
        self.viewSettings = viewSettings
    }
    
    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displaySpaceId = try container.decode(UUID.self, forKey: .displaySpaceId)
        viewSettings = try container.decode([ViewSetting2].self, forKey: .viewSettings)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displaySpaceId, forKey: .displaySpaceId)
        try container.encode(viewSettings, forKey: .viewSettings)
    }
    
    // MARK: - Hashable
    static func == (lhs: PackInDisplaySpace, rhs: PackInDisplaySpace) -> Bool {
        return lhs.displaySpaceId == rhs.displaySpaceId &&
               lhs.viewSettings == rhs.viewSettings
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(displaySpaceId)
        hasher.combine(viewSettings)
    }
}
