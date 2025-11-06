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
            
        default:
            break
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
