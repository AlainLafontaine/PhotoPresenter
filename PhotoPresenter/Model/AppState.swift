//
//  AppState.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-05-06.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var fullPresenterMode: Bool = false
    @Published var isDigitalSignageModeActive: Bool = false
}
