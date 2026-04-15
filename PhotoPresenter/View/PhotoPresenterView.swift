//
//  PhotoPresenterView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import SwiftUtilities

struct PhotoPresenterView: View {
    
    @ObservedObject private var helper: DataPresenterHelp
    
    @Binding private var communityParam: CommunityParameter
    @Binding private var dataPresenters: DataPresenterMap
    @Binding private var windowIdentifier: Set<String>
    
    
    var body: some View {
        Group {
            switch helper.displayView {
            case .information:
                PhotoPresenterInfoView(presenter: helper.presenter)
                
            case .multiImageView:
                MultiImageView(dataHelper: helper, communityParemeter: _communityParam)
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                .background(Color.black)
                .onDisappear {}
            }
        }.onAppear {
            for win in NSApp.windows {
                if let windowId = win.identifier?.rawValue {
                    let components = windowId.split(separator: "-")
                    
                    if components[0] == "photoPresenterWindows"  {
                        if !windowIdentifier.contains(windowId) {
                            windowIdentifier.insert(windowId)
                            helper.windowId = windowId
                            break;
                        }
                    }
                }
            }
        }
        .onDisappear {
            //saveToJSONFile(dataPresenter.presenter, filename: dataPresenter.filename)
        }
    }
    
    init(
        dataHelper: DataPresenterHelp,
        dataPresenters: Binding<DataPresenterMap>,
        windowIdentifier: Binding<Set<String>>,
        communityParam: Binding<CommunityParameter>
    ) {
        self.helper = dataHelper
        self._dataPresenters = dataPresenters
        self._windowIdentifier = windowIdentifier
        self._communityParam = communityParam
    }
}
