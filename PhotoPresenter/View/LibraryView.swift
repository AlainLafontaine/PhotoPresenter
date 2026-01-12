//
//  LibraryView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-11-11.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var displaySpace: DisplaySpace
    @ObservedObject var sharedRessources: SharedRessources
    
    private var photoPresenterInfos: [PhotoPresenterInfo] = []
    private let requestOpeningPresenter: (URL) -> Bool
    
    var body: some View {
        VStack() {
            Text("L'offre de notre bibliothèque")
            
            Spacer()
            
            List(Array(photoPresenterInfos.enumerated()), id: \.element.id) { index, photoPresenterInfo in
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        VStack {
                            Text(
                                "\(photoPresenterInfo.isInclusInDisplaySpace ? "O" : "N")"
                            )
                            .onTapGesture {
                                if !photoPresenterInfo.isInclusInDisplaySpace {
                                    if self.requestOpeningPresenter(photoPresenterInfo.url) {
                                        photoPresenterInfo.isInclusInDisplaySpace = true
                                    }
                                }
                            }
                        }
                        VStack {
                            HStack {
                                if photoPresenterInfo.isInclusInDisplaySpace {
                                    Text("\(photoPresenterInfo.name)").foregroundColor(.red)
                                }
                                else {
                                    Text("\(photoPresenterInfo.name)")
                                }
                                Spacer()
                                
                                Text("\(photoPresenterInfo.nbPhotos) photos")
                            }
                            HStack {
                                Text("\(photoPresenterInfo.description)")
                                Spacer()
                                Text("Ratio: \(String(format: "%.3f", photoPresenterInfo.ratio))")
                            }.font(.system(size: 10)) // taille plus petite que le standard
                        }
                    }.foregroundColor((photoPresenterInfo.isInclusInDisplaySpace ? .red : .white))
                }
                .padding(8) // marge intérieure de tous les côtés
                .background(index % 2 == 0 ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                .listRowSeparator(.hidden) // supprime la ligne de séparation
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) // supprime l'espacement
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    init (
        displaySpace: DisplaySpace,
        sharedRessources: SharedRessources,
        requestOpeningPresenter: @escaping (URL) -> Bool
    )
    {
        self.displaySpace = displaySpace
        self.sharedRessources = sharedRessources
        self.requestOpeningPresenter = requestOpeningPresenter
        
        for path in sharedRessources.paths2PresenterDirectory {
            let ppInfos: [PhotoPresenterInfo] = GetAllPresenters(path: path)
            
            photoPresenterInfos.append(contentsOf: ppInfos)
        }
        
        photoPresenterInfos.sort { $0.name < $1.name }
        
        print("Nom du fichier :")
    }
    
    private func GetAllPresenters(path: String) -> [PhotoPresenterInfo] {
        var ppInfos: [PhotoPresenterInfo] = []
        let url = URL(fileURLWithPath: path)

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                
                do {
                    let data = try Data(contentsOf: fileURL)
                    let photoPresenter = try JSONDecoder().decode(PhotoPresenter.self, from: data)
                    let id: UUID = photoPresenter.fileHeader.id!
                    
                    ppInfos.append(
                        PhotoPresenterInfo(
                            url: fileURL,
                            id: id,
                            name: photoPresenter.photoPresenterHeader.name,
                            description: photoPresenter.photoPresenterHeader.description ?? "",
                            nbPhotos: NumberOfPhotos(photoPresenter.groupedViews),
                            ratio: photoPresenter.photoPresenterHeader.ratio ?? -1,
                            orientation: photoPresenter.photoPresenterHeader.orientation,
                            isInclusInDisplaySpace: IsInclusInDisplaySpace(id: id)
                        )
                    )
                } catch {
                    print("Erreur : \(error)")
                }
            }
        } catch {
            print("Erreur lors de la lecture du répertoire : \(error)")
        }
        
        return ppInfos
    }
    
    private func IsInclusInDisplaySpace(id: UUID) -> Bool {
        return displaySpace.presenters?.contains(where: { $0.fileHeader.id! == id }) ?? false
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
