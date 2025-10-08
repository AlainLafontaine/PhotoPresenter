//
//  MainVIew.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-09-25.
//

import SwiftUI
import SwiftUtilities

struct MainView: View {
    
    @ObservedObject private var viewModel: DisplayViewModel    
    @State private var photoPresenter: PhotoPresenter
    
    private let filename: String
    
    var body: some View {
        Group {
            switch viewModel.displayView {
            case .information:
                PhotoPresenterInfo(presenter: $photoPresenter)
                
            case .multiImageView:
                MultiImageView(presenter: $photoPresenter)
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .background(Color.black).onDisappear {
                        
                    }
            }
        }.onAppear {
            if let window = NSApp.windows.last {
                window.identifier = NSUserInterfaceItemIdentifier(viewModel.mainViewId.uuidString)
            }
        }.onDisappear {
            saveToJSONFile(photoPresenter, filename: filename)
        }
    }
    
    init(filename path: String, presenter photoPresenter: PhotoPresenter, displayViewModel displayView: DisplayViewModel) {
        self.filename = path
        self.photoPresenter = photoPresenter
        self.viewModel = displayView
    }
}

