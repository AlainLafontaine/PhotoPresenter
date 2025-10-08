//
//  PhotoPresenter.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import Foundation

enum Orientation: String, Codable, Hashable {
    case Horizontal
    case Vertical
    case Free
}

enum ViewType: String, Codable, Hashable {
    case FilesSelected
    case DirectorySelected
    case WebServiceSelected
}

struct PhotoPresenter: Codable, Hashable {
    let fileHeader: FileHeader
    let groupedViews: [GroupedView]
}

struct FileHeader: Codable, Hashable {
    let name: String
    let description: String?
    let orientation: Orientation
}

struct GroupedView: Codable, Hashable {
    let nbOfView: Int
    let viewSettings: [ViewSetting]
}

struct ViewSetting: Codable, Hashable {
    let type: ViewType
    
    let isPaused: Bool
    let isRandomizing: Bool
    let currentIndex: Int
    let intervalTimer: Double
    let displayNumImage: Bool
    let displayFilename: Bool

    // Section pour le type fichiers par sélection
    let filesSelected: [String]?
    
    // Section pour le type fichiers sélectionnés à l'aide de répertoire
    let directorySelected: [String]?
    let ratio: Double?
    let tolerance: Double?
}
