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
    @State private var uninterestingRefresh: Bool = false
    @State private var fKeyActive: Bool = false
    @State private var iKeyActive: Bool = false
    @State private var isShiftPressed: Bool = false           // §5 — Shift révèle infos + pictogrammes
    @State private var isHoveringPictogramZone: Bool = false  // §6 — survol de la zone des pictogrammes
    @State private var keyDownMonitor: Any? = nil
    @State private var keyUpMonitor: Any? = nil
    @State private var flagsMonitor: Any? = nil
    @State private var windowStyle: NSWindow.StyleMask? = nil
    @State private var displayedIndex: Int = 0              // index réellement affiché (pilote la transition)
    @State private var activeTransition: AnyTransition = .identity
    @State private var transitionStep: Int = 0             // compteur monotone pilotant le z-index (Recouvrement/Dévoilement)

    private var directories: [String] = []
    private var ratio: Double?

    // MARK: - Transition (Evo_004)

    /// Image à l'index donné avec sa logique d'affichage (expansion vs ajusté).
    /// Rendue **par index** (et non `currentIndex`) pour que la vue sortante
    /// conserve l'ancienne image pendant la transition.
    @ViewBuilder private func transitionImage(at index: Int) -> some View {
        if !isResizing && viewSetting.isExpansionMode ?? false {
            Image(nsImage: imageController.getImage(at: index))
                .resizable()
        } else {
            Image(nsImage: imageController.getImage(at: index))
                .resizable()
                .scaledToFit()
        }
    }

    /// Durée de la transition (s), 0 = aucune. Déterminée par la durée d'affichage
    /// de la source active. Cas particulier : si le présentateur est en pause au
    /// moment du changement, le seul déclencheur possible est la navigation clavier
    /// (les timers ignorent les présentateurs en pause) → 1 s.
    private var transitionDuration: Double {
        if viewSetting.isPaused { return 1.0 }

        let displayDuration: Double
        if communityParam.digitalSignageMode {
            displayDuration = communityParam.loopDuration * Double(communityParam.loopsPerImage)
        } else if communityParam.isCommunityModeActived {
            displayDuration = communityParam.intervalTimer
        } else {
            displayDuration = viewSetting.intervalTimer
        }

        if displayDuration < 1.0 { return 0.0 }   // < 1 s : aucune transition
        if displayDuration <= 2.0 { return 0.5 }  // 1 à 2 s : 0,5 s
        return 1.0                                 // > 2 s : 1 s
    }

    /// Réagit au changement d'image (`currentIndex`). Le sens du glissement
    /// (Horizontal/Vertical) dépend de la comparaison d'index. On fixe d'abord la
    /// transition — la vue sortante adopte ainsi le bon bord de sortie — puis on
    /// bascule l'index affiché au cycle suivant pour déclencher l'animation.
    private func handleIndexChange(to newIndex: Int) {
        let oldIndex = displayedIndex
        guard newIndex != oldIndex else { return }

        let mode = communityParam.transitionMode
        let duration = transitionDuration

        // Mode Aucune ou durée nulle : changement instantané (comportement actuel).
        guard mode != .none, duration > 0 else {
            activeTransition = .identity
            displayedIndex = newIndex
            return
        }

        activeTransition = mode.anyTransition(forward: newIndex > oldIndex)
        DispatchQueue.main.async {
            // transitionStep et displayedIndex changent dans la MÊME transaction :
            // la vue entrante (step courant) et la vue sortante (step précédent)
            // obtiennent ainsi des z-index distincts, pour Recouvrement/Dévoilement.
            withAnimation(.easeInOut(duration: duration)) {
                transitionStep += 1
                displayedIndex = newIndex
            }
        }
    }

    /// Facteur de z-index selon le mode : la vue entrante a un `transitionStep`
    /// supérieur à la sortante.
    /// - Recouvrement (+1) : la nouvelle image passe au-dessus de l'ancienne.
    /// - Dévoilement (-1) : l'ancienne reste au-dessus et glisse pour dévoiler.
    /// - autres (0) : ordre indifférent.
    private func zIndexFactor(for mode: ImageTransition) -> Double {
        switch mode {
        case .cover:  return 1
        case .reveal: return -1
        default:      return 0
        }
    }

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

                    case 44, 75: // / - Opacité à 0 (invisible)
                        if !(viewSetting.isTransparent ?? false) {
                            viewSetting.isTransparent = true
                            capturedWindow?.isOpaque = false
                            capturedWindow?.backgroundColor = .clear
                        }
                        viewSetting.transparentFactor = 0.0
                        capturedWindow?.alphaValue = 0.0

                    case 67: // * (pavé numérique) - Opacité à 1 (plein)
                        viewSetting.transparentFactor = 1.0
                        capturedWindow?.alphaValue = 1.0

                    default:
                        slideShowController.keyDown(with: event)
                        break
                    }
                }
                
                // To do - exception si currentIndex dépasse le tableau
                // tableau vide plante

                ZStack {
                    transitionImage(at: displayedIndex)
                        .id(displayedIndex)
                        .zIndex(zIndexFactor(for: communityParam.transitionMode) * Double(transitionStep))
                        .transition(activeTransition)
                }
                .mask { gradientMask }
                .onAppear {
                    slideShowController.start()
                    if !DisplaySpaceView.slideShowControllers.contains(where: { $0 === self.slideShowController }) {
                        DisplaySpaceView.slideShowControllers.append(self.slideShowController)
                    }
                }
                .onChange(of: viewSetting.currentIndex) { _, newIndex in
                    handleIndexChange(to: newIndex)
                }
                .background(WindowAccessor { window in
                    window.title = "\(title)"
                    window.collectionBehavior.insert(.fullScreenPrimary)
                    window.isMovableByWindowBackground = true
                    capturedWindow = window
                    if (viewSetting.transparencyGradientDirection ?? .none) != .none {
                        window.isOpaque = false
                        window.backgroundColor = .clear
                    }
                })
                .onChange(of: communityParam.fullPresenterMode) { _, isFullPresenterMode in
                    guard let window = capturedWindow else { return }
                    if isFullPresenterMode {
                        windowStyle = window.styleMask
                        window.styleMask = [.borderless, .resizable]
                        
                        if let isTransparent = viewSetting.isTransparent, let transparencyGradientDirection = viewSetting.transparencyGradientDirection {
                            window.isMovableByWindowBackground = isTransparent || transparencyGradientDirection != TransparencyGradientDirection.none
                        }
                        else {
                            window.isMovableByWindowBackground = false;
                        }
                        
                        viewSetting.isExpansionMode = true
                    } else {
                        if let windowStyle = windowStyle {
                            window.styleMask = windowStyle
                        }

                        window.isMovableByWindowBackground = true
                    }
                }
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
                .onChange(of: viewSetting.transparencyGradientDirection) { _, direction in
                    guard !(viewSetting.isTransparent ?? false) else { return }
                    guard let window = capturedWindow else { return }
                    if (direction ?? .none) != .none {
                        window.isOpaque = false
                        window.backgroundColor = .clear
                    } else if !(viewSetting.isTransparent ?? false) {
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

                    // §7 — Inverse le dégradé de transparence. Libellé = direction
                    // inversée ; désactivé quand aucun dégradé n'est actif.
                    let gradientDirection = viewSetting.transparencyGradientDirection ?? .none
                    Button(action: {
                        viewSetting.transparencyGradientDirection = gradientDirection.inverted
                    }) {
                        Text(gradientDirection.inverseLabel)
                    }
                    .disabled(gradientDirection == .none)

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
                        viewSetting.isShowPictograms = !(viewSetting.isShowPictograms ?? true)
                    }) {
                        Label("Pictogrammes", systemImage: (viewSetting.isShowPictograms ?? true) ? "checkmark.circle.fill" : "circle")
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

                    Button(action: {
                        let currentFileInfo = slideShowController.fastLoading.fileInfos[viewSetting.currentIndex]
                        currentFileInfo.isUninteresting.toggle()
                        uninterestingRefresh.toggle()
                    }) {
                        let isUnint = slideShowController.fastLoading.fileInfos[viewSetting.currentIndex].isUninteresting
                        Label("Inintéressant", systemImage: isUnint ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    }

                    Divider() // ⬅️ Séparateur visuel

                    Menu {
                        Button(action: {
                            viewSetting.isDisplayFavorite = !(viewSetting.isDisplayFavorite ?? false)
                        }) {
                            Label("Favori", systemImage: (viewSetting.isDisplayFavorite ?? false) ? "heart.fill" : "heart")
                        }
                        Button(action: {
                            viewSetting.isDisplayUninteresting = !(viewSetting.isDisplayUninteresting ?? false)
                        }) {
                            Label("Inintéressant", systemImage: (viewSetting.isDisplayUninteresting ?? false) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        }
                    } label: {
                        Label("Afficher", systemImage: "eye")
                    }

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
                    if fKeyActive {
                        let currentFileInfo = slideShowController.fastLoading.fileInfos[viewSetting.currentIndex]
                        currentFileInfo.isFavorite.toggle()
                        favoriteRefresh.toggle()
                    } else if iKeyActive {
                        let currentFileInfo = slideShowController.fastLoading.fileInfos[viewSetting.currentIndex]
                        currentFileInfo.isUninteresting.toggle()
                        uninterestingRefresh.toggle()
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

                let _ = favoriteRefresh
                let isFav = !slideShowController.fastLoading.fileInfos.isEmpty &&
                            slideShowController.fastLoading.fileInfos[viewSetting.currentIndex].isFavorite
                let isCommunity = viewSetting.isInCommunity ?? false
                let isPaused = viewSetting.isPaused

                // §3 — Le Favori est toujours affiché quand l'image est favorite.
                //
                // §6 — Les pictogrammes contextuels (pause, communauté) ne sont visibles,
                // quand l'option Pictogrammes est active, que si la souris survole la zone
                // d'affichage des pictogrammes (coin supérieur droit). Shift les force
                // « comme si l'option était activée » (§5). La zone des infos est
                // indépendante de celle des pictogrammes.
                let optionPictograms = (viewSetting.isShowPictograms ?? true) && isHoveringPictogramZone
                let showContextPictograms = isShiftPressed || optionPictograms
                let showPause = isPaused && showContextPictograms
                let showCommunity = isCommunity && showContextPictograms

                VStack {
                    HStack {
                        Spacer()
                        // Zone de survol stable (même quand aucune icône n'est visible)
                        // bornée au coin supérieur droit, qui pilote isHoveringPictogramZone.
                        HStack(spacing: 4) {
                            if showPause {
                                Image(systemName: "pause.fill")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(red: 0.6, green: 0.35, blue: 0.0))
                                    .padding(5)
                                    .background(Circle().fill(Color.white))
                                    .opacity(0.75)
                            }
                            if showCommunity {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(red: 0.0, green: 0.1, blue: 0.6))
                                    .padding(5)
                                    .background(Circle().fill(Color.white))
                                    .opacity(0.75)
                            }
                            if isFav {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(red: 0.6, green: 0.0, blue: 0.0))
                                    .padding(5)
                                    .background(Circle().fill(Color.white))
                                    .opacity(0.75)
                            }
                        }
                        .frame(width: 130, height: 36, alignment: .trailing)
                        .contentShape(Rectangle())
                        .background(MouseHoverObserver { hovering in
                            isHoveringPictogramZone = hovering
                        })
                    }
                    .padding(10)
                    Spacer()
                }
                let _ = uninterestingRefresh
                if !slideShowController.fastLoading.fileInfos.isEmpty &&
                   slideShowController.fastLoading.fileInfos[viewSetting.currentIndex].isUninteresting {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "hand.thumbsdown.fill")
                                .font(.system(size: 72, weight: .regular))
                                .foregroundColor(Color(red: 0.6, green: 0.0, blue: 0.0))
                                .opacity(1.0)
                                .padding(10)
                        }
                        Spacer()
                    }
                    GeometryReader { geo in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                            path.move(to: CGPoint(x: geo.size.width, y: 0))
                            path.addLine(to: CGPoint(x: 0, y: geo.size.height))
                        }
                        .stroke(Color.red.opacity(0.68), lineWidth: 30)
                    }
                    .allowsHitTesting(false)
                }
            } else {
                Text("Initiation des images...").onAppear { displayImage = true }
            }
            
            // Affichage pour la vue qui affiche les paramètres version
            if displayParameters {
                ImageParametersView(intervalTimer: $viewSetting.intervalTimer, transparencyGradientDirection: $viewSetting.transparencyGradientDirection, opacityStart: $viewSetting.opacityStart, opacityEnd: $viewSetting.opacityEnd) { didApply in
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
                onStart: {
                    guard let window = capturedWindow else { return }
                    window.backgroundColor = .windowBackgroundColor
                    isResizing = true;
                },
                onEnd: {
                    guard let window = capturedWindow else { return }
                    window.backgroundColor =  (viewSetting.isTransparent ?? false) ? .clear : .windowBackgroundColor
                    isResizing = false
                }
            )
        ).background(
            WindowOcclusionObserver { isVisible in
                slideShowController.isWindowVisible = isVisible
            }
        ).background(
            WindowLevelController(isOnTop: viewPosition.isOnTop ?? false)
        ).background(
            WindowGradientController(
                isGradientActive: (viewSetting.transparencyGradientDirection ?? TransparencyGradientDirection.none) != TransparencyGradientDirection.none
            )
        ).onAppear {
            keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 3 { fKeyActive = true }
                if event.keyCode == 34 { iKeyActive = true }
                return event
            }
            keyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { event in
                if event.keyCode == 3 { fKeyActive = false }
                if event.keyCode == 34 { iKeyActive = false }
                return event
            }
            // §5 — Suit l'état de la touche Shift pour révéler infos + pictogrammes.
            flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                isShiftPressed = event.modifierFlags.contains(.shift)
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
            if let monitor = flagsMonitor {
                NSEvent.removeMonitor(monitor)
                flagsMonitor = nil
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

    private var gradientMask: some View {
        let direction = viewSetting.transparencyGradientDirection ?? TransparencyGradientDirection.none
        let start = viewSetting.opacityStart ?? 1.0
        let end = viewSetting.opacityEnd ?? 0.0

        let (startPoint, endPoint): (UnitPoint, UnitPoint) = {
            switch direction {
            case .none:        return (.leading, .trailing)
            case .leftToRight: return (.leading, .trailing)
            case .rightToLeft: return (.trailing, .leading)
            case .topToBottom: return (.top, .bottom)
            case .bottomToTop: return (.bottom, .top)
            }
        }()

        let (startLuminance, endLuminance): (Double, Double) = direction == .none
            ? (1.0, 1.0)
            : (start, end)

        // Color.black.opacity(x) : RGB=0 donc l'interpolation prémultipliée reste dans (0,0,0,x),
        // seul l'alpha varie — aucun assombrissement. Le masque utilise uniquement l'alpha.
        return LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(startLuminance), Color.black.opacity(endLuminance)]),
            startPoint: startPoint,
            endPoint: endPoint
        )
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
        self._displayedIndex = State(initialValue: setting.currentIndex)
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
