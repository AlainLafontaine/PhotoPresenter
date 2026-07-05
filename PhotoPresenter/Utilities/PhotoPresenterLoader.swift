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

        case "0.1.0006":
            // Version courante (Evo_012) : plus de packInDisplaySpaces dans le
            // fichier présentateur. La migration des fichiers ≤ 0.1.0003 est
            // assurée par un script externe, pas par l'application.
            break

        default:
            break
        }
    }
}
