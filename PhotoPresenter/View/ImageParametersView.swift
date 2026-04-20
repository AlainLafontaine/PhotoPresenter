//
//  ParametersView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-06.
//

import SwiftUI
import SwiftUtilities

struct ImageParametersView: View {
    @Binding var intervalTimer: Double
    @Binding var transparencyGradientDirection: TransparencyGradientDirection?
    @Binding var opacityStart: Double?
    @Binding var opacityEnd: Double?
    var result: (_ applic: Bool) -> Void
    
    var body: some View {
        VStack {
            TabView {
                Tab("Photo", systemImage: "") {
                    VStack {
                        GroupBox("General") {
                            VStack(alignment: .leading) {
                                Text("Zone pour Photo")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 64)
                    Spacer()
                }
 
                Tab("Presenter", systemImage: "") {
                    VStack(alignment: .leading, spacing: 0) {
                        GroupBox(label: Text("General").font(.title2).bold()) {
                            VStack(alignment: .leading) {
                                Stepper("Interval timer : \(intervalTimer, specifier: "%.2f") sec", value: $intervalTimer, in: 0.25...60, step: 0.25)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)

                        GroupBox(label: Text("Transition").font(.title2).bold()) {
                            VStack(alignment: .leading) {
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)

                        GroupBox(label: Text("Effet").font(.title2).bold()) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Dégradé de la transparence:")
                                    Picker("", selection: Binding(
                                        get: { transparencyGradientDirection ?? TransparencyGradientDirection.none },
                                        set: { transparencyGradientDirection = $0 }
                                    )) {
                                        ForEach(TransparencyGradientDirection.allCases, id: \.self) { direction in
                                            Text(direction.label).tag(direction)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .fixedSize()
                                    Spacer()
                                }
                                Stepper(
                                    "Opacité de départ : \(opacityStart ?? 1.0, specifier: "%.1f")",
                                    value: Binding(
                                        get: { opacityStart ?? 1.0 },
                                        set: { opacityStart = $0 }
                                    ),
                                    in: 0.0...1.0,
                                    step: 0.1
                                )
                                Stepper(
                                    "Opacité d'arrivée : \(opacityEnd ?? 0.0, specifier: "%.1f")",
                                    value: Binding(
                                        get: { opacityEnd ?? 0.0 },
                                        set: { opacityEnd = $0 }
                                    ),
                                    in: 0.0...1.0,
                                    step: 0.1
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 64)
                    Spacer()
                }

                Tab("Communauté", systemImage: "") {
                    VStack {
                        GroupBox("General") {
                            VStack(alignment: .leading) {
                                Text("Zone pour Communauté")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 64)
                    Spacer()
                }
            }

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
