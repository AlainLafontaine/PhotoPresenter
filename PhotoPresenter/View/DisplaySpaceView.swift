//
//  DisplaySpaceView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-11.
//

import SwiftUI

struct DisplaySpaceView: View {
    @ObservedObject var displaySpace: DisplaySpace
    
    @State private var displayView: DisplaySpaceViewType = .DashboardView
    
    var body: some View {
        switch displayView {
        case .DashboardView:
            DashboardView(displaySpace: displaySpace)
            
        case .RatioSimulatorView:
            RatioSimulatorView()
            
        }
    }
    
    init(displaySpace: DisplaySpace) {
        self.displaySpace = displaySpace
    }
}

#Preview {
    //DisplaySpaceView()
}
