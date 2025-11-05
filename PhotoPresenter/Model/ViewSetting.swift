//
//  ViewSetting2.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-31.
//

import Foundation

class ViewSetting: ObservableObject, Codable, Hashable {
    @Published var isPaused: Bool
    @Published var isReverse: Bool
    @Published var isRandomizing: Bool
    @Published var currentIndex: Int
    @Published var intervalTimer: Double
    @Published var displayNumImage: Bool
    @Published var displayFilename: Bool

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case isPaused
        case isReverse
        case isRandomizing
        case currentIndex
        case intervalTimer
        case displayNumImage
        case displayFilename
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isPaused = try container.decode(Bool.self, forKey: .isPaused)
        isReverse = try container.decode(Bool.self, forKey: .isReverse)
        isRandomizing = try container.decode(Bool.self, forKey: .isRandomizing)
        currentIndex = try container.decode(Int.self, forKey: .currentIndex)
        intervalTimer = try container.decode(Double.self, forKey: .intervalTimer)
        displayNumImage = try container.decode(Bool.self, forKey: .displayNumImage)
        displayFilename = try container.decode(Bool.self, forKey: .displayFilename)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isPaused, forKey: .isPaused)
        try container.encode(isReverse, forKey: .isReverse)
        try container.encode(isRandomizing, forKey: .isRandomizing)
        try container.encode(currentIndex, forKey: .currentIndex)
        try container.encode(intervalTimer, forKey: .intervalTimer)
        try container.encode(displayNumImage, forKey: .displayNumImage)
        try container.encode(displayFilename, forKey: .displayFilename)
    }

    // MARK: - Hashable
    static func == (lhs: ViewSetting, rhs: ViewSetting) -> Bool {
        lhs.isPaused == rhs.isPaused &&
        lhs.isReverse == rhs.isReverse &&
        lhs.isRandomizing == rhs.isRandomizing &&
        lhs.currentIndex == rhs.currentIndex &&
        lhs.intervalTimer == rhs.intervalTimer &&
        lhs.displayNumImage == rhs.displayNumImage &&
        lhs.displayFilename == rhs.displayFilename
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(isPaused)
        hasher.combine(isReverse)
        hasher.combine(isRandomizing)
        hasher.combine(currentIndex)
        hasher.combine(intervalTimer)
        hasher.combine(displayNumImage)
        hasher.combine(displayFilename)
    }

    // MARK: - Initializer
    init(isPaused: Bool = false,
         isReverse: Bool = false,
         isRandomizing: Bool = false,
         currentIndex: Int = 0,
         intervalTimer: Double = 3.0,
         displayNumImage: Bool = true,
         displayFilename: Bool = false) {
        self.isPaused = isPaused
        self.isReverse = isReverse
        self.isRandomizing = isRandomizing
        self.currentIndex = currentIndex
        self.intervalTimer = intervalTimer
        self.displayNumImage = displayNumImage
        self.displayFilename = displayFilename
    }
}
