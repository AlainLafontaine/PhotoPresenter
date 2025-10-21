//
//  PhotoPresenterInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import SwiftUtilities

struct PhotoPresenterInfo: View {
    @ObservedObject private var photoPresenter: PhotoPresenter

    var body: some View {
        
        Text("Nom: \(photoPresenter.photoPresenterHeader.name)").padding()
        
        if let description = photoPresenter.photoPresenterHeader.description {
            Text("Description: \(description)").padding()
        }
    }
    
    init(presenter: PhotoPresenter) {
        self.photoPresenter = presenter
    }
}
