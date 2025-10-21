//
//  DisplaySpaceView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-11.
//

import SwiftUI

struct DisplaySpaceView: View {
    @ObservedObject var displaySpace: DisplaySpace
    
    @Binding private var displayView: DisplaySpaceViewType
    
    var body: some View {
        switch displayView {
        case .LibraryView:
            Text("LibraryView")
            
        case .DashboardView:
            DashboardView(displaySpace: displaySpace)
            
        case .RatioSimulatorView:
            RatioSimulatorView()
        }
    }
    
    init(
        displaySpace: DisplaySpace,
        displayView: Binding<DisplaySpaceViewType>
    ) {
        self.displaySpace = displaySpace
        self._displayView = displayView
    }
}

#Preview {
    //DisplaySpaceView()
}
