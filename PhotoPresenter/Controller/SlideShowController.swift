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
