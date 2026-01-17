//
//  AnalysisResultat.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-01-16.
//

import Foundation

struct AnalysisResultat: Identifiable, Codable, Hashable {
    
    let id: UUID
    var isChecked: Bool
    let ratio: Double
    let resultats: [FileDirectoryInfo]
    var suffix: String
    
    init(
        id: UUID = UUID(),
        isChecked: Bool,
        ratio: Double,
        resultats: [FileDirectoryInfo],
        suffix: String
    ) {
        self.id = id
        self.isChecked = isChecked
        self.ratio = ratio
        self.resultats = resultats
        self.suffix = suffix
    }
}
