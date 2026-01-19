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
    let resultats: [LinkDirectoryToFileDirectoryInfo]
    var suffix: String
    
    init(
        id: UUID = UUID(),
        isChecked: Bool,
        ratio: Double,
        resultats: [LinkDirectoryToFileDirectoryInfo],
        suffix: String
    ) {
        self.id = id
        self.isChecked = isChecked
        self.ratio = ratio
        self.resultats = resultats
        self.suffix = suffix
    }
    
    func NbOfFiles() -> Int {
        resultats.reduce(0) { $0 + $1.fileInfos.count }
    }
}
