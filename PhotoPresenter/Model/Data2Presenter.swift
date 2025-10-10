//
//  Data2Presenter.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-26.
//

import Foundation

class Data2Presenter: ObservableObject, Identifiable {
    enum DisplayView: String, Codable, Equatable {
        case information
        case multiImageView
    }

    let mainViewId = UUID()
    let filename: String
    let overridingWindowPosition: WindowPosition?
    
    @Published var displayView: DisplayView = .multiImageView
    @Published var photoPresenter: PhotoPresenter? = nil
    
    init(filename path: String,
         overridingWindowPosition: WindowPosition? = nil)
    {
        self.filename = path
        self.overridingWindowPosition = overridingWindowPosition
    }
}
