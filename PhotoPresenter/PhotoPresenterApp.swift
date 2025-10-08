//
//  PhotoPresenterApp.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import AppKit
import UniformTypeIdentifiers  // ✅ nécessaire pour UTType
import SwiftUI

struct MainViewHelper: Codable, Hashable {
    let filename: String
    let presenter: PhotoPresenter
    let viewId: UUID
}

@main
struct PhotoPresenterApp: App {
    @Environment(\.openWindow) private var openWindow
    
    @State private var displayViews: [UUID: DisplayViewModel] = [:]
    
    var body: some Scene {
        
        WindowGroup {
            
        }
        
        WindowGroup(id: "mainWindow", for: MainViewHelper.self) { $helper in
            if let helper = helper,
               let viewModel = displayViews[helper.viewId]
            {
                MainView(filename: helper.filename, presenter: helper.presenter, displayViewModel: viewModel)
            }
        }.commands {
            CommandGroup(after: .newItem) {
                Button("Open…") {
                    if let url = openFileDialog(),
                       let presenter = LoadPhotoPresenter(fullpath: url.path())
                    {
                        let viewModel = DisplayViewModel()
                        let helper = MainViewHelper(filename: url.path(), presenter: presenter, viewId: viewModel.mainViewId)
                        
                        displayViews[viewModel.mainViewId] = viewModel
                        openWindow(id: "mainWindow", value: helper)
                    }
                }
                .keyboardShortcut("O", modifiers: [.command])
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
    
    func sendCommandToActiveWindow(_ command: DisplayViewModel.DisplayView) {
        if let keyWindow = NSApp.keyWindow {
            for (id, controller) in displayViews {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id.uuidString }),
                   window == keyWindow {
                    controller.displayView = command
                    break
                }
            }
        }
    }
}
