//
//  ImageView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import AppKit  // Nécessaire pour NSImage
import SwiftUtilities

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                callback(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct ImageView: View {
    
    @ObservedObject private var viewSetting: ViewSetting
    
    @StateObject private var sideShowController: SlideShowController
    @StateObject private var imageController : ImageController

    @State private var displayImage = false
    @State private var displayParameters: Bool = false
    @State private var savePauseState = false
    
    private var title: String;
    private var directories: [String] = []

    var body: some View {
        ZStack {
            if displayImage {
                KeyCatcherView { event, isShiftPressed in
                    sideShowController.keyDown(with: event)
                }
                
                // To do - exception si currentIndex dépasse le tableau
                // tableau vide plante

                Image(
                   nsImage: imageController.getImage()
                )
                .resizable()
                .scaledToFit()
//                .scaledToFill()
                .onAppear {
                    sideShowController.start()
                }
                .background(WindowAccessor { window in
                    window.title = "\(title)"
                })
                .contextMenu {
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
                        viewSetting.displayFilename.toggle()
                    }) {
                        Label("Nom du fichier", systemImage: viewSetting.displayFilename ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Button(action: {
                        viewSetting.displayNumImage.toggle()
                    }) {
                        Label("# Image", systemImage: viewSetting.displayNumImage ? "checkmark.circle.fill" : "circle")
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
                
                VStack {
                    FloatingLabelView(
                        text: sideShowController.fastLoading.fileInfos[viewSetting.currentIndex].filename,
                        isDisplay: $viewSetting.displayFilename,position: .halfTop,
                        opacityMinimale: 0.01
                    )
                }
                
                VStack {
                    FloatingLabelView(
                        text: "\(viewSetting.currentIndex + 1) sur \(sideShowController.fastLoading.fileInfos.count)",
                        isDisplay: $viewSetting.displayNumImage,
                        opacityMinimale: 0.01
                    );
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
                        sideShowController.start()
                        viewSetting.isPaused = savePauseState
                    } else {
                        displayParameters.toggle()
                        displayImage.toggle()
                        sideShowController.start()
                        viewSetting.isPaused = savePauseState
                    }
                }
            }
        }
    }

    init(
        name title: String,
        presenterDataSource: PhotoPresenterDataSource,
        setting: ViewSetting,
        fastLoading: FastLoading
    ) {
        self._sideShowController = StateObject(wrappedValue: SlideShowController(viewSetting: setting, fastLoading: fastLoading))
        self._imageController = StateObject(wrappedValue: ImageController(dataSource: presenterDataSource,  viewSetting: setting, fastLoading: fastLoading))
        self.viewSetting = setting
        self.title = title
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
