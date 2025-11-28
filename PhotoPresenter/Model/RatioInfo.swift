//
//  RatioInfo.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-11-27.
//

import Foundation

final class RatioInfo {
    private var _height: Double
    private var _width: Double
    
    var ratio: Double {
        get { return _width / _height }
    }
    var Height: Double {
        get { return _height }
        set { _height = newValue }
    }
    var Width: Double {
        get { return _width }
        set { _width = newValue }
    }
    
    init(height: Double, width: Double) {
        _height = height
        _width = width
    }
}
