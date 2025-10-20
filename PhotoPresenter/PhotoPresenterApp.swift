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
    
    @State private var windowIdentifier: Set<String> = []
    @State private var dataPresenters: DataPresenterMap = DataPresenterMap()
    
    @StateObject private var displaySpace: DisplaySpace = DisplaySpace(
                                                                fileHeader: DisplaySpaceHeader(name: "sans nom"),
                                                                viewPositions: [PresenterViewPosition]()
                                                          )
    
    var body: some Scene {

        WindowGroup(id: "displaySpaceWindows") {
            DisplaySpaceView(
                displaySpace: displaySpace,
                displayView: $displaySpaceViewType
            )
        }.commands {
            CommandGroup(after: .newItem) {
                Button("Open…") {
                    if let url = openFileDialog(),
                       let fileType = checkFileType(path: url.path())
                    {
                        switch fileType {
                        case .DisplaySpace:
                            
                            if pathDisplaySpace != nil {
                                //saveAllPhotoPresenter()
/*
                                for window in NSApp.windows {
                                    if let windowId = window.identifier?.rawValue {
                                        let components = windowId.split(separator: "-")
                                        
                                        if components[0] == "photoPresenterWindows"  {
                                            window.orderOut(nil)
                                        }
                                    }
                                }
*/
                                windowIdentifier.removeAll()
                                dataPresenters.removeAll()
                            }

                            pathDisplaySpace = url.path()
                            
                            if let ds = LoadDisplaySpace(fullpath: url.path())
                            {
                                displaySpace.fileHeader = ds.fileHeader
                                displaySpace.viewPositions = ds.viewPositions
                                displaySpace.presenters = [PhotoPresenter]()
                                
                                if loadingController == nil {
                                    loadingController = PresenterLoadingFileController(
                                                            loadingInProgress: $loadingInProgress,
//                                                            windowIdentifier: $windowIdentifier,
                                                            openWindow: openWindow
                                                        )
                                }
                    
                                loadingController?.start(with: ds.viewPositions)
                             }
                                                    
                        case .PhotoPresenter:
                            let presenter: PhotoPresenter? = PhotoPresenterApp.LoadPhotoPresenter(fullpath: url.path())
                         
                            if let groupedViews = presenter?.groupedViews {
                                for grView in groupedViews  {
                                    if grView.fastLoaddings == nil {
                                        grView.fastLoaddings = []
                                        
                                        for _ in 0..<grView.nbOfView {
                                            grView.fastLoaddings?.append(FastLoading())
                                        }
                                    }
                                }
                            }
                            
                            displaySpace.viewPositions.append(
                                PresenterViewPosition(
                                    name: presenter!.fileHeader.name,
                                    pahtFile: url.path(),
                                    windowPosition: WindowPosition(x: 0, y: 0, width: 400, height: 400)
                                )
                            )
                            
                            let helper = DataPresenterHelp(
                                            filename: url.path(),
                                            name: presenter!.fileHeader.name,
                                            presenter: presenter!
                                         )
                                                    
                            openWindow(id: "photoPresenterWindows", value: helper)
                        }
                    }
                }
                
                Button("Save") {
                    savePhotoPresenterToActiveWindow()
                }
                .keyboardShortcut("S", modifiers: [.command])
                
                Button("Save all") {
                    saveAllPhotoPresenter()
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
                
                Button("Dashboard") {
                    displaySpaceViewType = .RatioSimulatorView
                }
                .keyboardShortcut("R", modifiers: [.command])
                
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
                    
                    dataPresenters[helper.windowId!] = helper
/*
                    if let pos = helper.windowPos,
                       let windowId = helper.windowId,
                       let window = getNSWindow(withIdentifier: windowId)
                    {
                        let frame = NSRect(
                            x: pos.x,
                            y: pos.y,
                            width: pos.width,
                            height: pos.height
                        )
                        
                        print("/(window.identifier: \(window.identifier!.rawValue))")
                        window.setFrame(frame, display: true)
                    }
*/
                    loadingInProgress = false
                }
            }
        }
    }
    
    static func LoadPhotoPresenter(fullpath path: String) -> PhotoPresenter? {
        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            let photoPresenter = try JSONDecoder().decode(PhotoPresenter.self, from: data)
            return photoPresenter
        } catch {
            print("Erreur : \(error)")
            return nil
        }
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
            let checkFileType = try JSONDecoder().decode(CheckFileType.self, from: data)
            return checkFileType.fileType
        } catch {
            print("Erreur : \(error)")
            return nil
        }
    }
    
    private func LoadDisplaySpace(fullpath path: String) -> DisplaySpace? {
        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            let displaySpace = try JSONDecoder().decode(DisplaySpace.self, from: data)
            return displaySpace
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
    
    func savePhotoPresenterToActiveWindow() {
        if let keyWindow = NSApp.keyWindow {
            for (id, dataPresenter) in dataPresenters {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id }),
                       window == keyWindow
                {
                    if let windowPos = dataPresenter.windowPos {
                        windowPos.x = window.frame.origin.x
                        windowPos.y = window.frame.origin.y
                        windowPos.width = window.frame.size.width
                        windowPos.height = window.frame.size.height
                    }

                    saveToJSONFile(dataPresenter.presenter, filename: dataPresenter.filename)
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
                    
                    saveToJSONFile(dataPresenter.presenter, filename: dataPresenter.filename)
                }
            }
        }
        
        saveDisplaySpaceFile()
    }
    
    func saveDisplaySpaceFile() {
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
                
                    if let viewPosition = displaySpace.viewPositions.first(where: { $0.pahtFile == dataPresenter.filename }) {
                        viewPosition.windowPosition = dataPresenter.windowPos!
                    } else {
                        displaySpace.viewPositions.append(
                            PresenterViewPosition(
                                name: dataPresenter.name,
                                pahtFile: dataPresenter.filename,
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
                    saveToJSONFile(displaySpace, filename: url.path)
                    pathDisplaySpace = url.path
                }
                
                displaySpace.presenters = tmp
            }
        }
    }
}
