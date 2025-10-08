//
//  ViewSetting.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-08.
//

import Foundation

class ViewSetting: ObservableObject, Codable, Hashable {
    @Published var type: ImageViewType
    @Published var isPaused: Bool
    @Published var isReverse: Bool
    @Published var isRandomizing: Bool
    @Published var currentIndex: Int
    @Published var intervalTimer: Double
    @Published var displayNumImage: Bool
    @Published var displayFilename: Bool
    @Published var filesSelected: [String]?
    @Published var directorySelected: [String]?
    @Published var ratio: Double?
    @Published var tolerance: Double?

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case type, isPaused, isReverse, isRandomizing, currentIndex, intervalTimer, displayNumImage, displayFilename, filesSelected, directorySelected, ratio, tolerance
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        type = try c.decode(ImageViewType.self, forKey: .type)
        isPaused = try c.decode(Bool.self, forKey: .isPaused)
        isReverse = try c.decode(Bool.self, forKey: .isReverse)
        isRandomizing = try c.decode(Bool.self, forKey: .isRandomizing)
        currentIndex = try c.decode(Int.self, forKey: .currentIndex)
        intervalTimer = try c.decode(Double.self, forKey: .intervalTimer)
        displayNumImage = try c.decode(Bool.self, forKey: .displayNumImage)
        displayFilename = try c.decode(Bool.self, forKey: .displayFilename)
        filesSelected = try c.decodeIfPresent([String].self, forKey: .filesSelected)
        directorySelected = try c.decodeIfPresent([String].self, forKey: .directorySelected)
        ratio = try c.decodeIfPresent(Double.self, forKey: .ratio)
        tolerance = try c.decodeIfPresent(Double.self, forKey: .tolerance)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(type, forKey: .type)
        try c.encode(isPaused, forKey: .isPaused)
        try c.encode(isReverse, forKey: .isReverse)
        try c.encode(isRandomizing, forKey: .isRandomizing)
        try c.encode(currentIndex, forKey: .currentIndex)
        try c.encode(intervalTimer, forKey: .intervalTimer)
        try c.encode(displayNumImage, forKey: .displayNumImage)
        try c.encode(displayFilename, forKey: .displayFilename)
        try c.encodeIfPresent(filesSelected, forKey: .filesSelected)
        try c.encodeIfPresent(directorySelected, forKey: .directorySelected)
        try c.encodeIfPresent(ratio, forKey: .ratio)
        try c.encodeIfPresent(tolerance, forKey: .tolerance)
    }

    // MARK: - Hashable
    static func == (lhs: ViewSetting, rhs: ViewSetting) -> Bool {
        lhs.type == rhs.type && lhs.currentIndex == rhs.currentIndex
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(currentIndex)
    }

    // MARK: - Init
    init(
        type: ImageViewType,
        isPaused: Bool,
        isReverse: Bool,
        isRandomizing: Bool,
        currentIndex: Int,
        intervalTimer: Double,
        displayNumImage: Bool,
        displayFilename: Bool,
        filesSelected: [String]? = nil,
        directorySelected: [String]? = nil,
        ratio: Double? = nil,
        tolerance: Double? = nil
    ) {
        self.type = type
        self.isPaused = isPaused
        self.isReverse = isReverse
        self.isRandomizing = isRandomizing
        self.currentIndex = currentIndex
        self.intervalTimer = intervalTimer
        self.displayNumImage = displayNumImage
        self.displayFilename = displayFilename
        self.filesSelected = filesSelected
        self.directorySelected = directorySelected
        self.ratio = ratio
        self.tolerance = tolerance
    }
}
