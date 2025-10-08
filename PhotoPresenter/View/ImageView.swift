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
    
    @StateObject private var controller: SlideShowController
    
    var viewSetting: ViewSetting
    
    @State private var displayImage = false
    @State private var displayNumImage: Bool
    @State private var displayFilename: Bool
    @State private var displayParameters: Bool = false
    @State private var intervalTimer: Double
    @State private var savePauseState = false
    
    private var title: String;
    private var directories: [String] = []

    var body: some View {
        ZStack {
            if displayImage {
                KeyCatcherView { event, isShiftPressed in
                    controller.keyDown(with: event)
                }
                
                Image(
                    nsImage: controller.fileInfos[controller.currentIndex].nsImage
                )
                .resizable()
                .scaledToFit()
                .onAppear {
                    controller.start()
                }
                .background(WindowAccessor { window in
                    window.title = "\(title)"
                })
                .contextMenu {
                    Button(action: {
                        controller.isPaused.toggle()
                    }) {
                        Label("Pause", systemImage: controller.isPaused ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Button(action: {
                        if controller.isReverse {
                            controller.isReverse.toggle()
                        } else {
                            if controller.isRandomizing {
                                controller.isRandomizing.toggle()
                            }
                            controller.isReverse.toggle()
                        }
                    }) {
                        Label("Inverser", systemImage: controller.isReverse ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Button(action: {
                        if controller.isRandomizing {
                            controller.isRandomizing.toggle()
                        } else {
                            if controller.isReverse {
                                controller.isReverse.toggle()
                            }
                            controller.isRandomizing.toggle()
                        }
                    }) {
                        Label("Aléatoire", systemImage: controller.isRandomizing ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Divider() // ⬅️ Séparateur visuel
                    
                    Button(action: {
                        displayFilename.toggle()
                    }) {
                        Label("Nom du fichier", systemImage: displayFilename ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Button(action: {
                        displayNumImage.toggle()
                    }) {
                        Label("# Image", systemImage: displayNumImage ? "checkmark.circle.fill" : "circle")
                    }
                    
                    Divider() // ⬅️ Séparateur visuel
                    
                    Button(action: {
                        intervalTimer = controller.intervalTimer
                        savePauseState = controller.isPaused
                        
                        if (!controller.isPaused) {
                            controller.isPaused.toggle()
                        }
                        displayImage.toggle()
                        displayParameters.toggle()
                    }) {
                        Text("Parametres")
                    }
                }
                
                VStack {
                    FloatingLabelView(
                        text: controller.fileInfos[controller.currentIndex].filename,
                        isDisplay: $displayFilename,position: .halfTop,
                        opacityMinimale: 0.1
                    )
                }
                
                VStack {
                    FloatingLabelView(
                        text: "\(controller.currentIndex + 1) sur \(controller.fileInfos.count)",
                        isDisplay: $displayNumImage,
                        opacityMinimale: 0.1
                    );
                }
            } else {
                Text("Initiation des images...").onAppear { displayImage = true }
            }
            
            // Affichage pour la vue qui affiche les paramètresversion
            if displayParameters {
                ParametersView(intervalTimer: $intervalTimer) { didApply in
                    if didApply {
                        controller.intervalTimer = intervalTimer
                        displayParameters.toggle()
                        displayImage.toggle()
                        controller.start()
                        controller.isPaused = savePauseState
                    } else {
                        displayParameters.toggle()
                        displayImage.toggle()
                        controller.start()
                        controller.isPaused = savePauseState
                    }
                }
            }
        }
    }

    init(name title: String, setting: ViewSetting) {
        _controller = StateObject(wrappedValue: SlideShowController(viewSetting: setting))
        
        self.viewSetting = setting
        
        displayNumImage = setting.displayNumImage
        displayFilename = setting.displayFilename
        intervalTimer = setting.intervalTimer
        
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
