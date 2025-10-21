//
//  RatioSimulatorView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-11.
//

import SwiftUI

struct RatioSimulatorView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            VStack {
                Spacer()
                VStack {
                    
                    Text("Largeur: \(String(format: "%.0f", width))")
                    Text("Hauteur: \(String(format: "%.0f", height))")
                }
                Spacer()
                HStack {
                    if height == 0 {
                        Text("Pas de ratio")
                    } else {
                        let ratio = width / height
                        Text("Ratio est de \(String(format: "%.3f", ratio))")
                    }
                }
                Spacer()
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    RatioSimulatorView()
}
