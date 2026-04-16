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
    
    @Binding var communityParam: CommunityParameter
    @ObservedObject var viewSetting: ViewSetting
    @ObservedObject var fastLoading: FastLoading
     
    var timer: Timer?
    var isWindowVisible: Bool = true


    init(
        viewSetting setting: ViewSetting,
        fastLoading: FastLoading,
        communityParameter: Binding<CommunityParameter>
    ) {
        self.viewSetting = setting
        self.fastLoading = fastLoading
        self._communityParam = communityParameter
    }
    
    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: viewSetting.intervalTimer,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }
            
            let isCapsLockActive = NSEvent.modifierFlags.contains(.capsLock)
            
            if isCapsLockActive {
                if !communityParam.isCommunityModeActived {
                    communityParam.isCommunityModeActived = true
                    DisplaySpaceView.startCommunityTimer(intervalTimer: self.communityParam.intervalTimer)
                }
            } else {
                self.advanceSlide()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    func advanceSlide() {
        guard !viewSetting.isPaused else { return }
        guard isWindowVisible else { return }
        
        if viewSetting.isRandomizing {
            viewSetting.currentIndex = Int.random(in: 0..<fastLoading.fileInfos.count)
        } else if viewSetting.isReverse {
            viewSetting.currentIndex = (viewSetting.currentIndex - 1 + fastLoading.fileInfos.count) % fastLoading.fileInfos.count
        } else {
            viewSetting.currentIndex = (viewSetting.currentIndex + 1) % fastLoading.fileInfos.count
        }
    }
    
    func keyDown(with event: NSEvent) {
        
        if communityParam.isCommunityModeActived {
            communityParam.isCommunityModeActived.toggle()
            DisplaySpaceView.stopCommunityTime()
        }
        
        switch event.keyCode {
        case 49:
            viewSetting.isPaused.toggle()
            
        case 123...126:
            navigationByKeyboard(event: event)
            
        default: break
        }
    }
    
    func CommunityKeyDown(with event: NSEvent) {
        if NSEvent.modifierFlags.contains(.capsLock) && viewSetting.isInCommunity ?? false {
        
            if !communityParam.isCommunityModeActived {
                communityParam.isCommunityModeActived.toggle()
            }
            
            switch event.keyCode {
            case 49:
                viewSetting.isPaused.toggle()
                
            case 123...126:
                navigationByKeyboard(event: event)
                
            default: break
            }
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
