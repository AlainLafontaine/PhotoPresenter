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
                in: 30...600, step: 5
            ).padding(.top, 8)

            Stepper(
                "Tours par image : \(loopsPerImage)",
                value: $loopsPerImage,
                in: 1...10, step: 1
            ).padding(.top, 8)

            Spacer()

            HStack {
                SecondaryButton(title: "Annuler") {
                    intervalTimer = communityParam.intervalTimer
                    loopDuration = communityParam.loopDuration
                    loopsPerImage = communityParam.loopsPerImage
                }

                PrimaryButton(title: "Appliquer") {
                    communityParam.intervalTimer = intervalTimer
                    communityParam.loopDuration = loopDuration
                    communityParam.loopsPerImage = loopsPerImage
                    DisplaySpaceView.startCommunityTimer(intervalTimer: intervalTimer)
                    // Resynchronise la vitesse du défilement Digital Signage si actif.
                    if DigitalSignageController.shared.isRunning {
                        DigitalSignageController.shared.updateInterval(intervalTimer)
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: communityParam.digitalSignageMode) { _, isOn in
            if isOn {
                DigitalSignageController.shared.start(intervalTimer: communityParam.intervalTimer)
            } else {
                DigitalSignageController.shared.stop()
            }
        }
    }
    
    init (communityParam: Binding<CommunityParameter>) {
        self.communityParam = communityParam.wrappedValue
        intervalTimer = communityParam.wrappedValue.intervalTimer
        loopDuration = communityParam.wrappedValue.loopDuration
        loopsPerImage = communityParam.wrappedValue.loopsPerImage
    }
    
}

#Preview {
    //CommunityParamView()
}
