//
//  ParametersView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-06.
//

import SwiftUI
import SwiftUtilities

struct ParametersView: View {
    @Binding var intervalTimer: Double
    var result: (_ applic: Bool) -> Void
    
    var body: some View {
        VStack {
            Stepper("Interval timer : \(intervalTimer, specifier: "%.2f") sec", value: $intervalTimer, in: 0.25...60, step: 0.25)
                .padding(.top, 48)
            
            Spacer()
            
            HStack {
                SecondaryButton(title: "Annuler") {
                    result(false);
                }
                
                PrimaryButton(title: "Appliquer") {
                    result(true)
                }
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
    }
}

#Preview {
    //ParametersView(  )
}
