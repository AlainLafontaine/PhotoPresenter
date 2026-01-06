//
//  DashboardView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-12.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var displaySpace: DisplaySpace
    @ObservedObject var sharedRessources: SharedRessources
    
    var presenters: [PhotoPresenter] = []
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                
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
                
                List(Array(displaySpace.viewPositions.enumerated()), id: \.element.id) { index, viewPosition in
                    VStack(alignment: .leading, spacing: 0) {
                        if let presenter = displaySpace.presenters?.first(where:{ $0.fileHeader.id == viewPosition.id }) {
                            HStack {
                                Text(presenter.photoPresenterHeader.name)
                                Spacer()
                                
                                Text("\(NumberOfPhotos(presenter.groupedViews)) photos")
                            }
                            
                            if let ratio = presenter.photoPresenterHeader.ratio {
                                HStack {
                                    if let isOnTop = viewPosition.windowPosition.isOnTop {
                                        if isOnTop {
                                            Text("Toujour sur le dessus")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    Spacer()
                                    Text("Ratio: \(String(format: "%.3f", ratio))")
                                }.font(.system(size: 10)) // taille plus petite que le standard
                            }
                            
                            HStack {
                                Text(getFriendlyName(for: viewPosition.screenName ?? "Inconnue"))
                                Spacer()
/*
                                if let settings = getViewSetting(displaySpaceId: displaySpace.fileHeader.id, presenter: presenter) {
                                    if settings.isInCommunity {
                                        Text("Communauté: oui")
                                    } else {
                                        Text("Communauté: non")
                                    }
                                }
*/
                            }.font(.system(size: 10)) // taille plus petite que le standard
                        }
                    }
                    .padding(8) // marge intérieure de tous les côtés
                    .background(index % 2 == 0 ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                    .listRowSeparator(.hidden) // supprime la ligne de séparation
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // supprime l'espacement
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    init (
        displaySpace: DisplaySpace,
        sharedRessources: SharedRessources
    )
    {
        self.displaySpace = displaySpace
        self.sharedRessources = sharedRessources
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
    
    private func getFriendlyName(for screenName: String) -> String {
        // Recherche dans sharedRessources pour trouver le mapping
        if let mapping = sharedRessources.screenNames2FriendlyNames.first(where: { $0.screenName == screenName }) {
            return mapping.friendlyName
        }
        
        // Si aucun mapping n'est trouvé, retourne le screenName original
        return screenName
    }
    
    private func getViewSetting(displaySpaceId: UUID, presenter: PhotoPresenter) -> ViewSetting? {
        var viewSetting: ViewSetting?
        
        for i in 0..<presenter.groupedViews.count {
            presenter.groupedViews[i].packInDisplaySpaces?.forEach { pack in
                if pack.displaySpaceId == displaySpaceId {
                    viewSetting = pack.viewSettings[0]
                }
            }
        }

        return viewSetting
    }
    
}

#Preview {
    //DashboardView()
}
