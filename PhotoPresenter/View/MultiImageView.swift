//
//  MultiImageView.swift
//  MultiImageView
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import AppKit  // Nécessaire pour NSImage
import SwiftUtilities

struct MultiImageView: View {
    @ObservedObject private var photoPresenter: PhotoPresenter
    
    var body: some View {
        switch photoPresenter.fileHeader.orientation
        {
        case .Horizontal:
            ForEach(0..<photoPresenter.groupedViews.count, id: \.self) { grViewIndex in
                HStack(spacing: 0) {
                    ForEach(0..<photoPresenter.groupedViews[grViewIndex].nbOfView, id: \.self) { viewSettingIndex in
                        VStack(spacing: 0) {
                            ImageView(name: photoPresenter.fileHeader.name,
                                      setting: photoPresenter.groupedViews[grViewIndex].viewSettings[viewSettingIndex])
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                //.ignoresSafeArea()
            }
            
        case .Vertical:
            HStack(spacing: 0) {
                ForEach(0..<photoPresenter.groupedViews.count, id: \.self) { grViewIndex in
                    VStack(spacing: 0) {
                        ForEach(0..<photoPresenter.groupedViews[grViewIndex].nbOfView, id: \.self) { viewSettingIndex in
                            ImageView(name: photoPresenter.fileHeader.name,
                                      setting: photoPresenter.groupedViews[grViewIndex].viewSettings[viewSettingIndex])
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            //.ignoresSafeArea()
            
        case .Free:
            VStack {
                
            }
        }
    }

    init(presenter: PhotoPresenter) {
        self.photoPresenter = presenter // ✅ note le underscore
    }
}
