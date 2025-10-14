//
//  DashboardView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-12.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var displaySpace: DisplaySpace
    
    var body: some View {
        VStack {
            Text("Nom: \(displaySpace.fileHeader.name)")
            if let description = displaySpace.fileHeader.description {
                Text("\(description)")
            }
            
            Text("Tableau de bord")
        
            Spacer()
            Spacer()
/*
            List(displaySpace.presenters) { presenter in
                Text(presenter.name)
            }
 */
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    init (displaySpace: DisplaySpace) {
        self.displaySpace = displaySpace
    }
}

#Preview {
    //DashboardView()
}
