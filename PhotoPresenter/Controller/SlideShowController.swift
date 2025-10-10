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
    @ObservedObject var viewSetting: ViewSetting
    @ObservedObject var fastLoading: FastLoading
    
    var timer: Timer?
    
    init(viewSetting setting: ViewSetting, fastLoading: FastLoading) {
        self.viewSetting = setting
        self.fastLoading = fastLoading
        
        switch setting.type {
        case ImageViewType.FilesSelected:
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
                    addImagefile4SelectedFiles(filename: fullPath)
                }
            }
            
        case ImageViewType.DirectorySelected:
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
    
    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: viewSetting.intervalTimer, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !viewSetting.isPaused {
                if viewSetting.isRandomizing {
                    viewSetting.currentIndex = Int.random(in: 0..<fastLoading.fileInfos.count)
                } else if viewSetting.isReverse {
                    viewSetting.currentIndex = (viewSetting.currentIndex - 1 + fastLoading.fileInfos.count) % fastLoading.fileInfos.count
                } else {
                    viewSetting.currentIndex = (viewSetting.currentIndex + 1) % fastLoading.fileInfos.count
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
    
    private func addImagefile4SelectedFiles(filename path: String) {
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
        var files: [FileInfo] = []

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
                            files.append(
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
                viewSetting.currentIndex = fastLoading.fileInfos.count - 1
            }
                
        case 124: // Right
            if viewSetting.currentIndex < fastLoading.fileInfos.count - 1 {
                viewSetting.currentIndex += 1
            } else {
                viewSetting.currentIndex = 0
            }
            
        case 125: // Down
            viewSetting.currentIndex = 0
            
        case 126: // Up
            viewSetting.currentIndex = fastLoading.fileInfos.count - 1
            
        default:
            break;
        }
    }
}
