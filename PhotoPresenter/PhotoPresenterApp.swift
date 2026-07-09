//
//  PhotoPresenterApp.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import AppKit
import UniformTypeIdentifiers  // ✅ nécessaire pour UTType
import SwiftUI
import SwiftUtilities


@main
struct PhotoPresenterApp: App {
    @Environment(\.openWindow) private var openWindow
    
    @State private var communityParam = CommunityParameter()
    
    @State private var loadingInProgress: Bool = false
    @State private var loadingController: PresenterLoadingFileController? = nil
    @State private var pathDisplaySpace: String? = nil
    @State private var displaySpaceViewType: DisplaySpaceViewType = .LibraryView
    @State private var screensInfo: ScreensInfo = getScreenInfo()
    @State private var showTitleBar: Bool = false

    @State private var windowIdentifier: Set<String> = []
    @State private var dataPresenters: DataPresenterMap = DataPresenterMap()
    @State private var emergencyExit: Bool = false
    @State private var back2LastDisplaySpace: String? = nil
    @State private var sharedRessources: SharedRessources = loadSharedResources(path: "/Volumes/Image_Mac/Emergency/sharedRessources.json") ?? SharedRessources()
    
    @StateObject private var displaySpace: DisplaySpace = DisplaySpace(
                                                                fileHeader: FileHeader(fileType: FileType.DisplaySpace),
                                                                displaySpaceHeader: DisplaySpaceHeader(name: "sans nom"),
                                                                viewPositions: [PresenterViewPosition]()
                                                          )
    
    private let presenterLoader: PhotoPresenterLoader = PhotoPresenterLoader()
    private let displaySpaceLoader: DisplaySpaceLoader = DisplaySpaceLoader()
        
    var body: some Scene {

        WindowGroup(id: "displaySpaceWindows") {
            DisplaySpaceView(
                displaySpace: displaySpace,
                sharedRessources: sharedRessources,
                displayView: $displaySpaceViewType,
                requestOpeningPresenter: openFile,
                requestRemovingPresenter: { id in removePresenter(id) },
                communityParameter: $communityParam
            )
            .onAppear() {
                if let window = getDisplaySpaceView() {
                    window.title = displaySpace.displaySpaceHeader.name
                }

                // Différé : le menu principal n'est pas forcément construit
                // au moment du premier onAppear.
                DispatchQueue.main.async {
                    removeSystemCloseMenuItem()
                }
            }
            .background(WindowAccessor { window in
                 window.level = .floating        // Mettre la fenêtre au-dessus
            })
        }.commands {
            CommandGroup(after: .newItem) {
                Button("New") {
                    if pathDisplaySpace != nil {
                        saveAllPhotoPresenter()
                    }

                    closeAllPresenterWindows()
                    resetToInitialState()
                }
                
                Button("Open…") {
                    if let url = openFileDialog() {
                        if !openFile( url) {
                            print("Impossible d'ouvrir le fichier")
                        }
                    }
                }

                Button("Close") {
                    closeActiveView()
                }
                .keyboardShortcut("W", modifiers: [.command])

                Button("Save") {
                    saveAllPhotoPresenter()
                }
                .keyboardShortcut("S", modifiers: [.command])
                
                Button("Save As...") {
                    
                }
            }
            
            CommandGroup(before: .sidebar) {
                Button("Information") {
                    sendCommandToActiveWindow(.information)
                }
                .keyboardShortcut("I", modifiers: [.command])
                
                Button("Presenter") {
                    sendCommandToActiveWindow(.multiImageView)
                }
                .keyboardShortcut("P", modifiers: [.command])
                
                Divider() // 🔹 Séparateur visuel dans le menu principal
                
                Button("Library") {
                    displaySpaceViewType = .LibraryView
                }
                .keyboardShortcut("L", modifiers: [.command])
                
                Button("Dashboard") {
                    displaySpaceViewType = .DashboardView
                }
                .keyboardShortcut("D", modifiers: [.command])
                
                Button("Ratio") {
                    displaySpaceViewType = .RatioSimulatorView
                }
                .keyboardShortcut("R", modifiers: [.command])
                
                Button("Factory") {
                    displaySpaceViewType = .FactoryView
                }
                .keyboardShortcut("F", modifiers: [.command])

                Button("Community parameters") {
                    displaySpaceViewType = .CommunityParamView
                }
                .keyboardShortcut("C", modifiers: [.command])
                
                Divider() // 🔹 Séparateur visuel dans le menu principal

                Button("EDS") {
                    if emergencyExit {
                        if openFile( URL(fileURLWithPath: back2LastDisplaySpace!)) {
                            back2LastDisplaySpace = nil
                        } else {
                            print("Impossible d'ouvrir le fichier")
                        }
                        
                        emergencyExit = false
                    } else {
                        if let emergencyDisplaySpace = displaySpace.emergencyDisplaySpace {
                            back2LastDisplaySpace = pathDisplaySpace!
                            if openFile( URL(fileURLWithPath: emergencyDisplaySpace.filename)) {
                                emergencyExit = true
                            } else {
                                print("Impossible d'ouvrir le fichier")
                            }
                        } else {
                            NSApplication.shared.terminate(nil)
                        }
                    }
                }
                .keyboardShortcut("Z", modifiers: [.command])

                Divider() // 🔹 Séparateur visuel dans le menu principal
            }
        }
        
        WindowGroup(id: "photoPresenterWindows", for: DataPresenterHelp.self) { $helper in
            if let helper = helper {
                PhotoPresenterView(
                    dataHelper: resolveViewPosition(for: helper),
                    dataPresenters: $dataPresenters,
                    windowIdentifier: $windowIdentifier,
                    communityParam: $communityParam
                )
                .onAppear {
                    if displaySpace.presenters == nil {
                        displaySpace.presenters = []
                    }
                    displaySpace.presenters!.append(helper.presenter)

                    dataPresenters[helper.windowId!] = helper
                    loadingInProgress = false
                }
                .onDisappear {
                    // Evo_013 : le retrait des références du DisplaySpace se
                    // fait explicitement aux points de fermeture individuelle
                    // (closePresenterWindow) — jamais ici. Ce .onDisappear a
                    // un déclenchement non garanti et parfois tardif (il peut
                    // suivre le chargement du DisplaySpace suivant) : il ne
                    // fait que le ménage du suivi de fenêtres.
                    if let windowId = helper.windowId {
                        windowIdentifier.remove(windowId)
                        dataPresenters.removeValue(forKey: windowId)
                    }
                }
                // Le niveau de la fenêtre (floating/normal) est géré de façon réactive
                // par WindowLevelController dans ImageView, branché sur viewPosition.isOnTop.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
    
    private func openFileDialog() -> URL? {
        let panel = NSOpenPanel()
       
        panel.title = "Choisir un fichier"
        panel.allowedContentTypes = [ UTType.json ]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        let réponse = panel.runModal()
        return réponse == .OK ? panel.url : nil
    }
    
    private func checkFileType(path: String) -> FileType? {
        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)

            struct RootHeader: Decodable {
                let fileHeader: FileHeader
            }

            let root = try JSONDecoder().decode(RootHeader.self, from: data)
            return root.fileHeader.fileType
        } catch {
            print("Erreur : \(error)")
            return nil
        }
    }
    
    private func getNSWindow(withIdentifier identifier: String) -> NSWindow? {
        return NSApp.windows.first(where: { $0.identifier?.rawValue == identifier })
    }
    
    func sendCommandToActiveWindow(
        _ command: PhotoPresenterViewType
    )
    {
        if let keyWindow = NSApp.keyWindow {
            for (id, controller) in dataPresenters {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id }),
                   window == keyWindow {
                    controller.displayView = command
                    break
                }
            }
        }
    }
    
    func saveAllPhotoPresenter() {
        for (id, dataPresenter) in dataPresenters {
            for window in NSApp.windows {
                if window.identifier?.rawValue == id {
                    if let windowPos = dataPresenter.windowPos, !windowPos.isFullPage {
                        windowPos.x = window.frame.origin.x
                        windowPos.y = window.frame.origin.y
                        windowPos.width = window.frame.size.width
                        windowPos.height = window.frame.size.height
                    }
                    
                    let presenter = dataPresenter.presenter
                    
                    if let _ = presenter.photoPresenterHeader.ratio {}
                    else {
                        var grpGrpRatios: [(ratio: RatioInfo, grpRatios: [RatioInfo])] = []
                        
                        for grpView in presenter.groupedViews {
                            if let fastLoaddings = grpView.fastLoaddings {
                                var grpRatios: [RatioInfo] = []
                                
                                for fastLoadding in fastLoaddings {
                                    var height: Double = 0.0
                                    var width: Double = 0.0
                                    
                                    for fileInfo in fastLoadding.fileInfos {
                                        height += Double(fileInfo.height) / Double(fastLoadding.fileInfos.count)
                                        width += Double(fileInfo.width) / Double(fastLoadding.fileInfos.count)
                                    }
                                    
                                    grpRatios.append(RatioInfo(height: height, width: width))
                                }
                                
                                grpGrpRatios.append((RatioInfo(height: 1.0, width: 1.0), grpRatios))
                            }
                        }
                        
                        switch(presenter.photoPresenterHeader.orientation) {
                            
                        case .Vertical: continue
                        case .Horizontal:
                            for grpGrpRatio: (ratio: RatioInfo, grpRatios: [RatioInfo]) in grpGrpRatios {
                                var minHeight: Double = .greatestFiniteMagnitude
                                
                                for grpRatio in grpGrpRatio.grpRatios {
                                    if minHeight > grpRatio.Height {
                                        minHeight = grpRatio.Height
                                    }
                                }
                                
                                let height: Double = minHeight
                                var width: Double = 0.0
                                
                                for grpRatio in grpGrpRatio.grpRatios {
                                    width += grpRatio.Width * height / grpRatio.Height
                                }
                                
                                grpGrpRatio.ratio.Width = width
                                grpGrpRatio.ratio.Height = height
                            }
                            
                            var width: Double = .greatestFiniteMagnitude
                            for grpGrpRatio: (ratio: RatioInfo, grpRatios: [RatioInfo])  in grpGrpRatios {
                                let ratio = grpGrpRatio.ratio

                                if width > ratio.Width {
                                    width = ratio.Width
                                }
                            }
                            
                            var height: Double = 0.0
                            for grpGrpRatio: (ratio: RatioInfo, grpRatios: [RatioInfo])  in grpGrpRatios {
                                let ratio = grpGrpRatio.ratio
                                
                                height += ratio.Height * width / ratio.Width
                            }
                            
                            presenter.photoPresenterHeader.ratio = (presenter.photoPresenterHeader.orientation == .Horizontal) ? width / height : height / width
                            
                        default:
                            presenter.photoPresenterHeader.ratio = 16.0 / 9.0
                        }
                    }
                    
                    saveToJSONFile(dataPresenter.presenter, filename: dataPresenter.filename)
                }
            }
        }
        
        saveDisplaySpaceFile()
    }
    
    func saveDisplaySpaceFile() {

        snapshotDisplaySpaceState()

        if let path = pathDisplaySpace {
            // Sauvegarde synchrone : on neutralise `presenters` juste autour de
            // l'écriture pour ne pas le persister dans le fichier DisplaySpace.
            let tmp = displaySpace.presenters
            displaySpace.presenters = nil
            saveToJSONFile(displaySpace, filename: path)
            displaySpace.presenters = tmp
        } else {
            promptAndSaveDisplaySpace(regenerateID: false)
        }
    }

    /// Recopie l'état runtime (réglages communautaires, positions de fenêtres,
    /// viewPositions) dans le modèle avant persistance.
    private func snapshotDisplaySpaceState() {

        // Recopie les réglages communautaires live dans le snapshot persisté du
        // DisplaySpace avant l'écriture JSON.
        if displaySpace.communityParameter == nil {
            displaySpace.communityParameter = CommunityParameter()
        }
        displaySpace.communityParameter?.applyPersistedValues(from: communityParam)

        // Pour la sauvegarde de la position de la fenêtre
        if let window = getDisplaySpaceView() {
            if let windowPos = displaySpace.windowPosition {
                windowPos.x = window.frame.origin.x
                windowPos.y = window.frame.origin.y
                windowPos.width = window.frame.size.width
                windowPos.height = window.frame.size.height
            } else {
                
                displaySpace.windowPosition = WindowPosition(
                    x: window.frame.origin.x,
                    y: window.frame.origin.y,
                    width: window.frame.size.width,
                    height: window.frame.size.height
                )
            }
        }
        
        for (id, dataPresenter) in dataPresenters {
            for window in NSApp.windows {
                if window.identifier?.rawValue == id {
                    if let windowPos = dataPresenter.windowPos, !windowPos.isFullPage {
                        windowPos.x = window.frame.origin.x
                        windowPos.y = window.frame.origin.y
                        windowPos.width = window.frame.size.width
                        windowPos.height = window.frame.size.height
                    } else if dataPresenter.windowPos == nil {
                        dataPresenter.windowPos = WindowPosition(
                            x: window.frame.origin.x,
                            y: window.frame.origin.y,
                            width: window.frame.size.width,
                            height: window.frame.size.height
                        )
                    }
                
                    if let viewPosition = displaySpace.viewPositions.first(where: { $0.pathFile == dataPresenter.filename }) {
                        viewPosition.windowPosition = dataPresenter.windowPos!
                        viewPosition.screenName = getScreenName(for: dataPresenter.windowPos!, in: self.screensInfo)
                    } else {
                        displaySpace.viewPositions.append(
                            PresenterViewPosition(
                                id: dataPresenter.presenter.fileHeader.id!,
                                pathFile: dataPresenter.filename,
                                screenName: getScreenName(for: dataPresenter.windowPos!, in: self.screensInfo),
                                windowPosition: dataPresenter.windowPos!
                            )
                        )
                    }
                }
            }
        }
        
    }

    /// Demande l'emplacement via le panel système puis écrit le DisplaySpace.
    /// regenerateID : affecte un nouveau UUID à fileHeader.id juste avant
    /// l'écriture (Save As — Evo_014) ; l'annulation du panel ne change rien.
    private func promptAndSaveDisplaySpace(regenerateID: Bool) {
        let panel = NSSavePanel()

        panel.title = "Enregistrer l'espace d'affichage"
        panel.allowedContentTypes = [UTType.json]
        panel.nameFieldStringValue = "displayspace.json"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                let filename = URL(fileURLWithPath: url.path).deletingPathExtension().lastPathComponent
                displaySpace.displaySpaceHeader.name = filename.replacingOccurrences(of: "_", with: " ")

                if regenerateID {
                    displaySpace.fileHeader.id = UUID()
                }

                // `panel.begin` est asynchrone : la mise à nil/restauration
                // doit se faire ICI, autour de l'écriture réelle, sinon
                // `presenters` serait déjà restauré et sérialisé dans le fichier.
                let tmp = displaySpace.presenters
                displaySpace.presenters = nil
                saveToJSONFile(displaySpace, filename: url.path)
                displaySpace.presenters = tmp

                pathDisplaySpace = url.path

                if let window = getDisplaySpaceView() {
                    window.title = displaySpace.displaySpaceHeader.name
                }
            }
        }
    }
    
    /// Rebranche le helper d'une fenêtre présentateur sur le PresenterViewPosition
    /// vivant du DisplaySpace courant (porteur des ViewSetting — Evo_012).
    /// Nécessaire car openWindow(value:) sérialise DataPresenterHelp : le helper
    /// reçu par la fenêtre peut être une copie décodée dont la référence runtime
    /// est nulle. Idempotent : ensureViewSettings conserve les valeurs chargées.
    private func resolveViewPosition(for helper: DataPresenterHelp) -> DataPresenterHelp {
        if let viewPosition = displaySpace.viewPositions.first(where: { $0.id == helper.presenter.fileHeader.id }) {
            viewPosition.ensureViewSettings(for: helper.presenter)
            helper.viewPosition = viewPosition
        }

        return helper
    }

    private func getDisplaySpaceView() -> NSWindow? {
        var window: NSWindow? = nil
        
        for wind in NSApp.windows {
            if let id = wind.identifier?.rawValue {
                if id.contains("displaySpaceWindows") {
                    window = wind
                }
            }
        }
        
        return window
    }
    
    private func openFile(
        _ url: URL,
        pos suggestionPos: WindowPosition = WindowPosition(x: 0, y: 0, width: 400, height: 400)
    ) -> Bool {
    
        let path: String = url.path()
        
        if let fileType = checkFileType(path: path) {
            switch fileType {
            case .DisplaySpace:
                if pathDisplaySpace != nil {
                    saveAllPhotoPresenter()
                    DisplaySpaceView.resetCommunity()
                    closeAllPresenterWindows()
                }

                pathDisplaySpace = path
                 
                if let ds = displaySpaceLoader.load(fullpath: path)
                {
                    displaySpace.fileHeader = ds.fileHeader
                    displaySpace.displaySpaceHeader = ds.displaySpaceHeader
                    displaySpace.windowPosition = ds.windowPosition
                    displaySpace.viewPositions = ds.viewPositions
                    displaySpace.presenters = [PhotoPresenter]()
                    displaySpace.emergencyDisplaySpace = ds.emergencyDisplaySpace

                    // Synchronise l'instance live partagée avec les réglages
                    // communautaires persistés (check4Update garantit un défaut).
                    let loadedCommunity = ds.communityParameter ?? CommunityParameter()
                    displaySpace.communityParameter = loadedCommunity
                    communityParam.applyPersistedValues(from: loadedCommunity)

                    if loadingController == nil {
                       loadingController = PresenterLoadingFileController(
                                               loadingInProgress: $loadingInProgress,
                                               screensInfo: $screensInfo,
                                               sharedRessources: sharedRessources,
                                               openWindow: openWindow
                                           )
                    }

                    loadingController?.start(with: ds.viewPositions, for: displaySpace.fileHeader.id!)
                     
                    if let window = getDisplaySpaceView() {
                        if let windowPosition = displaySpace.windowPosition {
                            let frame = NSRect(
                                x: windowPosition.x,
                                y: windowPosition.y,
                                width: windowPosition.width,
                                height: windowPosition.height
                            )
                              
                            window.setFrame(frame, display: true)
                        }
                         
                        window.title = displaySpace.displaySpaceHeader.name
                    }
                }
                                         
            case .PhotoPresenter:
                let presenter: PhotoPresenter? = presenterLoader.load(fullpath: url.path())
              
                if displaySpace.viewPositions.contains(where: { $0.id == presenter?.fileHeader.id }) == true {
                    break
                }
                 
                 
                if let groupedViews = presenter?.groupedViews {
                    for grView in groupedViews  {
                        if grView.fastLoaddings == nil {
                            grView.fastLoaddings = (0..<grView.nbOfView).map { _ in FastLoading() }
                        }
                    }
                }
                 
                if let pp = presenter {
                    let viewPosition = PresenterViewPosition(
                        id: pp.fileHeader.id!,
                        pathFile: url.path(),
                        screenName: getScreenName(for: suggestionPos, in: self.screensInfo),
                        windowPosition: suggestionPos
                    )

                    // Réglages par défaut du présentateur dans le DisplaySpace
                    // courant : un ViewSetting par vue, tous groupes confondus
                    // (Evo_012 — persistés dans le fichier DisplaySpace).
                    viewPosition.ensureViewSettings(for: pp)
                    displaySpace.viewPositions.append(viewPosition)

                    let helper = DataPresenterHelp(
                                     filename: url.path(),
                                     name: pp.photoPresenterHeader.name,
                                     windowPos: suggestionPos,
                                     presenter: presenter!,
                                     displaySpaceId: displaySpace.fileHeader.id!
                                  )
                                             
                    openWindow(id: "photoPresenterWindows", value: helper)
                }
                
            default:
            break;
            }
            
        }
        
        return true
    }
    
    /// « Close » (Cmd+W) — Evo_013 : agit sur la fenêtre active.
    /// Fenêtre présentateur : fermeture individuelle (le .onDisappear retire
    /// la référence du DisplaySpace). Fenêtre DisplaySpace : fermeture de
    /// toutes les fenêtres présentateurs en conservant leurs références,
    /// puis retour à l'état initial. Aucune sauvegarde dans les deux cas
    /// (décision Evo_013) : le fichier sur disque n'est jamais touché.
    private func closeActiveView() {
        guard let keyWindow = NSApp.keyWindow,
              let windowId = keyWindow.identifier?.rawValue else { return }

        if windowId.hasPrefix("photoPresenterWindows") {
            closePresenterWindow(windowId: windowId, window: keyWindow)
        } else if windowId.hasPrefix("displaySpaceWindows") {
            closeAllPresenterWindows()
            resetToInitialState()
        }
    }

    /// Fermeture individuelle d'un présentateur (Evo_013) : retrait explicite
    /// de ses références du DisplaySpace (viewPosition — donc ses ViewSetting —
    /// et presenter), nettoyage du suivi de fenêtres, puis fermeture de la
    /// fenêtre. Le retrait n'est PAS délégué au .onDisappear, dont le
    /// déclenchement n'est ni garanti ni synchrone.
    private func closePresenterWindow(windowId: String, window: NSWindow?) {
        if let dataPresenter = dataPresenters[windowId],
           let presenterId = dataPresenter.presenter.fileHeader.id {
            displaySpace.viewPositions.removeAll { $0.id == presenterId }
            displaySpace.presenters?.removeAll { $0.fileHeader.id == presenterId }
        }

        windowIdentifier.remove(windowId)
        dataPresenters.removeValue(forKey: windowId)
        window?.close()
    }

    /// Retire le « Close » système d'AppKit (performClose:) du menu : il
    /// partage Cmd+W avec notre item et fermerait brutalement la fenêtre
    /// active (y compris la fenêtre de contrôle) sans passer par
    /// closeActiveView(). Recherche par action et non par titre de menu,
    /// pour être insensible à la localisation (« File » / « Fichier »).
    /// Idempotent, appelé après la construction du menu.
    private func removeSystemCloseMenuItem() {
        guard let mainMenu = NSApp.mainMenu else { return }

        for menuItem in mainMenu.items {
            guard let submenu = menuItem.submenu else { continue }

            let index = submenu.indexOfItem(withTarget: nil, andAction: #selector(NSWindow.performClose(_:)))
            if index >= 0 {
                submenu.removeItem(at: index)
            }
        }
    }

    /// Ferme toutes les fenêtres présentateurs SANS retirer leurs références
    /// du DisplaySpace (fermeture globale — Evo_013). Le vidage de
    /// dataPresenters AVANT la fermeture des fenêtres signale aux
    /// .onDisappear (asynchrones) qu'il s'agit d'une fermeture globale : ils
    /// laissent alors viewPositions/presenters intacts.
    private func closeAllPresenterWindows() {
        windowIdentifier.removeAll()
        dataPresenters.removeAll()

        for window in NSApp.windows {
            if let windowId = window.identifier?.rawValue {
                let components = windowId.split(separator: "-")

                if components[0] == "photoPresenterWindows" {
                    window.close()
                }
            }
        }
    }

    /// Remet l'application dans l'état initial de son lancement (Evo_013) :
    /// DisplaySpace vierge, aucun fichier courant, indicateurs EDS remis à
    /// zéro, mode communautaire arrêté. Utilisée par « New » et par le
    /// « Close » du DisplaySpace. N'écrit rien sur disque.
    private func resetToInitialState() {
        pathDisplaySpace = nil
        emergencyExit = false
        back2LastDisplaySpace = nil

        DisplaySpaceView.resetCommunity()
        communityParam = CommunityParameter()

        displaySpace.fileHeader = FileHeader(fileType: FileType.DisplaySpace)
        displaySpace.displaySpaceHeader = DisplaySpaceHeader(name: "Photo presenter")
        displaySpace.windowPosition = nil
        displaySpace.viewPositions = [PresenterViewPosition]()
        displaySpace.presenters = [PhotoPresenter]()
        displaySpace.emergencyDisplaySpace = nil
        displaySpace.communityParameter = nil

        if let window = getDisplaySpaceView() {
            window.title = displaySpace.displaySpaceHeader.name
        }
    }

    private func removePresenter(_ presenterId: UUID) {
        for (windowId, dataPresenter) in dataPresenters {
            if dataPresenter.presenter.fileHeader.id == presenterId {
                let window = NSApp.windows.first(where: { $0.identifier?.rawValue == windowId })
                closePresenterWindow(windowId: windowId, window: window)
                break
            }
        }
    }

    private func getScreenName(for windowPosition: WindowPosition, in screensInfo: ScreensInfo) -> String? {
        let windowCenterX = windowPosition.x + windowPosition.width / 2
        let windowCenterY = windowPosition.y + windowPosition.height / 2
        
        for (index, position) in screensInfo.positions.enumerated() {
            if windowCenterX >= position.x &&
               windowCenterX < position.x + position.width &&
               windowCenterY >= position.y &&
               windowCenterY < position.y + position.height {
                return screensInfo.screennames[index]
            }
        }
        
        // Si aucun écran ne correspond
        return nil
    }
    
    static private func loadSharedResources(path: String) -> SharedRessources? {
        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            let sharedRessources = try JSONDecoder().decode(SharedRessources.self, from: data)
                
            return sharedRessources
        } catch {
            print("Erreur : \(error)")
            return nil
        }
    }
}
