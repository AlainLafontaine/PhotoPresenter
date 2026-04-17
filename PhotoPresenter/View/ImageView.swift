//
//  ImageView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import AppKit  // Nécessaire pour NSImage
import SwiftUtilities

struct ImageView: View {
    
    @ObservedObject private var viewSetting: ViewSetting
    @ObservedObject private var viewPosition: WindowPosition
    
    @StateObject private var slideShowController: SlideShowController
    @StateObject private var imageController : ImageController
    
    @State private var displayImage = false
    @State private var displayParameters: Bool = false
    @State private var savePauseState = false
    @State private var isResizing = false
    @State private var title: String
    
    private var directories: [String] = []
    private var ratio: Double?

    var body: some View {
        ZStack {
            if displayImage {
                
                KeyCatcherView { event in
                    switch event.keyCode {
                    case 24, 69: // + (plus) - Augmenter la transparence
                        if let currentFactor = viewSetting.transparentFactor {
                            viewSetting.transparentFactor = min(currentFactor + 0.05, 1.0)
                        } else {
                            viewSetting.transparentFactor = 0.05
                        }
                        
                    case 27, 78: // - (moins) - Diminuer la transparence
                        if let currentFactor = viewSetting.transparentFactor {
                            viewSetting.transparentFactor = max(currentFactor - 0.05, 0.0)
                        } else {
                            viewSetting.transparentFactor = 0.95
                        }
                        
                    default:
                        slideShowController.keyDown(with: event)
                        break
                    }
                }
                
                // To do - exception si currentIndex dépasse le tableau
                // tableau vide plante

                Group {
                    if !isResizing &&  viewSetting.isExpansionMode ?? false  {
                        Image(nsImage: imageController.getImage())
                            .resizable()
                    } else {
                        Image(nsImage: imageController.getImage())
                            .resizable()
                            .scaledToFit()
                    }
                }
                .onAppear {
                    slideShowController.start()
                    if !DisplaySpaceView.slideShowControllers.contains(where: { $0 === self.slideShowController }) {
                        DisplaySpaceView.slideShowControllers.append(self.slideShowController)
                    }
                }
                .background(WindowAccessor { window in
                    window.title = "\(title)"
                })
                .onChange(of: viewSetting.isTransparent) { _, isTransparent in
                    // Mettre à jour la transparence de la fenêtre
                    if let window = NSApp.keyWindow {
                        if isTransparent ?? false {
                            window.isOpaque = false
                            window.backgroundColor = NSColor.clear
                            window.alphaValue = viewSetting.transparentFactor ?? 1.0
                        } else {
                            window.isOpaque = true
                            window.backgroundColor = NSColor.windowBackgroundColor
                            window.alphaValue = 1.0
                        }
                    }
                }
                .onChange(of: viewSetting.transparentFactor) { _, factor in
                    // Mettre à jour le niveau de transparence
                    if viewSetting.isTransparent ?? false, let window = NSApp.keyWindow {
                        window.alphaValue = factor ?? 1.0
                    }
                }
                .contextMenu {
                    Button(action: {
                        viewPosition.isOnTop!.toggle()
                    }) {
                        Label("Toujours visible", systemImage: (viewPosition.isOnTop ?? false) ? "checkmark.circle.fill" : "circle")
                    }

                    Button(action: {
                        viewSetting.isTransparent!.toggle()
                    }) {
                        Label("Transparence", systemImage: (viewSetting.isTransparent ?? false) ? "checkmark.circle.fill" : "circle")
                    }

                    Divider() // ⬅️ Séparateur visuel
                    
                    Button(action: {
                        viewSetting.isPaused.toggle()
                    }) {
                        Label("Pause", systemImage: viewSetting.isPaused ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Button(action: {
                        if viewSetting.isReverse {
                            viewSetting.isReverse.toggle()
                        } else {
                            if viewSetting.isRandomizing {
                                viewSetting.isRandomizing.toggle()
                            }
                            viewSetting.isReverse.toggle()
                        }
                    }) {
                        Label("Inverser", systemImage: viewSetting.isReverse ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Button(action: {
                        if viewSetting.isRandomizing {
                            viewSetting.isRandomizing.toggle()
                        } else {
                            if viewSetting.isReverse {
                                viewSetting.isReverse.toggle()
                            }
                            viewSetting.isRandomizing.toggle()
                        }
                    }) {
                        Label("Aléatoire", systemImage: viewSetting.isRandomizing ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Divider() // ⬅️ Séparateur visuel
                    
                    Button(action: {
                        viewSetting.isExpansionMode?.toggle()
                    }) {
                        Label("Expension", systemImage: viewSetting.isExpansionMode! ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Button(action: {
                        viewSetting.isOverlayDisplayInfo?.toggle()
                    }) {
                        Label("Information", systemImage: viewSetting.isOverlayDisplayInfo! ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Button(action: {
                        viewSetting.isInCommunity?.toggle()
                    }) {
                        Label("Liée à la communauté", systemImage: viewSetting.isInCommunity! ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Divider() // ⬅️ Séparateur visuel
                    
                    Button(action: {
                        viewSetting.intervalTimer = viewSetting.intervalTimer
                        savePauseState = viewSetting.isPaused
                        
                        if (!viewSetting.isPaused) {
                            viewSetting.isPaused.toggle()
                        }
                        displayImage.toggle()
                        displayParameters.toggle()
                    }) {
                        Text("Parametres")
                    }
                }
                
                Group {
                    FloatingLabelView(
                        text: slideShowController.fastLoading.fileInfos[viewSetting.currentIndex].filename,
                        isDisplay: Binding(
                            get: { viewSetting.isOverlayDisplayInfo ?? false },
                            set: { viewSetting.isOverlayDisplayInfo = $0 }
                        ),
                        position: .halfTop,
                        opacityMinimale: 0.01
                    )

                    if let ratio = self.ratio {
                        FloatingLabelView(
                            text: "\(ratio) r",
                            isDisplay: Binding(
                                get: { viewSetting.isOverlayDisplayInfo ?? false },
                                set: { viewSetting.isOverlayDisplayInfo = $0 }
                            ),
                            position: .leftBottom,
                            opacityMinimale: 0.01
                        )
                    }
                    
                    FloatingLabelView(
                        text: "\(viewSetting.currentIndex + 1) / \(slideShowController.fastLoading.fileInfos.count)",
                        isDisplay: Binding(
                            get: { viewSetting.isOverlayDisplayInfo ?? false },
                            set: { viewSetting.isOverlayDisplayInfo = $0 }
                        ),
                        position: .halfBottom,
                        opacityMinimale: 0.01
                    )
                    
                    FloatingLabelView(
                        text: "\(viewSetting.intervalTimer) s",
                        isDisplay: Binding(
                            get: { viewSetting.isOverlayDisplayInfo ?? false },
                            set: { viewSetting.isOverlayDisplayInfo = $0 }
                        ),
                        position: .rightBottom,
                        opacityMinimale: 0.01
                    )
                    
                    FloatingLabelView(
                        text: "\(title)",
                        isDisplay: Binding(
                            get: { viewSetting.isOverlayDisplayInfo ?? false },
                            set: { viewSetting.isOverlayDisplayInfo = $0 }
                        ),
                        position: .leftTop,
                        opacityMinimale: 0.01
                    )
                }
            } else {
                Text("Initiation des images...").onAppear { displayImage = true }
            }
            
            // Affichage pour la vue qui affiche les paramètres version
            if displayParameters {
                ImageParametersView(intervalTimer: $viewSetting.intervalTimer) { didApply in
                    if didApply {
                        viewSetting.intervalTimer = viewSetting.intervalTimer
                        displayParameters.toggle()
                        displayImage.toggle()
                        slideShowController.start()
                        viewSetting.isPaused = savePauseState
                    } else {
                        displayParameters.toggle()
                        displayImage.toggle()
                        slideShowController.start()
                        viewSetting.isPaused = savePauseState
                    }
                }
            }
        }.background(
            WindowResizeObserver(
                onStart: { isResizing = true },
                onEnd: { isResizing = false }
            )
        ).background(
            WindowOcclusionObserver { isVisible in
                slideShowController.isWindowVisible = isVisible
            }
        ).background(
            WindowLevelController(isOnTop: viewPosition.isOnTop ?? false)
        ).onHover { (entered) in
            if entered {
                if NSEvent.modifierFlags.contains(.control) {
/*
                    let width = viewPosition.width * 2
                    let height = viewPosition.height * 2
                    
                    let newFrame = NSRect(
                        x: viewPosition.x,
                        y: viewPosition.y,
                        width: width,
                        height: height
                    )
*/
//                    NSWorkspace.shared.frontmostApplication?.setValue(newFrame, forKey: "windowFrame")
                }
                
               // viewPosition
            } else {
/*
                let newFrame = NSRect(
                    x: viewPosition.x,
                    y: viewPosition.y,
                    width: viewPosition.width,
                    height: viewPosition.height
                )
 */
//                NSWorkspace.shared.frontmostApplication?.setValue(newFrame, forKey: "windowFrame")
            }
        }
    }

    init(
        name title: String,
        presenterDataSource: PhotoPresenterDataSource,
        viewPosition: WindowPosition,
        setting: ViewSetting,
        fastLoading: FastLoading,
        communityParameter: Binding<CommunityParameter>
    ) {
        self._slideShowController = StateObject(wrappedValue: SlideShowController(viewSetting: setting, fastLoading: fastLoading, communityParameter: communityParameter))
        self._imageController = StateObject(wrappedValue: ImageController(dataSource: presenterDataSource,  viewSetting: setting, fastLoading: fastLoading))
        self.viewSetting = setting
        self.viewPosition = viewPosition
        self.title = title
        self.ratio = presenterDataSource.ratio
    }
    
    private mutating func getDirectoryIndex(_ path: String) -> Int {
        var index = 0
        
        if let ind = directories.firstIndex(of: path) {
            index = ind
        } else {
            directories.append(path)
            index = directories.count - 1
        }
        
        return index
    }
}
