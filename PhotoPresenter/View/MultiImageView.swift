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
    @Binding private var communityParam: CommunityParameter


    var body: some View {
        switch photoPresenter.photoPresenterHeader.orientation
        {
        case .Horizontal:
            VStack(spacing: 0) {
                ForEach(0..<photoPresenter.groupedViews.count, id: \.self) { grViewIndex in
                    HStack(spacing: 0) {
                        
                        
                        ForEach (0..<photoPresenter.groupedViews[grViewIndex].nbOfView, id: \.self) { viewSettingIndex in
                            ImageView(
                                name: photoPresenter.photoPresenterHeader.name,
                                presenterDataSource: photoPresenter.groupedViews[grViewIndex].photoPresenterDataSources[viewSettingIndex],
                                viewPosition: helper.windowPos!,
                                setting: getViewSetting(group: grViewIndex, view: viewSettingIndex),
                                fastLoading: photoPresenter.groupedViews[grViewIndex].fastLoaddings![viewSettingIndex],
                                communityParameter: _communityParam
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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
                                setting: getViewSetting(group: grViewIndex, view: viewSettingIndex),
                                fastLoading: photoPresenter.groupedViews[grViewIndex].fastLoaddings![viewSettingIndex],
                                communityParameter: _communityParam
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
        dataHelper: DataPresenterHelp,
        communityParemeter: Binding<CommunityParameter>
    ) {
        self.helper = dataHelper
        self.photoPresenter = dataHelper.presenter
        self._communityParam = communityParemeter
    }
    
    private func getViewSetting(group: Int, view: Int) -> ViewSetting {
        // Réglages portés par le PresenterViewPosition vivant du DisplaySpace
        // courant (Evo_012), résolu par l'App à la construction de la fenêtre.
        // Fallback jetable si la référence n'a pas pu être résolue.
        guard let viewPosition = helper.viewPosition else {
            return ViewSetting()
        }

        return viewPosition.viewSetting(for: photoPresenter, group: group, view: view)
    }
}
