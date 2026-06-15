//
//  PhotoPresenterView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import SwiftUtilities

struct PhotoPresenterView: View {

    @EnvironmentObject private var appState: AppState

    @ObservedObject private var helper: DataPresenterHelp

    @Binding private var communityParam: CommunityParameter
    @Binding private var dataPresenters: DataPresenterMap
    @Binding private var windowIdentifier: Set<String>

    @State private var scrollOffset: CGFloat = 0


    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            Group {
                if appState.isDigitalSignageModeActive {
                    ZStack {
                        contentView.offset(x: scrollOffset)
                        contentView.offset(x: scrollOffset + width)   // le clone, à droite
                    }
                    .clipped()
                } else {
                    contentView
                }
            }
            .onAppear {
                if appState.isDigitalSignageModeActive {
                    startScrolling(width: width)
                }
            }
            .onChange(of: appState.isDigitalSignageModeActive) { active in
                if active { startScrolling(width: width) }
                else { stopScrolling() }
            }
            .onChange(of: communityParam.intervalTimer) { _ in
                if appState.isDigitalSignageModeActive { startScrolling(width: width) }
            }
        }
        // assignWindowId() est attaché ici, sur le GeometryReader lui-même : son
        // onAppear n'est pas différé par la passe de layout du contenu, ce qui
        // préserve l'ordre attendu par PhotoPresenterApp (helper.windowId lu au
        // onAppear de la WindowGroup).
        .onAppear { assignWindowId() }
        .onDisappear {}
    }

    @ViewBuilder
    private var contentView: some View {
        switch helper.displayView {
        case .information:
            PhotoPresenterInfoView(presenter: helper.presenter)

        case .multiImageView:
            MultiImageView(dataHelper: helper, communityParemeter: _communityParam)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func startScrolling(width: CGFloat) {
        scrollOffset = 0                                       // départ = position d'origine
        withAnimation(.linear(duration: communityParam.intervalTimer)
                        .repeatForever(autoreverses: false)) {
            scrollOffset = -width                              // droite → gauche
        }
    }

    private func stopScrolling() {
        withAnimation(.linear(duration: 0)) {                 // retour immédiat à l'origine
            scrollOffset = 0
        }
    }

    private func assignWindowId() {
        for win in NSApp.windows {
            if let windowId = win.identifier?.rawValue {
                let components = windowId.split(separator: "-")

                if components[0] == "photoPresenterWindows" {
                    if !windowIdentifier.contains(windowId) {
                        windowIdentifier.insert(windowId)
                        helper.windowId = windowId
                        break
                    }
                }
            }
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
