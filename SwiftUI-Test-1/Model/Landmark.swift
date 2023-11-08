//
//  Landmark.swift
//  SwiftUI-Test-1
//
//  Created by junjie wu on 2023/10/31.
//

import Foundation
import SwiftUI
import CoreLocation

/*
 Adding Codable conformance makes it easier to move data between the structure and a data file.
 You’ll rely on the Decodable component of the Codable protocol later in this section to read data from file.
 */

struct Landmark: Hashable, Codable, Identifiable {
  // 坐标信息
  var id: Int
  var name: String
  var park: String
  var state: String
  var description: String
  /// 是否 收藏/喜欢
  var isFavorite: Bool
  var isFeatured: Bool
  
  var category: Category
  enum Category: String, CaseIterable, Codable {
      case lakes = "Lakes"
      case rivers = "Rivers"
      case mountains = "Mountains"
  }
  
  private var imageName: String
  
  var image: Image {
    Image(imageName)
  }
  
  var featureImage: Image? {
    isFeatured ? Image(imageName + "_feature") : nil
  }
  
  // 坐标位置
  private var coordinates: Coordinates
  
  var locationCoordinate: CLLocationCoordinate2D {
      CLLocationCoordinate2D(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude)
  }

  struct Coordinates: Hashable, Codable {
    var latitude: Double
    var longitude: Double
  }
}
