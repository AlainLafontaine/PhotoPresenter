//
//  PresenterLoadingFileController.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-17.
//

import Foundation
import SwiftUI
import AppKit  // Nécessaire pour NSImage

class PresenterLoadingFileController {
    
    @Binding var loadingInProgress: Bool
    @Binding var windowIdentifier: Set<String>
    
    private var timer: Timer? = nil
    private let intervalTimer = 0.1
    private let openWindow: OpenWindowAction

    init(
        loadingInProgress: Binding<Bool>,
        windowIdentifier: Binding<Set<String>>,
        openWindow: OpenWindowAction
    )
    {
        _loadingInProgress = loadingInProgress
        _windowIdentifier = windowIdentifier
        self.openWindow = openWindow
    }

    func start(with viewPositions: [PresenterViewPosition]) {
        let nbOfViews = viewPositions.count
        var index: Int = 0

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: intervalTimer, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if !loadingInProgress {
                let viewPosition = viewPositions[index]
                
                loadingInProgress = true

                if let presenter = PhotoPresenterApp.LoadPhotoPresenter(fullpath: viewPosition.pahtFile) {
                    for grView in presenter.groupedViews {
                        if grView.fastLoaddings == nil {
                            grView.fastLoaddings = (0..<grView.nbOfView).map { _ in FastLoading() }
                        }
                    }

                    let helper = DataPresenterHelp(
                        filename: viewPosition.pahtFile,
                        name: presenter.fileHeader.name,
                        windowPos: viewPosition.windowPosition,
                        presenter: presenter
                    )

                    // Utilisation de la closure injectée
                    openWindow.callAsFunction(id: "photoPresenterWindows", value: helper)
                }

                index += 1
            }

            if index >= nbOfViews {
                timer?.invalidate()
 /*
                // Libére les fenêtres du chargement précédent
                for window in NSApp.windows {
                    if let windowId = window.identifier?.rawValue {
                        if !windowIdentifier.contains(windowId) {
                            window.close()
                        }
                    }
                }
*/
            }
        }
    }
}
