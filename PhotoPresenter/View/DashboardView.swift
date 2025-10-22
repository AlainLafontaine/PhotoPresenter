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
        GeometryReader { geometry in
            VStack {
                
                if let description = displaySpace.displaySpaceHeader.description {
                    HStack {
                        Text(
                            "\(description)"
                        )
                        .lineLimit(nil) // Permet un nombre illimité de lignes
                        //.fixedSize(horizontal: false, vertical: true) // Empêche le texte de déborder horizontalement
                        //.frame(maxWidth: .infinity, alignment: .leading) // S'étend à la largeur disponible
                        .padding(.horizontal, 20) // marge égale à gauche et à droite
                    }
                }
                
                Spacer()
                Text("Tableau de bord")
                Spacer()
                
                List(displaySpace.viewPositions) { viewPosition in
                    HStack {
                        Text(viewPosition.name)
                        Spacer()
                        
                        if let presenter = displaySpace.presenters?.first(where:{ $0.fileHeader.id == viewPosition.id }) {
                            Text("\(NumberOfPhotos(presenter.groupedViews)) photos")
                        }
                    }
                    
                }
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    init (displaySpace: DisplaySpace) {
        self.displaySpace = displaySpace
    }
    
    private func NumberOfPhotos(_ groupedViews: [GroupedView]) -> Int {
        var count: Int = 0
        
        for groupedView in groupedViews {
            if let fastLoaddings = groupedView.fastLoaddings {
                for fastLoadding in fastLoaddings {
                    count += fastLoadding.fileInfos.count
                }
            }
        }
        
        return count
    }
}

#Preview {
    //DashboardView()
}
