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
    
    private var title: String;
    private var directories: [String] = []
    private var ratio: Double?

    var body: some View {
        ZStack {
            if displayImage {
                
                KeyCatcherView { event in
                    slideShowController.keyDown(with: event)
                }
                
                // To do - exception si currentIndex dépasse le tableau
                // tableau vide plante

                Group {
                    if viewSetting.isExpansionMode ?? false{
                        Image(nsImage: imageController.getImage())
                            .resizable()
                          //  .scaledToFill()
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
                .contextMenu {

                    Button(action: {
                        viewPosition.isOnTop!.toggle()
                    }) {
                        Label("Toujours visible", systemImage: (viewPosition.isOnTop ?? false) ? "checkmark.circle.fill" : "circle")
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
        }
    }

    init(
        name title: String,
        presenterDataSource: PhotoPresenterDataSource,
        viewPosition: WindowPosition,
        setting: ViewSetting,
        fastLoading: FastLoading
    ) {
        self._slideShowController = StateObject(wrappedValue: SlideShowController(viewSetting: setting, fastLoading: fastLoading))
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
