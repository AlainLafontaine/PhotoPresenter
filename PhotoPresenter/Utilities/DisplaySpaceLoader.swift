//
//  DisplaySpaceLoader.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-22.
//

import Foundation
import SwiftUtilities

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

        case "0.1.0006":
            // Version courante (Evo_012) : les ViewSetting sont portés par les
            // viewPositions. La migration des fichiers ≤ 0.1.0005 est assurée
            // par un script externe, pas par l'application.
            break

        case "0.1.0005":
            break

        default:
            // Migration vers 0.1.0005 : les anciens fichiers (≤ 0.1.0004) n'ont pas
            // de CommunityParameter. On en crée un par défaut et on aligne la version.
            if displaySpace.communityParameter == nil {
                displaySpace.communityParameter = CommunityParameter()
            }
            displaySpace.fileHeader.version = "0.1.0005"
        }
    }
    
    private func loadPhotoPresententer(fullpath path: String) -> PhotoPresenter? {
        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            let photoPresenter = try JSONDecoder().decode(PhotoPresenter.self, from: data)

            return photoPresenter
        } catch {
            print("Erreur : \(error)")
            return nil
        }
    }
}
