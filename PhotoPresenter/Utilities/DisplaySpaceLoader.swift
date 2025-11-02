//
//  DisplaySpaceLoader.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-22.
//

import Foundation
import SwiftUtilities

struct DisplaySpaceLoader {
    
    func load(fullpath path: String) -> DisplaySpace? {
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            let displaySpace = try JSONDecoder().decode(DisplaySpace.self, from: data)
            
            check4Update(displaySpace)
            return displaySpace
        } catch {
            print("Erreur : \(error)")
            return nil
        }
    }
    
    private func check4Update(_ displaySpace: DisplaySpace) {
        
        switch(displaySpace.fileHeader.version) {
        case "0.1.0001":
            let fileHeader = displaySpace.fileHeader
            
            fileHeader.version = "0.1.0002"
            fileHeader.id = UUID()
            updateFor_0_1_0002(viewPositions: displaySpace.viewPositions)
            updateFor_0_1_0003(displaySpace)
            
        case "0.1.0002":
            let fileHeader = displaySpace.fileHeader
            
            fileHeader.version = "0.1.0003"
            updateFor_0_1_0003(displaySpace)
                    
        default:
            break
        }
    }
    
    private func loadPhotoPresententer(fullpath path: String) -> PhotoPresenter? {
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
    
    // Migration 0.1.0001 -> 0.1.0002
    private func updateFor_0_1_0002(viewPositions: [PresenterViewPosition]) {
        let presenterLoader: PhotoPresenterLoader = PhotoPresenterLoader()
        
        // Itérer sur viewPositions pour appliquer les changements nécessaires
        for viewPosition in viewPositions {
            
            if let presenter = presenterLoader.load(fullpath: viewPosition.pathFile) {
                viewPosition.id = presenter.fileHeader.id!
            }
        }
    }
    
    // Migration 0.1.0002 -> 0.1.0003
    private func updateFor_0_1_0003(_ displaySpace: DisplaySpace) {
        for viewPosition in displaySpace.viewPositions {
            if let photoPresenter = loadPhotoPresententer(fullpath: viewPosition.pathFile) {
                for groupedView in photoPresenter.groupedViews {
                    if groupedView.packInDisplaySpaces == nil {
                        groupedView.packInDisplaySpaces = []
                    }
                    
                    var viewSettings2: [ViewSetting2] = [ViewSetting2]()
                    
                    for index in 0..<groupedView.nbOfView {
                        switch photoPresenter.fileHeader.version {
                        case "0.1.0002":
                            if let vSetting = groupedView.viewSettings?[index] {
                                let presenterDataSource = PhotoPresenterDataSource(
                                    type: vSetting.type,
                                    filesSelected: vSetting.filesSelected,
                                    directorySelected: vSetting.directorySelected,
                                    ratio: vSetting.ratio,
                                    tolerance: vSetting.tolerance
                                )
                                
                                let viewSetting = ViewSetting2(
                                    presenterDataSource: presenterDataSource,
                                    isPaused: vSetting.isPaused,
                                    isReverse: vSetting.isReverse,
                                    isRandomizing: vSetting.isRandomizing,
                                    currentIndex: vSetting.currentIndex,
                                    intervalTimer: vSetting.intervalTimer,
                                    displayNumImage: vSetting.displayNumImage,
                                    displayFilename: vSetting.displayFilename
                                )
                                
                                viewSettings2.append(viewSetting)
                            }
                            
                        case "0.1.0003":
                            if let presenterDataSource = groupedView.packInDisplaySpaces?[0].viewSettings[index].presenterDataSource   {
                                let viewSetting = ViewSetting2(
                                    presenterDataSource: presenterDataSource,
                                )
                                
                                viewSettings2.append(viewSetting)
                            }
                            
                        default:
                            break;
                        }
                    }
                    
                    let packInDisplaySpace = PackInDisplaySpace(
                        displaySpaceId: displaySpace.fileHeader.id!,
                        viewSettings: viewSettings2
                    )
                    
                    groupedView.packInDisplaySpaces?.append(packInDisplaySpace)
                    groupedView.viewSettings = nil
                }
                
                saveToJSONFile(photoPresenter, filename: viewPosition.pathFile)
            }
        }
    }
}
