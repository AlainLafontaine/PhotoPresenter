//
//  CheckFileType.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-13.
//

import Foundation

class CheckFileType : Decodable {
    var fileType: FileType
    
    init(fileType: FileType) {
        self.fileType = fileType
    }
}
