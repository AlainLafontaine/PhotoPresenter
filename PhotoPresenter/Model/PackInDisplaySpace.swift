//
//  PackInDisplaySpace.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-31.
//

import Foundation

class PackInDisplaySpace: ObservableObject, Codable, Hashable {
    @Published var displaySpaceId: UUID
    @Published var viewSettings: [ViewSetting]
    
    // MARK: - Init
    init(displaySpaceId: UUID = UUID(),
         viewSettings: [ViewSetting] = []) {
        self.displaySpaceId = displaySpaceId
        self.viewSettings = viewSettings
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case displaySpaceId, viewSettings
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        displaySpaceId = try container.decode(UUID.self, forKey: .displaySpaceId)
        viewSettings = try container.decode([ViewSetting].self, forKey: .viewSettings)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displaySpaceId, forKey: .displaySpaceId)
        try container.encode(viewSettings, forKey: .viewSettings)
    }
    
    // MARK: - Hashable
    static func == (lhs: PackInDisplaySpace, rhs: PackInDisplaySpace) -> Bool {
        lhs.displaySpaceId == rhs.displaySpaceId &&
        lhs.viewSettings == rhs.viewSettings
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(displaySpaceId)
        hasher.combine(viewSettings)
    }
}
