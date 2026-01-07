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
    @ObservedObject private var helper: DataPresenterHelp
                    
    private let displaySpaceId: UUID
    
    var body: some View {
        switch photoPresenter.photoPresenterHeader.orientation
        {
        case .Horizontal:
            ForEach(0..<photoPresenter.groupedViews.count, id: \.self) { grViewIndex in
                HStack(spacing: 0) {
                    ForEach(0..<photoPresenter.groupedViews[grViewIndex].nbOfView, id: \.self) { viewSettingIndex in
                        ImageView(
                            name: photoPresenter.photoPresenterHeader.name,
                            presenterDataSource: photoPresenter.groupedViews[grViewIndex].photoPresenterDataSources[viewSettingIndex],
                            viewPosition: helper.windowPos!,
                            setting: getViewSetting(
                                displaySpaceId: displaySpaceId,
                                packInDisplaySpaces: photoPresenter.groupedViews[grViewIndex].packInDisplaySpaces ?? [],
                                viewSettingIndex: viewSettingIndex
                            ),
                            fastLoading: photoPresenter.groupedViews[grViewIndex].fastLoaddings![viewSettingIndex]
                        )  
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
        case .Vertical:
            HStack(spacing: 0) {
                ForEach(0..<photoPresenter.groupedViews.count, id: \.self) { grViewIndex in
                    VStack(spacing: 0) {
                        ForEach(0..<photoPresenter.groupedViews[grViewIndex].nbOfView, id: \.self) { viewSettingIndex in
                            ImageView(
                                name: photoPresenter.photoPresenterHeader.name,
                                presenterDataSource: photoPresenter.groupedViews[grViewIndex].photoPresenterDataSources[viewSettingIndex],
                                viewPosition: helper.windowPos!,
                                setting: getViewSetting(
                                    displaySpaceId: displaySpaceId,
                                    packInDisplaySpaces: photoPresenter.groupedViews[grViewIndex].packInDisplaySpaces ?? [],
                                    viewSettingIndex: viewSettingIndex
                                ),
                                fastLoading: photoPresenter.groupedViews[grViewIndex].fastLoaddings![viewSettingIndex]
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case .Free:
            VStack {
                
            }
        }
    }

    init(
        dataHelper: DataPresenterHelp
    ) {
        self.helper = dataHelper
        self.photoPresenter = dataHelper.presenter
        self.displaySpaceId = dataHelper.displaySpaceId
    }
    
    private func getViewSetting(
        displaySpaceId: UUID,
        packInDisplaySpaces: [PackInDisplaySpace],
        viewSettingIndex: Int
    ) -> ViewSetting
    {
        // Chercher l'élément PackInDisplaySpace qui correspond au displaySpaceId
        let packInDisplaySpace = packInDisplaySpaces.first(where: { $0.displaySpaceId == displaySpaceId })
            
        return packInDisplaySpace!.viewSettings[viewSettingIndex]
    }
}
