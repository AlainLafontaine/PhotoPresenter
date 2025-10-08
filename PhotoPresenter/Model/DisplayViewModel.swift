//
//  DisplayViewModel.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-26.
//

import Foundation

class DisplayViewModel: ObservableObject, Identifiable {
    enum DisplayView: String, Codable, Equatable {
        case information
        case multiImageView
    }

    let mainViewId = UUID()
    @Published var displayView: DisplayView = .multiImageView
}
