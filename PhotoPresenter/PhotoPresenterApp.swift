//
//  PhotoPresenterApp.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import AppKit
import UniformTypeIdentifiers  // ✅ nécessaire pour UTType
import SwiftUI

extension NSApplication {
    var mainWindowFrame: NSRect? {
        return self.mainWindow?.frame
    }
}

struct MainViewHelper: Codable, Hashable {
    let filename: String
    let presenter: PhotoPresenter
    let viewId: UUID
}

@main
struct PhotoPresenterApp: App {
    @Environment(\.openWindow) private var openWindow
    
    @StateObject private var windowObserver = WindowEventObserver()
    
    @State private var displayViews: [UUID: DisplayViewModel] = [:]
    
    var body: some Scene {
        
        WindowGroup {
            
        }
        
        WindowGroup(id: "mainWindow", for: MainViewHelper.self) { $helper in
            if let helper = helper,
               let viewModel = displayViews[helper.viewId]
            {
                MainView(
                    filename: helper.filename,
                    presenter: helper.presenter,
                    displayViewModel: viewModel,
                    windowObserver: windowObserver
                )
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        if let position = helper.presenter.fileHeader.windowPosition {
                            restoreWindowPosition(for: window, positionWindow: position)
                        }
                    }
                }
/*
                .onReceive(windowObserver.$lastFrame) { newFrame in
                    
                    helper.presenter.fileHeader.windowPosition = WindowPosition(
                        x: Int(newFrame.origin.x),
                        y: Int(newFrame.origin.y),
                        width: Int(newFrame.size.width),
                        height: Int(newFrame.size.height)
                    )
                }
 */
                .background(WindowAccessor { window in
                    window.delegate = windowObserver
                })
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
    
    private func sendCommandToActiveWindow(_ command: DisplayViewModel.DisplayView) {
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
    
    private func restoreWindowPosition(for window: NSWindow, positionWindow pos: WindowPosition) {
        let frame = NSRect(x: pos.x, y: pos.y, width: pos.width, height: pos.height)
        window.setFrame(frame, display: true)
    }
    
    private func saveWindowPosition(_ frame: NSRect) {
        let dict: [String: CGFloat] = [
            "x": frame.origin.x,
            "y": frame.origin.y,
            "width": frame.size.width,
            "height": frame.size.height
        ]
        UserDefaults.standard.set(dict, forKey: "windowFrame")
    }
}
