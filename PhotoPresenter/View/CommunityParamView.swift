//
//  CommunityParamView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-02-20.
//

import SwiftUI
import SwiftUtilities

struct CommunityParamView: View {
    
    @Binding var communityParam: CommunityParameter
    @State var intervalTimer: Double = 5
    
    var body: some View { 
        VStack {
            Stepper(
                "Interval timer : \(intervalTimer, specifier: "%.2f") sec",
                value: $intervalTimer,
                in: 0.25...60, step: 0.25
            ).padding(.top, 48)
            
            Spacer()
            
            HStack {
                SecondaryButton(title: "Annuler") {
                    intervalTimer = _communityParam.wrappedValue.intervalTimer
                }
                
                PrimaryButton(title: "Appliquer") {
                    _communityParam.wrappedValue.intervalTimer = intervalTimer
                    DisplaySpaceView.startCommunityTimer(intervalTimer: intervalTimer)
                }
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    init (communityParam: Binding<CommunityParameter>) {
        _communityParam = communityParam
        intervalTimer = communityParam.wrappedValue.intervalTimer
    }
    
}

#Preview {
    //CommunityParamView()
}
