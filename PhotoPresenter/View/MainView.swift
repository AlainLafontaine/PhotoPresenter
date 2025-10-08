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
    @ObservedObject private var windowObserver: WindowEventObserver
    
    @State private var photoPresenter: PhotoPresenter
    @State private var window: NSWindow?
    
    private let filename: String
    
    var body: some View {
        Group {
            switch viewModel.displayView {
            case .information:
                PhotoPresenterInfo(presenter: photoPresenter)
                
            case .multiImageView:
                MultiImageView(presenter: photoPresenter)
                    .frame(maxWidth: .infinity, maxHeight:.infinity)
                    .background(Color.black).onDisappear {
                        
                    }
            }
        }.onAppear {
            if let wind = NSApp.windows.last {
                self.window = wind
                self.window?.identifier = NSUserInterfaceItemIdentifier(viewModel.mainViewId.uuidString)
            }
        }.onDisappear {
            //photoPresenter.fileHeader.windowPosition = WindowPosition(x: Int(frame.origin.x), y: Int(frame.origin.y), width: Int(frame.size.width), height: Int(frame.size.height))
            saveToJSONFile(photoPresenter, filename: filename)
        }
    }
    
    init(
        filename path: String,
        presenter photoPresenter: PhotoPresenter,
        displayViewModel displayView: DisplayViewModel,
        windowObserver observer: WindowEventObserver
    ) {
        self.filename = path
        self.photoPresenter = photoPresenter
        self.viewModel = displayView
        self.windowObserver = observer
    }
}

