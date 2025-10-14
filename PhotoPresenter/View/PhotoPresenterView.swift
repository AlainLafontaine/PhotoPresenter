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
            if let window = NSApp.windows.last {
                window.identifier = NSUserInterfaceItemIdentifier(dataPresenter.mainViewId.uuidString)
                
                /*
                if photoPresenter.fileHeader.windowPosition == nil {
                    let pos: WindowPosition = WindowPosition(
                        x: Int(window.frame.origin.x),
                        y: Int(window.frame.origin.y),
                        width: Int(window.frame.size.width),
                        height: Int(window.frame.size.height)
                    )

                    photoPresenter.fileHeader.windowPosition = pos
                }
                */
            }
            
//            data2Presenter.photoPresenter = photoPresenter
        }.onDisappear {
//            saveToJSONFile(photoPresenter, filename: filename)
        }
    }
    
    init(data dataHelp: DataPresenterHelp) {
        self.dataPresenter = dataHelp
    }
}
