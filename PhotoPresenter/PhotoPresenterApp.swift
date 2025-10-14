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
                                                                windowPositions: [DSPresenter]()
                                                          )
    
    @State private var dataPresenters: [UUID: DataPresenterHelp] = [:]
    
    var body: some Scene {

        WindowGroup(id: "displaySpaceWindows") {
            DisplaySpaceView(displaySpace: displaySpace)
        }.commands {
            CommandGroup(after: .newItem) {
                Button("Open…") {
                    if let url = openFileDialog(),
                       let fileType = checkFileType(path: url.path())
                    {
                        switch fileType {
                        case .DisplaySpace:
                            
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
                                    
                                    for index in 0..<grView.nbOfView {
                                        LoadFileInfoInMem(
                                            viewSetting: grView.viewSettings[index],
                                            fastLoading: grView.fastLoaddings![index]
                                        )
                                    }
                                }
                            }
                            
                            let helper = DataPresenterHelp(filename: url.path(), presenter: presenter!)
                            
                            dataPresenters[helper.mainViewId] = helper
                            openWindow(id: "photoPresenterWindows", value: helper)
                        }
                    }
                }
            }
        }
        
        WindowGroup(id: "photoPresenterWindows", for: DataPresenterHelp.self) { $helper in
            if let helper = helper {
                PhotoPresenterView(data: helper)
            }
        }
        
        
/*
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
                        
                        if (helper.add2DisplaySpace) {
                            displaySpace.presenters.append(
                                DSPresenter(
                                    name: data2Presenter.photoPresenter?.fileHeader.name ?? "Unknown",
                                    pahtFile: data2Presenter.filename,
                                    windowPosition: pos!
                                )
                            )
                        }
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
                            if let presenter = LoadPhotoPresenter(fullpath: displaySpace.pahtFile)
                            {
                                for grView in presenter.groupedViews {
                                    if grView.fastLoaddings == nil {
                                        grView.fastLoaddings = []
                                        
                                        for _ in 0..<grView.nbOfView {
                                            grView.fastLoaddings?.append(FastLoading())
                                        }
                                    }
                                }
                                
                                let data2Presenter = Data2Presenter(filename: displaySpace.pahtFile, overridingWindowPosition: displaySpace.windowPosition)
                                let helper = MainViewHelper(filename: displaySpace.pahtFile, presenter: presenter, viewId: data2Presenter.mainViewId, windowPosition: displaySpace.windowPosition, add2DisplaySpace: false)
                                
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
                        for grView in presenter.groupedViews {
                            if grView.fastLoaddings == nil {
                                grView.fastLoaddings = []
                                
                                for _ in 0..<grView.nbOfView {
                                    grView.fastLoaddings?.append(FastLoading())
                                }
                            }
                        }

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
    
    private func LoadFileInfoInMem(viewSetting setting: ViewSetting, fastLoading: FastLoading) {
        switch setting.type {
        case .FilesSelected:
            if fastLoading.fileInfos.count > 0 {
                for fileInfo in fastLoading.fileInfos {
                    let fullPath = "\(fastLoading.directories[fileInfo.directoryIndex])/\(fileInfo.filename)"
                    
                    if let nsImage = NSImage(contentsOfFile: fullPath) {
                        fileInfo.nsImage = nsImage
                    } else {
                        // To do journalisation de l'erreur
                    }
                }
            } else {
                for fullPath in setting.filesSelected! {
                    addImagefile4SelectedFiles(filename: fullPath, fastLoading: fastLoading)
                }
            }
            
        case .DirectorySelected:
            if fastLoading.fileInfos.count > 0 {
                for fileInfo in fastLoading.fileInfos {
                    let fullPath = "\(fastLoading.directories[fileInfo.directoryIndex])/\(fileInfo.filename)"
                    
                    if let nsImage = NSImage(contentsOfFile: fullPath) {
                        fileInfo.nsImage = nsImage
                    } else {
                        // To do journalisation de l'erreur
                    }
                }
            } else {
                let ratio = setting.ratio ?? 1.0
                let tolerance = setting.tolerance ?? 0.05
                
                for directory in setting.directorySelected ?? [] {
                    var index: Int? = fastLoading.directories.firstIndex(of: directory)

                    if index == nil {
                        fastLoading.directories.append(directory)
                        index = fastLoading.directories.count - 1
                    }
                    
                    fastLoading.fileInfos.append(
                        contentsOf: retrieveFiles(directory: directory, index: index!, ratio: ratio, tolerance: tolerance)
                    )
                }
            }
            
        case ImageViewType.WebServiceSelected:
            break
        }
    }

    private func addImagefile4SelectedFiles(filename path: String, fastLoading: FastLoading) {
        if let nsImage = NSImage(contentsOfFile: path),
           let rep = nsImage.representations.first as? NSBitmapImageRep
        {
            let url = URL(fileURLWithPath: path)
            let directoryPath = url.deletingLastPathComponent().path
            let filename = url.lastPathComponent
            var index: Int? = fastLoading.directories.firstIndex(of: directoryPath)

            if index == nil {
                fastLoading.directories.append(directoryPath)
                index = fastLoading.directories.count - 1
            }
            
            let fileInfo = FileInfo(
                filename: filename,
                directoryIndex: index!,
                width: rep.pixelsWide,
                height: rep.pixelsHigh,
                nsImage: nsImage
            )
            
            fastLoading.fileInfos.append(fileInfo)
        } else {
            // To do - journalisation de l'erreur
        }
    }
    
    private func retrieveFiles(directory path: String, index directoryIndex: Int, ratio: Double, tolerance: Double) -> [FileInfo] {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: path)
        var fileInfos: [FileInfo] = []

        do {
            let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            for fileURL in contents {
                switch fileURL.pathExtension {
                case "jpg", "jpeg", "png":
                    // To do: faire une journalisation pour les erreurs de ce type
                    //let nsImage = NSImage(contentsOfFile: fileURL.path)!  -> plante
                    let nsImage: NSImage? = NSImage(contentsOfFile: fileURL.path)
                    
                    if let rep = nsImage?.representations.first as? NSBitmapImageRep {
                        if fabs(ratio - Double(rep.pixelsWide) / Double(rep.pixelsHigh)) < tolerance {
                            fileInfos.append(
                                FileInfo(
                                    filename: fileURL.lastPathComponent,
                                    directoryIndex: directoryIndex,
                                    width: rep.pixelsWide,
                                    height: rep.pixelsHigh,
                                    nsImage: nsImage!
                                )
                            )
                        }
                    } else {
                        // To do - journaliser l'erreur
                        print("Erreur lors de la conversion de l'image en NSBitmapImageRep")
                        print(fileURL.path)
                    }
                    break
                default:
                    continue
                }
            }
        } catch {
            print("Erreur lors de la lecture du répertoire : \(error)")
        }
        
        return fileInfos
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
            for (id, data2Presenter) in dataPresenters {
                if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id.uuidString }),
                   window == keyWindow {
//                    if data2Presenter.overridingWindowPosition == nil {
                        //data2Presenter.photoPresenter?.fileHeader.windowPosition?.x = Int(window.frame.origin.x)
                        //data2Presenter.photoPresenter?.fileHeader.windowPosition?.y = Int(window.frame.origin.y)
                        //data2Presenter.photoPresenter?.fileHeader.windowPosition?.width = Int(window.frame.size.width)
                        //data2Presenter.photoPresenter?.fileHeader.windowPosition?.height = Int(window.frame.size.height)
//                    }
                    
//                    saveToJSONFile(data2Presenter.photoPresenter, filename: data2Presenter.filename)
                    break
                }
            }
        }
    }
    
    func saveAllPhotoPresenter() {
        for (id, data2Presenter) in dataPresenters {
            if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id.uuidString }) {
//                if data2Presenter.overridingWindowPosition == nil {
                    //data2Presenter.photoPresenter?.fileHeader.windowPosition?.x = Int(window.frame.origin.x)
                    //data2Presenter.photoPresenter?.fileHeader.windowPosition?.y = Int(window.frame.origin.y)
                    //data2Presenter.photoPresenter?.fileHeader.windowPosition?.width = Int(window.frame.size.width)
                    //data2Presenter.photoPresenter?.fileHeader.windowPosition?.height = Int(window.frame.size.height)
//                }

//                saveToJSONFile(data2Presenter.photoPresenter, filename: dataPresenters.filename)
            }
        }
        saveDisplaySpaceFile()
    }
    
    func saveDisplaySpaceFile() {
        
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
