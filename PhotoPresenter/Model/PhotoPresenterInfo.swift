//
//  PhotoPrensenterInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-01-11.
//

import Foundation

class PhotoPresenterInfo {
    let url: URL
    let id: UUID
    let name: String
    let description: String
    let nbPhotos: Int
    let ratio: Double
    let orientation: Orientation
    var isInclusInDisplaySpace: Bool
    
    init(
        url: URL,
        id: UUID,
        name: String,
        description: String,
        nbPhotos: Int,
        ratio: Double,
        orientation: Orientation,
        isInclusInDisplaySpace: Bool
    ) {
        self.url = url
        self.id = id
        self.name = name
        self.description = description
        self.nbPhotos = nbPhotos
        self.ratio = ratio
        self.orientation = orientation
        self.isInclusInDisplaySpace = isInclusInDisplaySpace
    }
}
