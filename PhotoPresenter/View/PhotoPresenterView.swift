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
    @Binding private var dataPresenters: DataPresenterMap
    @Binding private var windowIdentifier: Set<String>
    
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
            var id: String = ""
            var window: NSWindow?
            
            for win in NSApp.windows {
                if let windowId = win.identifier?.rawValue {
                    let components = windowId.split(separator: "-")
                    
                    if components[0] == "photoPresenterWindows"  {
                        if !windowIdentifier.contains(windowId) {
                            windowIdentifier.insert(windowId)
                            id = windowId
                            window = win
                            break;
                        }
                    }
                }
            }
            
            dataPresenter.windowId = id
            dataPresenters[dataPresenter.windowId!] = dataPresenter
        
            if let pos = dataPresenter.windowPos {
                
                let frame = NSRect(
                    x: pos.x,
                    y: pos.y,
                    width: pos.width,
                    height: pos.height
                )
                        
                window!.setFrame(frame, display: true)
            }
            
            print("Identifiant windowsss: \(id)")

        }
        .onDisappear {
            //saveToJSONFile(dataPresenter.presenter, filename: dataPresenter.filename)
        }
    }
    
    init(
        dataHelper: DataPresenterHelp,
        dataPresenters: Binding<DataPresenterMap>,
        windowIdentifier: Binding<Set<String>>
    ) {
        self.dataPresenter = dataHelper
        self._dataPresenters = dataPresenters
        self._windowIdentifier = windowIdentifier
    }
}
