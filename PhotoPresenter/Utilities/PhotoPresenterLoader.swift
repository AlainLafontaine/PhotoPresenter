//
//  PhotoPresenterLoader.swift
//  SwiftUtilities
//
//  Created by Alain Lafontaine on 2025-10-22.
//

import Foundation

struct PhotoPresenterLoader {
    
    func load(fullpath path: String) -> PhotoPresenter? {
        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            let photoPresenter = try JSONDecoder().decode(PhotoPresenter.self, from: data)
                check4Update(photoPresenter)
            return photoPresenter
        } catch {
            print("Erreur : \(error)")
            return nil
        }
    }
    
    private func check4Update(_ presenter: PhotoPresenter) {
        
        switch(presenter.fileHeader.version) {
        case "0.1.0001":
            presenter.fileHeader.version = "0.1.0002"
            presenter.fileHeader.id = UUID()
            
        case "0.1.0002":
            presenter.fileHeader.version = "0.1.0003"
            
        default:
            break
        }
    }
}
