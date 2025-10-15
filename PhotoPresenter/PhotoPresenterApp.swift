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

struct MainViewHelper: Codable, Hashable {
    let filename: String
    let presenter: PhotoPresenter
    let viewId: UUID
    var windowPosition: WindowPosition?
    var add2DisplaySpace: Bool = false
}

@main
struct PhotoPresenterApp: App {
    @Environment(\.openWindow) private var openWindow
    
    @State       private var pathDisplaySpace: String? = nil
    @StateObject private var displaySpace: DisplaySpace = DisplaySpace(
                                                                fileHeader: DisplaySpaceHeader(name: "sans nom"),
                                                                viewPositions: [PresenterViewPosition]()
                                                          )
    
    @State private var dataPresenters: DataPresenterMap = DataPresenterMap()
    
    var body: some Scene {

        WindowGroup(id: "displaySpaceWindows") {
            DisplaySpaceView(
                displaySpace: displaySpace
            )
        }.commands {
            CommandGroup(after: .newItem) {
                Button("Open…") {
                    if let url = openFileDialog(),
                       let fileType = checkFileType(path: url.path())
                    {
                        switch fileType {
                        case .DisplaySpace:
                            if let ds = LoadDisplaySpace(fullpath: url.path())
                            {
                                displaySpace.fileHeader = ds.fileHeader
                                displaySpace.viewPositions = ds.viewPositions
                                displaySpace.presenters = [PhotoPresenter]()
                                
                                for (_, viewPosition) in ds.viewPositions.enumerated()  {
                                    if let presenter = LoadPhotoPresenter(fullpath: viewPosition.pahtFile)
                                    {
                                        for grView in presenter.groupedViews {
                                            if grView.fastLoaddings == nil {
                                                grView.fastLoaddings = []
                                                
                                                for _ in 0..<grView.nbOfView {
                                                    grView.fastLoaddings?.append(FastLoading())
                                                }
                                            }
                                        }
                                        
                                        let helper = DataPresenterHelp(
                                            filename: url.path(),
                                            presenter: presenter,
                                            windowPos: viewPosition.windowPosition
                                        )
                                        
                                        //dataPresenters[helper.windowId] = helper
                                        openWindow(id: "photoPresenterWindows", value: helper)
                                    }
                                }
                            }
                            
                            openWindow(id: "displaySpaceWindows")
                        
                        case .PhotoPresenter:
                            let presenter: PhotoPresenter? = LoadPhotoPresenter(fullpath: url.path())
                         
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
                            
                            let helper = DataPresenterHelp(filename: url.path(), presenter: presenter!)
                            
                            //dataPresenters[helper.imageViewId] = helper
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
        }
        
        WindowGroup(id: "photoPresenterWindows", for: DataPresenterHelp.self) { $helper in
            if let helper = helper {
                PhotoPresenterView(
                    dataHelper: helper,
                    dataPresenters: $dataPresenters
                ).onAppear {
                    if let pos = helper.windowPos,
                       let window = NSApp.windows.first(where: { $0.identifier?.rawValue == helper.windowId })
                    {
                        let frame = NSRect(
                            x: pos.x,
                            y: pos.y,
                            width: pos.width,
                            height: pos.height
                        )
                                
                        window.setFrame(frame, display: true)
                    }
                }
            }
        }
        
        
/*
    
        
        WindowGroup(id: "mainWindow", for: MainViewHelper.self) { $helper in
            
        }.commands {
            
            CommandGroup(before: .sidebar) {
                Button("Information") {
                    sendCommandToActiveWindow(.information)
                }
                .keyboardShortcut("I", modifiers: [.command])
                
                Button("Presenter") {
                    sendCommandToActiveWindow(.multiImageView)
                }
                .keyboardShortcut("P", modifiers: [.command])
            }
        }
 */
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
    
    private func LoadPhotoPresenter(fullpath path: String) -> PhotoPresenter? {
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
    
    func sendCommandToActiveWindow(_ command: PhotoPresenterViewType) {
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
                        windowPos.x = Int(window.frame.origin.x)
                        windowPos.y = Int(window.frame.origin.y)
                        windowPos.width = Int(window.frame.size.width)
                        windowPos.height = Int(window.frame.size.height)
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
                        windowPos.x = Int(window.frame.origin.x)
                        windowPos.y = Int(window.frame.origin.y)
                        windowPos.width = Int(window.frame.size.width)
                        windowPos.height = Int(window.frame.size.height)
                    } else {
                        dataPresenter.windowPos = WindowPosition(
                            x: Int(window.frame.origin.x),
                            y: Int(window.frame.origin.y),
                            width: Int(window.frame.size.width),
                            height: Int(window.frame.size.height)
                        )
                    }
                
                    if let viewPosition = displaySpace.viewPositions.first(where: { $0.pahtFile == dataPresenter.filename }) {
                        viewPosition.windowPosition = dataPresenter.windowPos!
                    } else {
                        displaySpace.viewPositions.append(
                            PresenterViewPosition(
                                pahtFile: dataPresenter.filename,
                                windowPosition: dataPresenter.windowPos!
                            )
                        )
                    }
                }
            }
        }
        
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
                   print("Fichier enregistré à : \(url.path)")
               }
            }
        }
    }

}
