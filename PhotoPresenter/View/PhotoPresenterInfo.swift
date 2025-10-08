//
//  PhotoPresenterInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import SwiftUtilities

struct PhotoPresenterInfo: View {
    @Binding private var photoPresenter: PhotoPresenter

    
    var body: some View {
        
        Text("Nom: \(photoPresenter.fileHeader.name)").padding()
        
        if let description = photoPresenter.fileHeader.description {
            Text("Description: \(description)").padding()
        }
    }
    
    init(presenter: Binding<PhotoPresenter>) {
        self._photoPresenter = presenter
    }
}
