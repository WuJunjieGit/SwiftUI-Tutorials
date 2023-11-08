//
//  CategoryRow.swift
//  SwiftUI-Test-1
//
//  Created by junjie wu on 2023/11/3.
//

import SwiftUI

struct CategoryRow: View {
  
  var categoryName: String
  var items: [Landmark]
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(categoryName)
        .font(.headline)
        .padding(.leading, 15)
        .padding(.top, 5)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 0) {
          ForEach(items) { landmark in
            NavigationLink {
              LandmarkDetail(landmark: landmark)
            } label: {
              CategoryItem(landmark: landmark)
            }
          }
        }
      }
      .frame(height: 185)
    }
  }
}

struct CategoryRow_Previews: PreviewProvider {
  static var previews: some View {
    let landmarks = ModelData().landmarks
    
    return CategoryRow(
      categoryName: landmarks[0].category.rawValue,
      items: Array(landmarks.prefix(4))
    )
  }
}
