//
//  PhotoPresenterDataSource.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-31.
//

import Foundation

class PhotoPresenterDataSource: ObservableObject, Codable, Hashable {
    @Published var type: ImageViewType
    @Published var filesSelected: [String]?
    @Published var directorySelected: [String]?
    @Published var ratio: Double?
    @Published var tolerance: Double?
    
    // MARK: - Initializers
    init(
        type: ImageViewType = .FilesSelected,
        filesSelected: [String]? = nil,
        directorySelected: [String]? = nil,
        ratio: Double? = nil,
        tolerance: Double? = nil
    ) {
        self.type = type
        self.filesSelected = filesSelected
        self.directorySelected = directorySelected
        self.ratio = ratio
        self.tolerance = tolerance
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case type
        case filesSelected
        case directorySelected
        case ratio
        case tolerance
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try container.decode(ImageViewType.self, forKey: .type)
        filesSelected = try container.decodeIfPresent([String].self, forKey: .filesSelected)
        directorySelected = try container.decodeIfPresent([String].self, forKey: .directorySelected)
        ratio = try container.decodeIfPresent(Double.self, forKey: .ratio)
        tolerance = try container.decodeIfPresent(Double.self, forKey: .tolerance)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(filesSelected, forKey: .filesSelected)
        try container.encodeIfPresent(directorySelected, forKey: .directorySelected)
        try container.encodeIfPresent(ratio, forKey: .ratio)
        try container.encodeIfPresent(tolerance, forKey: .tolerance)
    }
    
    // MARK: - Hashable
    static func == (lhs: PhotoPresenterDataSource, rhs: PhotoPresenterDataSource) -> Bool {
        return lhs.type == rhs.type &&
               lhs.filesSelected == rhs.filesSelected &&
               lhs.directorySelected == rhs.directorySelected &&
               lhs.ratio == rhs.ratio &&
               lhs.tolerance == rhs.tolerance
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(filesSelected)
        hasher.combine(directorySelected)
        hasher.combine(ratio)
        hasher.combine(tolerance)
    }
}
