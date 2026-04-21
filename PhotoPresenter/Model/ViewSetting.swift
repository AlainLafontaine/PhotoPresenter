//
//  ViewSetting2.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-31.
//

import SwiftUI

enum TransparencyGradientDirection: String, Codable, CaseIterable {
    case none        = "none"
    case leftToRight = "leftToRight"
    case rightToLeft = "rightToLeft"
    case topToBottom = "topToBottom"
    case bottomToTop = "bottomToTop"

    var label: String {
        switch self {
        case .none:        return "Aucun"
        case .leftToRight: return "Gauche vers la droite"
        case .rightToLeft: return "Droite vers la gauche"
        case .topToBottom: return "Haut vers le bas"
        case .bottomToTop: return "Bas vers le haut"
        }
    }
}

class ViewSetting: ObservableObject, Codable, Hashable {

    @Published var isPaused: Bool
    @Published var isReverse: Bool
    @Published var isRandomizing: Bool
    @Published var currentIndex: Int
    @Published var intervalTimer: Double
    @Published var displayNumImage: Bool?
    @Published var displayFilename: Bool?
    @Published var isOverlayDisplayInfo: Bool?
    @Published var isExpansionMode: Bool?
    @Published var isInCommunity: Bool?
    @Published var isTransparent: Bool?
    @Published var transparentFactor: Double?
    @Published var isShowPictograms: Bool?
    @Published var transparencyGradientDirection: TransparencyGradientDirection?
    @Published var opacityStart: Double?
    @Published var opacityEnd: Double?
    @Published var isDisplayFavorite: Bool?
    @Published var isDisplayUninteresting: Bool?

    // MARK: - Init
    init(
        isPaused: Bool = true,
        isReverse: Bool = false,
        isRandomizing: Bool = false,
        currentIndex: Int = 0,
        intervalTimer: Double = 4.0,
        displayNumImage: Bool? = nil,
        displayFilename: Bool? = nil,
        isOverlayDisplayInfo: Bool? = true,
        isExpansionMode: Bool? = false,
        isInCommunity: Bool? = true,
        isTransparent: Bool? = false,
        transparentFactor: Double? = 1.0,
        isShowPictograms: Bool? = false,
        transparencyGradientDirection: TransparencyGradientDirection? = TransparencyGradientDirection.none,
        opacityStart: Double? = 1.0,
        opacityEnd: Double? = 0.0,
        isDisplayFavorite: Bool? = false,
        isDisplayUninteresting: Bool? = false
    ) {
        self.isPaused = isPaused
        self.isReverse = isReverse
        self.isRandomizing = isRandomizing
        self.currentIndex = currentIndex
        self.intervalTimer = intervalTimer
        self.displayNumImage = displayNumImage
        self.displayFilename = displayFilename
        self.isOverlayDisplayInfo = isOverlayDisplayInfo
        self.isExpansionMode = isExpansionMode
        self.isInCommunity = isInCommunity
        self.isTransparent = isTransparent
        self.transparentFactor = transparentFactor
        self.isShowPictograms = isShowPictograms
        self.transparencyGradientDirection = transparencyGradientDirection
        self.opacityStart = opacityStart
        self.opacityEnd = opacityEnd
        self.isDisplayFavorite = isDisplayFavorite
        self.isDisplayUninteresting = isDisplayUninteresting
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case isPaused
        case isReverse
        case isRandomizing
        case currentIndex
        case intervalTimer
        case displayNumImage
        case displayFilename
        case isOverlayDisplayInfo
        case isExpansionMode
        case isInCommunity
        case isTransparent
        case transparentFactor
        case isShowPictograms
        case transparencyGradientDirection
        case opacityStart
        case opacityEnd
        case isDisplayFavorite
        case isDisplayUninteresting
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        isPaused = try container.decode(Bool.self, forKey: .isPaused)
        isReverse = try container.decode(Bool.self, forKey: .isReverse)
        isRandomizing = try container.decode(Bool.self, forKey: .isRandomizing)
        currentIndex = try container.decode(Int.self, forKey: .currentIndex)
        intervalTimer = try container.decode(Double.self, forKey: .intervalTimer)

        // Optionnels → decodeIfPresent
        displayNumImage = nil
        displayFilename = nil
        isOverlayDisplayInfo = try container.decodeIfPresent(Bool.self, forKey: .isOverlayDisplayInfo) ?? true
        isExpansionMode = try container.decodeIfPresent(Bool.self, forKey: .isExpansionMode) ?? false
        isInCommunity = try container.decodeIfPresent(Bool.self, forKey: .isInCommunity) ?? true
        isTransparent = try container.decodeIfPresent(Bool.self, forKey: .isTransparent) ?? true
        let rawFactor = try container.decodeIfPresent(Double.self, forKey: .transparentFactor)
        transparentFactor = rawFactor.map { min(max($0, 0.0), 1.0) } ?? 1.0
        isShowPictograms = try container.decodeIfPresent(Bool.self, forKey: .isShowPictograms) ?? true
        transparencyGradientDirection = try container.decodeIfPresent(TransparencyGradientDirection.self, forKey: .transparencyGradientDirection) ?? TransparencyGradientDirection.none
        opacityStart = try container.decodeIfPresent(Double.self, forKey: .opacityStart) ?? 1.0
        opacityEnd = try container.decodeIfPresent(Double.self, forKey: .opacityEnd) ?? 0.0
        isDisplayFavorite = try container.decodeIfPresent(Bool.self, forKey: .isDisplayFavorite) ?? true
        isDisplayUninteresting = try container.decodeIfPresent(Bool.self, forKey: .isDisplayUninteresting) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(isPaused, forKey: .isPaused)
        try container.encode(isReverse, forKey: .isReverse)
        try container.encode(isRandomizing, forKey: .isRandomizing)
        try container.encode(currentIndex, forKey: .currentIndex)
        try container.encode(intervalTimer, forKey: .intervalTimer)

        // Optionnels → encodeIfPresent
        try container.encodeIfPresent(displayNumImage, forKey: .displayNumImage)
        try container.encodeIfPresent(displayFilename, forKey: .displayFilename)
        try container.encodeIfPresent(isOverlayDisplayInfo, forKey: .isOverlayDisplayInfo)
        try container.encodeIfPresent(isExpansionMode, forKey: .isExpansionMode)
        try container.encodeIfPresent(isInCommunity, forKey: .isInCommunity)
        try container.encodeIfPresent(isTransparent, forKey: .isTransparent)
        try container.encodeIfPresent(transparentFactor, forKey: .transparentFactor)
        try container.encodeIfPresent(isShowPictograms, forKey: .isShowPictograms)
        try container.encodeIfPresent(transparencyGradientDirection, forKey: .transparencyGradientDirection)
        try container.encodeIfPresent(opacityStart, forKey: .opacityStart)
        try container.encodeIfPresent(opacityEnd, forKey: .opacityEnd)
        try container.encodeIfPresent(isDisplayFavorite, forKey: .isDisplayFavorite)
        try container.encodeIfPresent(isDisplayUninteresting, forKey: .isDisplayUninteresting)
    }

    // MARK: - Hashable
    static func == (lhs: ViewSetting, rhs: ViewSetting) -> Bool {
        lhs.isPaused == rhs.isPaused &&
        lhs.isReverse == rhs.isReverse &&
        lhs.isRandomizing == rhs.isRandomizing &&
        lhs.currentIndex == rhs.currentIndex &&
        lhs.intervalTimer == rhs.intervalTimer &&
        lhs.displayNumImage == rhs.displayNumImage &&
        lhs.displayFilename == rhs.displayFilename &&
        lhs.isOverlayDisplayInfo == rhs.isOverlayDisplayInfo &&
        lhs.isExpansionMode == rhs.isExpansionMode &&
        lhs.isInCommunity == rhs.isInCommunity &&
        lhs.isTransparent == rhs.isTransparent &&
        lhs.transparentFactor == rhs.transparentFactor &&
        lhs.isShowPictograms == rhs.isShowPictograms &&
        lhs.transparencyGradientDirection == rhs.transparencyGradientDirection &&
        lhs.opacityStart == rhs.opacityStart &&
        lhs.opacityEnd == rhs.opacityEnd &&
        lhs.isDisplayFavorite == rhs.isDisplayFavorite &&
        lhs.isDisplayUninteresting == rhs.isDisplayUninteresting
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(isPaused)
        hasher.combine(isReverse)
        hasher.combine(isRandomizing)
        hasher.combine(currentIndex)
        hasher.combine(intervalTimer)
        hasher.combine(displayNumImage)
        hasher.combine(displayFilename)
        hasher.combine(isOverlayDisplayInfo)
        hasher.combine(isExpansionMode)
        hasher.combine(isInCommunity)
        hasher.combine(isTransparent)
        hasher.combine(transparentFactor)
        hasher.combine(isShowPictograms)
        hasher.combine(transparencyGradientDirection)
        hasher.combine(opacityStart)
        hasher.combine(opacityEnd)
        hasher.combine(isDisplayFavorite)
        hasher.combine(isDisplayUninteresting)
    }
}
