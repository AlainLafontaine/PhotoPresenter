//
//  CommunityParamView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-02-20.
//

import SwiftUI
import SwiftUtilities

struct CommunityParamView: View {
    
    @EnvironmentObject var appState: AppState
    
    @Binding var communityParam: CommunityParameter
    @State var intervalTimer: Double = 5
    
    var body: some View { 
        VStack {
            Stepper(
                "Interval timer : \(intervalTimer, specifier: "%.2f") sec",
                value: $intervalTimer,
                in: 0.25...60, step: 0.25
            ).padding(.top, 48)

            Toggle("Full Presenter Mode", isOn: $appState.fullPresenterMode)
                .padding(.top, 8)

            Toggle("Digital Signage Mode", isOn: $appState.digitalSignageMode)
                .padding(.top, 8)

            Spacer()
            
            HStack {
                SecondaryButton(title: "Annuler") {
                    intervalTimer = _communityParam.wrappedValue.intervalTimer
                }
                
                PrimaryButton(title: "Appliquer") {
                    _communityParam.wrappedValue.intervalTimer = intervalTimer
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
        .onChange(of: appState.digitalSignageMode) { _, isOn in
            if isOn {
                DigitalSignageController.shared.start(intervalTimer: communityParam.intervalTimer)
            } else {
                DigitalSignageController.shared.stop()
            }
        }
    }
    
    init (communityParam: Binding<CommunityParameter>) {
        _communityParam = communityParam
        intervalTimer = communityParam.wrappedValue.intervalTimer
    }
    
}

#Preview {
    //CommunityParamView()
}
