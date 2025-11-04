//
//  RatioSimulatorView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-11.
//

import SwiftUI

struct RatioSimulatorView: View {
    
    private var nbLine: Int = 1
    private var lines: [Int] = [1]
    
    var body: some View {

        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
        
            VStack(spacing: 0) {
                ForEach(0..<nbLine, id: \.self) { lineIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<lines[lineIndex], id: \.self) { colIndex in
                            VStack(spacing: 0) {
                                let w = width / CGFloat(lines[lineIndex])
                                let h = height / CGFloat(nbLine)
                                
                                Spacer()
                                Text("Largeur: \(String(format: "%.0f", h))")
                                Text("Hauteur: \(String(format: "%.0f", w))")
                                Spacer()
                                HStack {
                                    if height == 0 {
                                        Text("Pas de ratio")
                                    } else {
                                        let ratio = w / h
                                        Text("Ratio est de \(String(format: "%.3f", ratio))")
                                    }
                                }
                                Spacer()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.blue, width: 3)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    RatioSimulatorView()
}
