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

            Spacer()

            HStack {
                SecondaryButton(title: "Annuler") {
                    intervalTimer = communityParam.intervalTimer
                }

                PrimaryButton(title: "Appliquer") {
                    communityParam.intervalTimer = intervalTimer
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
    }
    
}

#Preview {
    //CommunityParamView()
}
