//
//  PhotoPresenterView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import SwiftUtilities

struct PhotoPresenterView: View {
    @ObservedObject private var dataPresenter: DataPresenterHelp
//    @Binding private var dataPresenters: DataPresenterMap
    
    var body: some View {
        Group {
            switch dataPresenter.displayView {
            case .information:
                PhotoPresenterInfo(presenter: dataPresenter.presenter)
                
            case .multiImageView:
                MultiImageView(presenter: dataPresenter.presenter)
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                .background(Color.black).onDisappear {
                    
                }
            }
        }.onAppear {
/*
            var id: String = ""
            
            for window in NSApp.windows {
                if let windowId = window.identifier?.rawValue {
                    let components = windowId.split(separator: "-")
                    
                    if components.count == 3 && components[0] == "photoPresenterWindows"  {
                        if windowId > id {
                            id = windowId
                        }
                    }
                }
            }
            
            dataPresenter.windowId = id
            dataPresenters[dataPresenter.windowId!] = dataPresenter
*/
        }.onDisappear {
            saveToJSONFile(dataPresenter.presenter, filename: dataPresenter.filename)
        }
    }
    
    init(
        dataHelper: DataPresenterHelp,
        //dataPresenters: Binding<DataPresenterMap>
    ) {
        self.dataPresenter = dataHelper
        //self._dataPresenters = dataPresenters
    }
}
