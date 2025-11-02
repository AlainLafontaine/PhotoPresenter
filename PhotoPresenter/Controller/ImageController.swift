//
//  ImageController.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-14.
//

import Foundation
import SwiftUI
import AppKit  // Nécessaire pour NSImage

class ImageController: ObservableObject {
    @ObservedObject var viewSetting: ViewSetting2
    @ObservedObject var fastLoading: FastLoading
    
    init(viewSetting setting: ViewSetting2, fastLoading: FastLoading) {
        self.viewSetting = setting
        self.fastLoading = fastLoading
        
        if self.fastLoading.fileInfos.count == 0 {
            LoadFileInfoInMem()
        }
    }
    
    func getImage() -> NSImage {
        if let nsImage = fastLoading.fileInfos[viewSetting.currentIndex].nsImage {
            return nsImage
        } else {
            if viewSetting.isRandomizing {
                return LoadOneFileInfoInMem(index: viewSetting.currentIndex)
            } else {
                // To do Optimiser le chargement
                return LoadOneFileInfoInMem(index: viewSetting.currentIndex)
            }
        }
    }
    
    private func LoadOneFileInfoInMem(index: Int) -> NSImage {
        switch viewSetting.presenterDataSource.type {
        case .FilesSelected, .DirectorySelected:
            let fullPath = "\(fastLoading.directories[fastLoading.fileInfos[index].directoryIndex])/\(fastLoading.fileInfos[index].filename)"
            
            if let nsImage = NSImage(contentsOfFile: fullPath) {
                fastLoading.fileInfos[index].nsImage = nsImage
                return nsImage
            } else {
                // To do - Afficher une image d'erreur
                return fastLoading.fileInfos[viewSetting.currentIndex].nsImage!
            }
            
        case .WebServiceSelected:
            // To do - Afficher une image d'erreur
            return fastLoading.fileInfos[viewSetting.currentIndex].nsImage!
        }
    }
    
    private func LoadFileInfoInMem() {
        switch viewSetting.presenterDataSource.type {
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
                for fullPath in viewSetting.presenterDataSource.filesSelected! {
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
                let ratio = viewSetting.presenterDataSource.ratio ?? 1.0
                let tolerance = viewSetting.presenterDataSource.tolerance ?? 0.05
                
                for directory in viewSetting.presenterDataSource.directorySelected ?? [] {
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
}
