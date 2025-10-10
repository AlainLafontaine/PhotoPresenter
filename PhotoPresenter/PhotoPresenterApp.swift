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
}

@main
struct PhotoPresenterApp: App {
    @Environment(\.openWindow) private var openWindow
    
    @State private var data2Presenters: [UUID: Data2Presenter] = [:]
    
    var body: some Scene {
        
        WindowGroup {
            
        }
        
        WindowGroup(id: "mainWindow", for: MainViewHelper.self) { $helper in
            if let helper = helper,
               let data2Presenter = data2Presenters[helper.viewId]
            {
                MainView(
                    filename: helper.filename,
                    presenter: helper.presenter,
                    data2Presenter: data2Presenter,
                    overringWindowPosition: data2Presenter.overridingWindowPosition
                ).onAppear {
                    if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == data2Presenter.mainViewId.uuidString }) {
                        let pos: WindowPosition? = data2Presenter.overridingWindowPosition != nil ? data2Presenter.overridingWindowPosition : data2Presenter.photoPresenter?.fileHeader.windowPosition
                        let frame = NSRect(
                            x: pos?.x ?? 0,
                            y: pos?.y ?? 0,
                            width: pos?.width ?? 400,
                            height: pos?.height ?? 400
                        )
                                
                        window.setFrame(frame, display: true)
                    }
                }
            }
        }.commands {
            CommandGroup(after: .newItem) {
                Button("Open Display Space…") {
                    if let url = openFileDialog(),
                       let displaySpaces = LoadDisplaySpace(fullpath: url.path())
                    {
                        for (_, displaySpace) in displaySpaces.presenters.enumerated()  {
                            if let presenter = LoadPhotoPresenter(fullpath: displaySpace.pahtFile) {
                                let data2Presenter = Data2Presenter(filename: displaySpace.pahtFile, overridingWindowPosition: displaySpace.windowPosition)
                                let helper = MainViewHelper(filename: displaySpace.pahtFile, presenter: presenter, viewId: data2Presenter.mainViewId, windowPosition: displaySpace.windowPosition)
                                
                                self.data2Presenters[data2Presenter.mainViewId] = data2Presenter
                                openWindow(id: "mainWindow", value: helper)
                            }
                        }
                    }
                }
                .keyboardShortcut("O", modifiers: [.command])

                Button("Open…") {
                    if let url = openFileDialog(),
                       let presenter = LoadPhotoPresenter(fullpath: url.path())
                    {
                        let data2Presenter = Data2Presenter(filename: url.path())
                        let helper = MainViewHelper(filename: url.path(), presenter: presenter, viewId: data2Presenter.mainViewId)
                        
                        data2Presenters[data2Presenter.mainViewId] = data2Presenter
                        openWindow(id: "mainWindow", value: helper)
                    }
                }
                .keyboardShortcut("O", modifiers: [.command])
                
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
            }
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
    
    func sendCommandToActiveWindow(_ command: Data2Presenter.DisplayView) {
        if let keyWindow = NSApp.keyWindow {
            for (id, controller) in data2Presenters {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id.uuidString }),
                   window == keyWindow {
                    controller.displayView = command
                    break
                }
            }
        }
    }
    
    func savePhotoPresenterToActiveWindow() {
        if let keyWindow = NSApp.keyWindow {
            for (id, data2Presenter) in data2Presenters {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id.uuidString }),
                   window == keyWindow {
                    if data2Presenter.overridingWindowPosition == nil {
                        data2Presenter.photoPresenter?.fileHeader.windowPosition?.x = Int(window.frame.origin.x)
                        data2Presenter.photoPresenter?.fileHeader.windowPosition?.y = Int(window.frame.origin.y)
                        data2Presenter.photoPresenter?.fileHeader.windowPosition?.width = Int(window.frame.size.width)
                        data2Presenter.photoPresenter?.fileHeader.windowPosition?.height = Int(window.frame.size.height)
                    }
                    
                    saveToJSONFile(data2Presenter.photoPresenter, filename: data2Presenter.filename)
                    break
                }
            }
        }
    }
    
    func saveAllPhotoPresenter() {
        for (id, data2Presenter) in data2Presenters {
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id.uuidString }) {
                if data2Presenter.overridingWindowPosition == nil {
                    data2Presenter.photoPresenter?.fileHeader.windowPosition?.x = Int(window.frame.origin.x)
                    data2Presenter.photoPresenter?.fileHeader.windowPosition?.y = Int(window.frame.origin.y)
                    data2Presenter.photoPresenter?.fileHeader.windowPosition?.width = Int(window.frame.size.width)
                    data2Presenter.photoPresenter?.fileHeader.windowPosition?.height = Int(window.frame.size.height)
                }

                saveToJSONFile(data2Presenter.photoPresenter, filename: data2Presenter.filename)
            }
        }
    }

}
