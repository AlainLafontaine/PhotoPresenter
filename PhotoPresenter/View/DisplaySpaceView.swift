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
    
    @ObservedObject var displaySpace: DisplaySpace
    @ObservedObject var sharedRessources: SharedRessources
    
    @Binding private var displayView: DisplaySpaceViewType
    
    private let requestOpeningPresenter: (URL) -> Bool
    
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
        }
    }
    
    init(
        displaySpace: DisplaySpace,
        sharedRessources: SharedRessources,
        displayView: Binding<DisplaySpaceViewType>,
        requestOpeningPresenter: @escaping (URL) -> Bool
    ) {
        self.displaySpace = displaySpace
        self.sharedRessources = sharedRessources
        self._displayView = displayView
        self.requestOpeningPresenter = requestOpeningPresenter
        
        KeyCatcherView.globalKeyDown = { event in
            DisplaySpaceView.slideShowControllers.forEach { slideShowController in
                slideShowController.CommunityKeyDown(with: event)
            }
        }
    }
}

#Preview {
    //DisplaySpaceView()
}
