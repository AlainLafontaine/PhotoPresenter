//
//  DisplaySpaceView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-11.
//

import SwiftUI
import SwiftUtilities

struct DisplaySpaceView: View {
    
    public  static var slideShowControllers: [SlideShowController] = []
    
    private static var timer: Timer?
    
    @ObservedObject var displaySpace: DisplaySpace
    @ObservedObject var sharedRessources: SharedRessources
    
    @Binding var communityParam: CommunityParameter
    @Binding private var displayView: DisplaySpaceViewType
    
    private let requestOpeningPresenter: (URL, WindowPosition) -> Bool
    
    
    var body: some View {
        switch displayView {
        case .LibraryView:
            LibraryView(
                displaySpace: displaySpace,
                sharedRessources: sharedRessources,
                requestOpeningPresenter: requestOpeningPresenter
            )
            
        case .DashboardView:
            DashboardView(
                displaySpace: displaySpace,
                sharedRessources: sharedRessources
            )
            
        case .RatioSimulatorView:
            RatioSimulatorView()
        
        case .FactoryView:
            PhotoPresenterFactoryView()
            
        case .CommunityParamView:
            CommunityParamView(communityParam: $communityParam)
        }
    }
    
    init(
        displaySpace: DisplaySpace,
        sharedRessources: SharedRessources,
        displayView: Binding<DisplaySpaceViewType>,
        requestOpeningPresenter: @escaping (URL, WindowPosition) -> Bool,
        communityParameter: Binding<CommunityParameter>
    ) {
        self.displaySpace = displaySpace
        self.sharedRessources = sharedRessources
        self._displayView = displayView
        self.requestOpeningPresenter = requestOpeningPresenter
        self._communityParam = communityParameter
        
        KeyCatcherView.globalKeyDown = { event in
            
            if !communityParameter.wrappedValue.isCommunityModeActived {
                communityParameter.wrappedValue.isCommunityModeActived = true
                DisplaySpaceView.startCommunityTimer(intervalTimer: communityParameter.wrappedValue.intervalTimer)
            }
            
            DisplaySpaceView.slideShowControllers.forEach { slideShowController in
                slideShowController.CommunityKeyDown(with: event)
            }
        }
    }
    
    static func startCommunityTimer(intervalTimer: Double) {
        DisplaySpaceView.timer?.invalidate()
        DisplaySpaceView.timer = Timer.scheduledTimer(
            withTimeInterval: intervalTimer,
            repeats: true
        ) { _ in
            
            let isCapsLockActive = NSEvent.modifierFlags.contains(.capsLock)

            if isCapsLockActive {
                DisplaySpaceView.slideShowControllers.forEach { slideShowController in
                    slideShowController.stop()
                }
                
                DisplaySpaceView.slideShowControllers.forEach { slideShowController in
                    slideShowController.advanceSlide()
                }
            } else {
                stopCommunityTime()
            }
        }
    }
    
    static func stopCommunityTime() {
        DisplaySpaceView.timer?.invalidate()
        DisplaySpaceView.slideShowControllers.forEach { slideShowController in
            slideShowController.start()
        }
    }
}

#Preview {
    //DisplaySpaceView()
}
