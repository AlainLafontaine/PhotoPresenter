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
    
    private var timer: Timer? = nil
    private let intervalTimer = 1.0
    private let openWindow: OpenWindowAction

    init(
        loadingInProgress: Binding<Bool>,
        openWindow: OpenWindowAction
    )
    {
        _loadingInProgress = loadingInProgress
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
            }
        }
    }
}
