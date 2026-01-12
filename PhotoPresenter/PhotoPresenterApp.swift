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
    
    @State private var loadingInProgress: Bool = false
    @State private var loadingController: PresenterLoadingFileController? = nil
    @State private var pathDisplaySpace: String? = nil
    @State private var displaySpaceViewType: DisplaySpaceViewType = .DashboardView
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
                requestOpeningPresenter: openFile
            ).onAppear() {
                if let window = getDisplaySpaceView() {
                    window.title = displaySpace.displaySpaceHeader.name
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
                        pathDisplaySpace = nil
                    }
                    
                    // Libére les fenêtres du chargement précédent
                    for window in NSApp.windows {
                        if let windowId = window.identifier?.rawValue {
                            let components = windowId.split(separator: "-")
                            
                            if components[0] == "photoPresenterWindows"  {
                                window.close()
                            }
                        }
                    }
                    
                    windowIdentifier.removeAll()
                    dataPresenters.removeAll()
                    
                    displaySpace.fileHeader = FileHeader(fileType: FileType.DisplaySpace)
                    displaySpace.displaySpaceHeader = DisplaySpaceHeader(name: "Photo presenter")
                    displaySpace.windowPosition = nil
                    displaySpace.viewPositions = [PresenterViewPosition]()
                    displaySpace.presenters = [PhotoPresenter]()
                }
                
                Button("Open…") {
                    if let url = openFileDialog() {
                        if !openFile( url) {
                            print("Impossible d'ouvrir le fichier")
                        }
                    }
                }
                
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
                    dataHelper: helper,
                    dataPresenters: $dataPresenters,
                    windowIdentifier: $windowIdentifier
                ).onAppear {
                    if displaySpace.presenters == nil {
                        displaySpace.presenters = []
                    }
                    displaySpace.presenters!.append(helper.presenter)
                    
                    dataPresenters[helper.windowId!] = helper
                    loadingInProgress = false
                }
                .background(WindowAccessor { window in
                    if let isOnTop = helper.windowPos?.isOnTop {
                        if isOnTop {
                            window.level = .floating        // Mettre la fenêtre au-dessus
                        }
                        else {
                            window.level = .normal
                        }
                    } else {
                        helper.windowPos?.isOnTop = false
                        window.level = .normal
                    }
                })
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
                    if let windowPos = dataPresenter.windowPos {
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
                    if let windowPos = dataPresenter.windowPos {
                        windowPos.x = window.frame.origin.x
                        windowPos.y = window.frame.origin.y
                        windowPos.width = window.frame.size.width
                        windowPos.height = window.frame.size.height
                    } else {
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
        
        let tmp = displaySpace.presenters
        
        displaySpace.presenters = nil
        
        if let path = pathDisplaySpace {
            saveToJSONFile(displaySpace, filename: path)
        } else {
            let panel = NSSavePanel()
               
            panel.title = "Enregistrer l'espace d'affichage"
            panel.allowedContentTypes = [UTType.json]
            panel.nameFieldStringValue = "displayspace.json"
           
            panel.begin { response in
                if response == .OK, let url = panel.url {
                    let filename = URL(fileURLWithPath: url.path).deletingPathExtension().lastPathComponent
                    displaySpace.displaySpaceHeader.name = filename.replacingOccurrences(of: "_", with: " ")
                    saveToJSONFile(displaySpace, filename: url.path)
                    pathDisplaySpace = url.path
                    
                    if let window = getDisplaySpaceView() {
                        window.title = displaySpace.displaySpaceHeader.name
                    }
                }
            }
        }
        
        displaySpace.presenters = tmp
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
    
    private func openFile(_ url: URL) -> Bool {
    
        let path: String = url.path()
        
        if let fileType = checkFileType(path: path) {
             switch fileType {
             case .DisplaySpace:
                 
                 if pathDisplaySpace != nil {
                     saveAllPhotoPresenter()
                     DisplaySpaceView.slideShowControllers = []
                     
                     // Libére les fenêtres du chargement précédent
                     for window in NSApp.windows {
                         if let windowId = window.identifier?.rawValue {
                             let components = windowId.split(separator: "-")
                             
                             if components[0] == "photoPresenterWindows"  {
                                 window.close()
                             }
                         }
                     }
                     
                     windowIdentifier.removeAll()
                     dataPresenters.removeAll()
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
                     displaySpace.viewPositions.append(
                         PresenterViewPosition(
                             id: pp.fileHeader.id!,
                             pathFile: url.path(),
                             screenName: getScreenName(for: WindowPosition(x: 0, y: 0, width: 400, height: 400), in: self.screensInfo),
                             windowPosition: WindowPosition(x: 0, y: 0, width: 400, height: 400)
                         )
                     )
                     
                     for groupedView in pp.groupedViews {
                         if groupedView.packInDisplaySpaces == nil {
                             groupedView.packInDisplaySpaces = []
                         }
                         
                         var viewSettings2: [ViewSetting] = [ViewSetting]()
                         
                         for _ in 0..<groupedView.nbOfView {
                             viewSettings2.append(ViewSetting())
                         }
                         
                         let packInDisplaySpace = PackInDisplaySpace(
                             displaySpaceId: displaySpace.fileHeader.id!,
                             viewSettings: viewSettings2
                         )
                         
                         groupedView.packInDisplaySpaces?.append(packInDisplaySpace)
                     }
                     
                     let helper = DataPresenterHelp(
                                     filename: url.path(),
                                     name: pp.photoPresenterHeader.name,
                                     presenter: presenter!,
                                     displaySpaceId: displaySpace.fileHeader.id!
                                  )
                                             
                     openWindow(id: "photoPresenterWindows", value: helper)
                 }
             }
        }
        
        return true
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
