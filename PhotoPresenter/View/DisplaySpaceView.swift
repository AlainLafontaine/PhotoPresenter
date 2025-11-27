//
//  DisplaySpaceView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-11.
//

import SwiftUI

struct DisplaySpaceView: View {
    @ObservedObject var displaySpace: DisplaySpace
    @ObservedObject var sharedRessources: SharedRessources
    
    @Binding private var displayView: DisplaySpaceViewType
    
    var body: some View {
        switch displayView {
        case .LibraryView:
            LibraryView(
                displaySpace: displaySpace,
                sharedRessources: sharedRessources
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
        displayView: Binding<DisplaySpaceViewType>
    ) {
        self.displaySpace = displaySpace
        self.sharedRessources = sharedRessources
        self._displayView = displayView
    }
}

#Preview {
    //DisplaySpaceView()
}
