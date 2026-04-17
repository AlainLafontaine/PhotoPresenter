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
    @ObservedObject private var communityParam: CommunityParameter

    @StateObject private var slideShowController: SlideShowController
    @StateObject private var imageController : ImageController
    
    @State private var displayImage = false
    @State private var displayParameters: Bool = false
    @State private var savePauseState = false
    @State private var isResizing = false
    @State private var title: String
    @State private var capturedWindow: NSWindow? = nil
    @State private var savedExpansionMode: Bool = false
    @State private var favoriteRefresh: Bool = false
    @State private var fKeyActive: Bool = false
    @State private var keyDownMonitor: Any? = nil
    @State private var keyUpMonitor: Any? = nil
    
    private var directories: [String] = []
    private var ratio: Double?

    var body: some View {
        ZStack {
            if displayImage {
                
                KeyCatcherView { event in
                    switch event.keyCode {
                    case 24, 69: // + (plus) - Augmenter l'opacité
                        if !(viewSetting.isTransparent ?? false) {
                            viewSetting.isTransparent = true
                            capturedWindow?.isOpaque = false
                            capturedWindow?.backgroundColor = .clear
                        }
                        let newFactorPlus = min((min(viewSetting.transparentFactor ?? 1.0, 1.0)) + 0.05, 1.0)
                        viewSetting.transparentFactor = newFactorPlus
                        capturedWindow?.alphaValue = newFactorPlus

                    case 27, 78: // - (moins) - Diminuer l'opacité
                        if !(viewSetting.isTransparent ?? false) {
                            viewSetting.isTransparent = true
                            capturedWindow?.isOpaque = false
                            capturedWindow?.backgroundColor = .clear
                        }
                        let newFactorMinus = max((min(viewSetting.transparentFactor ?? 1.0, 1.0)) - 0.05, 0.0)
                        viewSetting.transparentFactor = newFactorMinus
                        capturedWindow?.alphaValue = newFactorMinus
                        
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
                    window.collectionBehavior.insert(.fullScreenPrimary)
                    capturedWindow = window
                })
                .onChange(of: viewSetting.isTransparent) { _, isTransparent in
                    guard let window = capturedWindow else { return }
                    if isTransparent ?? false {
                        window.isOpaque = false
                        window.backgroundColor = .clear
                        window.alphaValue = min(viewSetting.transparentFactor ?? 1.0, 1.0)
                    } else {
                        window.isOpaque = true
                        window.backgroundColor = .windowBackgroundColor
                        window.alphaValue = 1.0
                    }
                }
                .onChange(of: viewSetting.transparentFactor) { _, factor in
                    guard viewSetting.isTransparent ?? false,
                          let window = capturedWindow,
                          let f = factor else { return }
                    window.alphaValue = min(f, 1.0)
                }
                .onChange(of: communityParam.transparentFactor) { _, factor in
                    guard viewSetting.isInCommunity ?? false,
                          let window = capturedWindow else { return }
                    if !(viewSetting.isTransparent ?? false) {
                        viewSetting.isTransparent = true
                        window.isOpaque = false
                        window.backgroundColor = .clear
                    }
                    viewSetting.transparentFactor = factor
                    window.alphaValue = factor
                }
                .onTapGesture(count: 2) {
                    guard let window = capturedWindow else { return }
                    if viewPosition.isFullPage {
                        let frame = NSRect(x: viewPosition.x, y: viewPosition.y,
                                          width: viewPosition.width, height: viewPosition.height)
                        window.setFrame(frame, display: true, animate: true)
                        viewSetting.isExpansionMode = savedExpansionMode
                        viewPosition.isFullPage = false
                    } else {
                        if let screenFrame = window.screen?.frame {
                            savedExpansionMode = viewSetting.isExpansionMode ?? false
                            viewSetting.isExpansionMode = false
                            window.setFrame(screenFrame, display: true, animate: true)
                            viewPosition.isFullPage = true
                        }
                    }
                }
                .contentShape(Rectangle())
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
                        let currentFileInfo = slideShowController.fastLoading.fileInfos[viewSetting.currentIndex]
                        currentFileInfo.isFavorite.toggle()
                        favoriteRefresh.toggle()
                    }) {
                        let isFav = slideShowController.fastLoading.fileInfos[viewSetting.currentIndex].isFavorite
                        Label("Favori", systemImage: isFav ? "heart.fill" : "heart")
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
                .onTapGesture(count: 1) {
                    guard fKeyActive else { return }
                    let currentFileInfo = slideShowController.fastLoading.fileInfos[viewSetting.currentIndex]
                    currentFileInfo.isFavorite.toggle()
                    favoriteRefresh.toggle()
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

                let _ = favoriteRefresh
                if !slideShowController.fastLoading.fileInfos.isEmpty &&
                   slideShowController.fastLoading.fileInfos[viewSetting.currentIndex].isFavorite {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "heart.fill")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.red)
                                .opacity(0.55)
                                .padding(10)
                        }
                        Spacer()
                    }
                    Rectangle()
                        .stroke(Color.red.opacity(0.4), lineWidth: 15)
                        .allowsHitTesting(false)
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
        ).onAppear {
            keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 3 { fKeyActive = true }
                return event
            }
            keyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { event in
                if event.keyCode == 3 { fKeyActive = false }
                return event
            }
        }.onDisappear {
            if let monitor = keyDownMonitor {
                NSEvent.removeMonitor(monitor)
                keyDownMonitor = nil
            }
            if let monitor = keyUpMonitor {
                NSEvent.removeMonitor(monitor)
                keyUpMonitor = nil
            }
        }.onHover { (entered) in
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
        self.communityParam = communityParameter.wrappedValue
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
