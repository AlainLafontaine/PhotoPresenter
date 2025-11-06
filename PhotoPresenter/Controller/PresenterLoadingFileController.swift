//
//  PresenterLoadingFileController.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-17.
//

import Foundation
import SwiftUI
import AppKit  // Nécessaire pour NSImage
import SwiftUtilities

class PresenterLoadingFileController: ObservableObject {
    
    @Binding var loadingInProgress: Bool
    @Binding var screensInfo: ScreensInfo
    @ObservedObject var sharedRessources: SharedRessources
    
    private var timer: Timer? = nil
    private let intervalTimer = 0.1
    private let openWindow: OpenWindowAction
    private let presenter: PhotoPresenterLoader = PhotoPresenterLoader()
    
    init(
        loadingInProgress: Binding<Bool>,
        screensInfo: Binding<ScreensInfo>,
        sharedRessources: SharedRessources,
        openWindow: OpenWindowAction
    )
    {
        _loadingInProgress = loadingInProgress
        _screensInfo = screensInfo
        self.sharedRessources = sharedRessources
        self.openWindow = openWindow
    }

    func start(with viewPositions: [PresenterViewPosition], for displaySpaceId: UUID) {
        let nbOfViews = viewPositions.count
        var index: Int = 0
        var helpers = [DataPresenterHelp]()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: intervalTimer, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            switch index {
            case 0..<nbOfViews:
                if !loadingInProgress {
                    let viewPosition = viewPositions[index]
                
                    if screenIsAvailable(viewPosition.screenName) {
                        if let presenter = presenter.load(fullpath: viewPosition.pathFile) {
                            loadingInProgress = true

                            for grView in presenter.groupedViews {
                                if grView.fastLoaddings == nil {
                                    grView.fastLoaddings = (0..<grView.nbOfView).map { _ in FastLoading() }
                                }
                            }

                            let helper = DataPresenterHelp(
                                filename: viewPosition.pathFile,
                                name: presenter.photoPresenterHeader.name,
                                windowPos: viewPosition.windowPosition,
                                presenter: presenter,
                                displaySpaceId: displaySpaceId
                            )
                            
                            helpers.append(helper)

                            // Utilisation de la closure injectée
                            openWindow.callAsFunction(id: "photoPresenterWindows", value: helper)
                        }
                    } else {
                        print("Écran non trouvé : \(viewPosition.screenName ?? "")")
                    }
                    
                    
                    index += 1
                }
                
            case nbOfViews:
                index += 1
                
            default:
                timer?.invalidate()
                for helper in helpers {
                    if let pos = helper.windowPos,
                       let windowId = helper.windowId,
                       let window = NSApp.windows.first(where: { $0.identifier?.rawValue == windowId })
                    {
                        let frame = NSRect(
                            x: pos.x,
                            y: pos.y,
                            width: pos.width,
                            height: pos.height
                        )
                        
                        window.setFrame(frame, display: true)
                        window.title = helper.presenter.photoPresenterHeader.name
                    }
                }
            }
            
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
    
    private func screenIsAvailable(_ screenName: String?) -> Bool {
        
        if let sn = screenName {
            for id in screensInfo.screennames {
               if id == sn {
                    return true
                }
            }
        }
        
        return false
    }
}
