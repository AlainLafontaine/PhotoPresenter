//
//  DisplaySpaceLoader.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-22.
//

import Foundation

struct DisplaySpaceLoader {
    
    func load(fullpath path: String) -> DisplaySpace? {
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            let displaySpace = try JSONDecoder().decode(DisplaySpace.self, from: data)
            
            check4Update(displaySpace)
            return displaySpace
        } catch {
            print("Erreur : \(error)")
            return nil
        }
    }
    
    private func check4Update(_ displaySpace: DisplaySpace) {
        
        switch(displaySpace.fileHeader.version) {
        case "0.1.0001":
            let fileHeader = displaySpace.fileHeader
            
            fileHeader.version = "0.1.0002"
            fileHeader.id = UUID()
            updateFor_0_1_0001(viewPositions: displaySpace.viewPositions)
                    
        default:
            break
        }
    }
    
    // Migration 0.1.0001 -> 0.1.0002
    private func updateFor_0_1_0001(viewPositions: [PresenterViewPosition]) {
        let presenterLoader: PhotoPresenterLoader = PhotoPresenterLoader()
        
        // Itérer sur viewPositions pour appliquer les changements nécessaires
        for viewPosition in viewPositions {
            
            if let presenter = presenterLoader.load(fullpath: viewPosition.pathFile) {
                viewPosition.id = presenter.fileHeader.id!
            }
        }
    }
}
