//
//  CommunityParameter.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-02-20.
//

import Foundation

class CommunityParameter: ObservableObject {
    @Published var isCommunityModeActived: Bool = false
    @Published var intervalTimer: Double = 3.0
    @Published var isTransparent: Bool = false
    @Published var transparentFactor: Double = 1.0
}
