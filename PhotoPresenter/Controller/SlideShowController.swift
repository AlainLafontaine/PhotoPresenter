//
//  SlideShowController.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-28.
//

import Foundation
import SwiftUI
import AppKit  // Nécessaire pour NSImage

class SlideShowController: ObservableObject {
    @ObservedObject private var viewSetting: ViewSetting
    
    //@Published var currentIndex: Int = 0
    //@Published var isPaused: Bool = false
    //@Published var isReverse: Bool = false
    //@Published var isRandomizing: Bool = false
               var timer: Timer?
               //var intervalTimer: Double = 2.0
               var fileInfos: [FileInfo] = []
               var directories: [String]

    init(viewSetting setting: ViewSetting)
    {
        //isPaused = setting.isPaused
        //isRandomizing = setting.isRandomizing
        //intervalTimer = setting.intervalTimer
        self.viewSetting = setting
        
        switch setting.type {
        case ImageViewType.FilesSelected:
            directories = []
            for path in setting.filesSelected ?? [] {
                if let nsImage = NSImage(contentsOfFile: path),
                   let rep = nsImage.representations.first as? NSBitmapImageRep {
                   let chemin = URL(fileURLWithPath: path)
                   let fileInfo = FileInfo(
                       filename: chemin.lastPathComponent,
                       directoryIndex: 0, // tu peux gérer l’index ailleurs
                       nsImage: nsImage,
                       width: rep.pixelsWide,
                       height: rep.pixelsHigh
                    )
                    fileInfos.append(fileInfo)
                }
            }
            
        case ImageViewType.DirectorySelected:
            let ratio = setting.ratio ?? 1.0
            let tolerance = setting.tolerance ?? 0.05
            
            directories = setting.directorySelected ?? []
            for directory in directories {
                let fileInfos: [FileInfo] = retrieveFiles(directory: directory, index: 0, ratio: ratio, tolerance: tolerance)
                self.fileInfos.append(contentsOf: fileInfos)
            }
            
        case ImageViewType.WebServiceSelected:
            directories = setting.directorySelected ?? []
        }
    }
    
    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: viewSetting.intervalTimer, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !viewSetting.isPaused {
                if viewSetting.isRandomizing {
                    viewSetting.currentIndex = Int.random(in: 0..<self.fileInfos.count)
                } else if viewSetting.isReverse {
                    viewSetting.currentIndex = (viewSetting.currentIndex - 1 + self.fileInfos.count) % self.fileInfos.count
                } else {
                    viewSetting.currentIndex = (viewSetting.currentIndex + 1) % self.fileInfos.count
                }
            }
        }
    }
    
    func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 49:
            viewSetting.isPaused.toggle()
            
        case 123...126:
            navigationByKeyboard(event: event)
            
        default: break
        }
    }
    
    private func retrieveFiles(directory path: String, index directoryIndex: Int, ratio: Double, tolerance: Double) -> [FileInfo] {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: path)
        var files: [FileInfo] = []

        do {
            let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            for fileURL in contents {
                switch fileURL.pathExtension {
                case "jpg", "jpeg", "png":
                    let nsImage = NSImage(contentsOfFile: fileURL.path)!
                    
                    if let rep = nsImage.representations.first as? NSBitmapImageRep {
                        if fabs(ratio - Double(rep.pixelsWide) / Double(rep.pixelsHigh)) < tolerance {
                            files.append(
                                FileInfo(
                                    filename: fileURL.lastPathComponent,
                                    directoryIndex: directoryIndex,
                                    nsImage: nsImage,
                                    width: rep.pixelsWide,
                                    height: rep.pixelsHigh
                                )
                            )
                        }
                    }
                    break
                default:
                    continue
                }
            }
        } catch {
            print("Erreur lors de la lecture du répertoire : \(error)")
        }
        
        return files
    }
    
    private func navigationByKeyboard(event: NSEvent) {
        if !viewSetting.isPaused {
            viewSetting.isPaused.toggle()
        }
        
        switch event.keyCode {
        case 123: // Left
            if viewSetting.currentIndex > 0 {
                viewSetting.currentIndex -= 1
            } else {
                viewSetting.currentIndex = fileInfos.count - 1
            }
                
        case 124: // Right
            if viewSetting.currentIndex < fileInfos.count - 1 {
                viewSetting.currentIndex += 1
            } else {
                viewSetting.currentIndex = 0
            }
            
        case 125: // Down
            viewSetting.currentIndex = 0
            
        case 126: // Up
            viewSetting.currentIndex = self.fileInfos.count - 1
            
        default:
            break;
        }
    }
}
