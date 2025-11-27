//
//  WindowPosition.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2025-10-08.
//

import Foundation
 
class WindowPosition: ObservableObject, Codable, Hashable {
    @Published var isOnTop: Bool? = false
    @Published var x: CGFloat
    @Published var y: CGFloat
    @Published var width: CGFloat
    @Published var height: CGFloat

    // MARK: - Init
     init(isOnTop: Bool? = false,
          x: CGFloat = 0,
          y: CGFloat = 0,
          width: CGFloat = 800,
          height: CGFloat = 600) {
         self.isOnTop = isOnTop
         self.x = x
         self.y = y
         self.width = width
         self.height = height
     }
     
     // MARK: - Codable
     enum CodingKeys: String, CodingKey {
         case isOnTop, x, y, width, height
     }
     
     required init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         isOnTop = try container.decodeIfPresent(Bool.self, forKey: .isOnTop)
         x = try container.decode(CGFloat.self, forKey: .x)
         y = try container.decode(CGFloat.self, forKey: .y)
         width = try container.decode(CGFloat.self, forKey: .width)
         height = try container.decode(CGFloat.self, forKey: .height)
     }
     
     func encode(to encoder: Encoder) throws {
         var container = encoder.container(keyedBy: CodingKeys.self)
         try container.encode(isOnTop, forKey: .isOnTop)
         try container.encode(x, forKey: .x)
         try container.encode(y, forKey: .y)
         try container.encode(width, forKey: .width)
         try container.encode(height, forKey: .height)
     }
     
     // MARK: - Hashable
     static func == (lhs: WindowPosition, rhs: WindowPosition) -> Bool {
         lhs.isOnTop == rhs.isOnTop &&
         lhs.x == rhs.x &&
         lhs.y == rhs.y &&
         lhs.width == rhs.width &&
         lhs.height == rhs.height
     }
     
     func hash(into hasher: inout Hasher) {
         hasher.combine(isOnTop)
         hasher.combine(x)
         hasher.combine(y)
         hasher.combine(width)
         hasher.combine(height)
     }
 }
