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
                Text(
                    "\(description)"
                )
                .lineLimit(nil) // Permet un nombre illimité de lignes
                .fixedSize(horizontal: false, vertical: true) // Empêche le texte de déborder horizontalement
                .frame(maxWidth: .infinity, alignment: .leading) // S'étend à la largeur disponible
                .padding(.horizontal, 20) // marge égale à gauche et à droite
            }
            
            Spacer()
            Text("Tableau de bord")        
            Spacer()
            
            List(displaySpace.viewPositions) { viewPosition in
                Text(viewPosition.name)
            }
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    init (displaySpace: DisplaySpace) {
        self.displaySpace = displaySpace
    }
}

#Preview {
    //DashboardView()
}
