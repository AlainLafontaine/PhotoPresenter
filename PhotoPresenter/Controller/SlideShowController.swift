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
            } else if self.communityParam.digitalSignageMode && !self.viewSetting.isPaused {
                // En Digital Signage actif (présentateur non pausé), le changement
                // d'image est piloté par le compteur de tours du
                // DigitalSignageController, pas par ce timer standard.
            } else {
                self.advanceSlide()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
    }

    private func passesDisplayFilter(at index: Int) -> Bool {
        let showFav = viewSetting.isDisplayFavorite ?? false
        let showUnint = viewSetting.isDisplayUninteresting ?? false
        guard showFav || showUnint else { return true }
        let info = fastLoading.fileInfos[index]
        return (showFav && info.isFavorite) || (showUnint && info.isUninteresting)
    }

    private func nextFilteredIndex(from current: Int, reverse: Bool) -> Int {
        let count = fastLoading.fileInfos.count
        var next = reverse ? (current - 1 + count) % count : (current + 1) % count
        var attempts = 0
        while !passesDisplayFilter(at: next) && attempts < count {
            next = reverse ? (next - 1 + count) % count : (next + 1) % count
            attempts += 1
        }
        return next
    }

    func advanceSlide() {
        guard !viewSetting.isPaused else { return }
        guard isWindowVisible else { return }

        let count = fastLoading.fileInfos.count
        if viewSetting.isRandomizing {
            var attempts = 0
            repeat {
                viewSetting.currentIndex = Int.random(in: 0..<count)
                attempts += 1
            } while !passesDisplayFilter(at: viewSetting.currentIndex) && attempts < count
        } else if viewSetting.isReverse {
            viewSetting.currentIndex = nextFilteredIndex(from: viewSetting.currentIndex, reverse: true)
        } else {
            viewSetting.currentIndex = nextFilteredIndex(from: viewSetting.currentIndex, reverse: false)
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
        guard isWindowVisible else { return }
        if !viewSetting.isPaused {
            viewSetting.isPaused.toggle()
        }
        
        switch event.keyCode {
        case 123: // Left
            viewSetting.currentIndex = nextFilteredIndex(from: viewSetting.currentIndex, reverse: true)

        case 124: // Right
            viewSetting.currentIndex = nextFilteredIndex(from: viewSetting.currentIndex, reverse: false)

        case 125: // Down
            viewSetting.currentIndex = 0

        case 126: // Up
            viewSetting.currentIndex = fastLoading.fileInfos.count - 1

        default:
            break
        }
    }
}
