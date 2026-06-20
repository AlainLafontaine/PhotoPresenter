//
//  Rating.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-06-20.
//
//  Appréciation d'une image. Remplace les anciens booléens isFavorite /
//  isUninteresting de FileInfo par une propriété unique et exclusive : une
//  image ne peut porter qu'une seule appréciation à la fois.
//

import Foundation

public enum Rating: String, Codable, CaseIterable {
    case none
    case favorite
    case uninteresting
    case improvable
}
