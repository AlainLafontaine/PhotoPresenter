//
//  LibraryView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-11-11.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var displaySpace: DisplaySpace
    @ObservedObject var sharedRessources: SharedRessources
    
    var body: some View {
        Text("Hello, Librairy view!")
    }
    
    init (
        displaySpace: DisplaySpace,
        sharedRessources: SharedRessources
    )
    {
        self.displaySpace = displaySpace
        self.sharedRessources = sharedRessources
        
        for path in sharedRessources.paths2PresenterDirectory {
            let Presenters: [PhotoPresenter] = GetAllPresenters(path: path)
        }
    }
    
    private func GetAllPresenters(path: String) -> [PhotoPresenter] {
        let Presenters: [PhotoPresenter] = []
        let url = URL(fileURLWithPath: path)

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                print("Nom du fichier : \(fileURL.lastPathComponent)")
            }
        } catch {
            print("Erreur lors de la lecture du répertoire : \(error)")
        }
        
        
        return Presenters
    }
}


