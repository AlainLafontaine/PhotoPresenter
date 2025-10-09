//
//  MainVIew.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import SwiftUtilities

struct MainView: View {
    
    @ObservedObject private var data2Presenter: Data2Presenter
    @State private var photoPresenter: PhotoPresenter
    
    private let filename: String
    
    var body: some View {
        Group {
            switch data2Presenter.displayView {
            case .information:
                PhotoPresenterInfo(presenter: photoPresenter)
                
            case .multiImageView:
                MultiImageView(presenter: photoPresenter)
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .background(Color.black).onDisappear {
                        
                    }
            }
        }.onAppear {
            if let window = NSApp.windows.last {
                window.identifier = NSUserInterfaceItemIdentifier(data2Presenter.mainViewId.uuidString)
            }
        }.onDisappear {
            saveToJSONFile(photoPresenter, filename: filename)
        }
    }
    
    init(filename path: String, presenter photoPresenter: PhotoPresenter, data2Presenter data: Data2Presenter) {
        self.filename = path
        self.photoPresenter = photoPresenter
        self.data2Presenter = data
    }
}

