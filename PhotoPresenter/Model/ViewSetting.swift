//
//  ViewSetting.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
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
    @Published var displaySpaceId: UUID?

    // MARK: - Initializer

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
        tolerance: Double? = nil,
        displaySpaceId: UUID? = nil
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
        self.displaySpaceId = displaySpaceId
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case type, isPaused, isReverse, isRandomizing, currentIndex, intervalTimer,
             displayNumImage, displayFilename, filesSelected, directorySelected,
             ratio, tolerance, displaySpaceId
    }

    required convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(ImageViewType.self, forKey: .type)
        let isPaused = try c.decode(Bool.self, forKey: .isPaused)
        let isReverse = try c.decode(Bool.self, forKey: .isReverse)
        let isRandomizing = try c.decode(Bool.self, forKey: .isRandomizing)
        let currentIndex = try c.decode(Int.self, forKey: .currentIndex)
        let intervalTimer = try c.decode(Double.self, forKey: .intervalTimer)
        let displayNumImage = try c.decode(Bool.self, forKey: .displayNumImage)
        let displayFilename = try c.decode(Bool.self, forKey: .displayFilename)
        let filesSelected = try c.decodeIfPresent([String].self, forKey: .filesSelected)
        let directorySelected = try c.decodeIfPresent([String].self, forKey: .directorySelected)
        let ratio = try c.decodeIfPresent(Double.self, forKey: .ratio)
        let tolerance = try c.decodeIfPresent(Double.self, forKey: .tolerance)
        let displaySpaceId = try c.decodeIfPresent(UUID.self, forKey: .displaySpaceId)

        self.init(
            type: type,
            isPaused: isPaused,
            isReverse: isReverse,
            isRandomizing: isRandomizing,
            currentIndex: currentIndex,
            intervalTimer: intervalTimer,
            displayNumImage: displayNumImage,
            displayFilename: displayFilename,
            filesSelected: filesSelected,
            directorySelected: directorySelected,
            ratio: ratio,
            tolerance: tolerance,
            displaySpaceId: displaySpaceId
        )
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
        try c.encodeIfPresent(displaySpaceId, forKey: .displaySpaceId)
    }

    // MARK: - Hashable

    static func == (lhs: ViewSetting, rhs: ViewSetting) -> Bool {
        lhs.type == rhs.type &&
        lhs.isPaused == rhs.isPaused &&
        lhs.isReverse == rhs.isReverse &&
        lhs.isRandomizing == rhs.isRandomizing &&
        lhs.currentIndex == rhs.currentIndex &&
        lhs.intervalTimer == rhs.intervalTimer &&
        lhs.displayNumImage == rhs.displayNumImage &&
        lhs.displayFilename == rhs.displayFilename &&
        lhs.filesSelected == rhs.filesSelected &&
        lhs.directorySelected == rhs.directorySelected &&
        lhs.ratio == rhs.ratio &&
        lhs.tolerance == rhs.tolerance &&
        lhs.displaySpaceId == rhs.displaySpaceId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(isPaused)
        hasher.combine(isReverse)
        hasher.combine(isRandomizing)
        hasher.combine(currentIndex)
        hasher.combine(intervalTimer)
        hasher.combine(displayNumImage)
        hasher.combine(displayFilename)
        hasher.combine(filesSelected)
        hasher.combine(directorySelected)
        hasher.combine(ratio)
        hasher.combine(tolerance)
        hasher.combine(displaySpaceId)
    }
}
