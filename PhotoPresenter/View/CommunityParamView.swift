//
//  CommunityParamView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-02-20.
//

import SwiftUI
import SwiftUtilities

struct CommunityParamView: View {

    @ObservedObject var communityParam: CommunityParameter
    @State var intervalTimer: Double = 5
    @State var loopDuration: Double = 60
    @State var loopsPerImage: Int = 1
    @State var transitionMode: ImageTransition = .none

    /// Catégories affichées dans le combobox : la section « Premium » n'apparaît que
    /// si le drapeau d'activation est levé.
    private var visibleCategories: [ImageTransition.Category] {
        ImageTransition.Category.allCases.filter {
            $0 != .premium || FeatureFlags.premiumTransitions
        }
    }

    var body: some View {
        VStack {
            Stepper(
                "Interval timer : \(intervalTimer, specifier: "%.2f") sec",
                value: $intervalTimer,
                in: 0.25...60, step: 0.25
            ).padding(.top, 48)

            Toggle("Full Presenter Mode", isOn: $communityParam.fullPresenterMode)
                .padding(.top, 8)

            Toggle("Digital Signage Mode", isOn: $communityParam.digitalSignageMode)
                .padding(.top, 8)

            // Réglages propres au Digital Signage Mode.
            Stepper(
                "Durée d'un tour : \(loopDuration, specifier: "%.0f") sec",
                value: $loopDuration,
                in: 5...600, step: 5
            ).padding(.top, 8)

            Stepper(
                "Tours par image : \(loopsPerImage)",
                value: $loopsPerImage,
                in: 1...10, step: 1
            ).padding(.top, 8)

            Picker("Mode de transition :", selection: $transitionMode) {
                ForEach(visibleCategories, id: \.self) { category in
                    Section(category.label) {
                        ForEach(ImageTransition.cases(in: category), id: \.self) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                }
            }.padding(.top, 8)

            Spacer()

            HStack {
                SecondaryButton(title: "Annuler") {
                    intervalTimer = communityParam.intervalTimer
                    loopDuration = communityParam.loopDuration
                    loopsPerImage = communityParam.loopsPerImage
                    transitionMode = communityParam.transitionMode
                }

                PrimaryButton(title: "Appliquer") {
                    communityParam.intervalTimer = intervalTimer
                    communityParam.loopDuration = loopDuration
                    communityParam.loopsPerImage = loopsPerImage
                    communityParam.transitionMode = transitionMode
                    DisplaySpaceView.startCommunityTimer(communityParam: communityParam)
                    // Resynchronise la vitesse du défilement Digital Signage si actif
                    // (pilotée par loopDuration, plus par intervalTimer).
                    if DigitalSignageController.shared.isRunning {
                        DigitalSignageController.shared.updateInterval(loopDuration)
                        DigitalSignageController.shared.updateLoopsPerImage(loopsPerImage)
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            syncDraftFromModel()
        }
        .onChange(of: communityParam.digitalSignageMode) { _, isOn in
            if isOn {
                DigitalSignageController.shared.start(
                    loopDuration: communityParam.loopDuration,
                    loopsPerImage: communityParam.loopsPerImage
                )
            } else {
                DigitalSignageController.shared.stop()
            }
        }
    }
    
    init (communityParam: Binding<CommunityParameter>) {
        let param = communityParam.wrappedValue
        self.communityParam = param
        // Les @State doivent être initialisés via leur projection `State(initialValue:)` :
        // une affectation directe à travers le wrappedValue dans l'init est ignorée par
        // SwiftUI, ce qui laissait les contrôles sur leurs valeurs par défaut au lieu des
        // valeurs persistées du DisplaySpace chargé.
        _intervalTimer = State(initialValue: param.intervalTimer)
        _loopDuration = State(initialValue: param.loopDuration)
        _loopsPerImage = State(initialValue: param.loopsPerImage)
        _transitionMode = State(initialValue: param.transitionMode)
    }

    /// Recopie les réglages durables du modèle vivant vers les brouillons @State.
    /// Couvre le cas où la vue reste affichée pendant l'ouverture d'un autre fichier :
    /// l'init ne se rejoue pas, mais `onAppear` resynchronise à chaque affichage.
    private func syncDraftFromModel() {
        intervalTimer = communityParam.intervalTimer
        loopDuration = communityParam.loopDuration
        loopsPerImage = communityParam.loopsPerImage
        transitionMode = communityParam.transitionMode
    }
    
}

#Preview {
    //CommunityParamView()
}
