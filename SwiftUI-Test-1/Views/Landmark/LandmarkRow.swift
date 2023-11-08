//
//  LandmarkRow.swift
//  SwiftUI-Test-1
//
//  Created by junjie wu on 2023/10/31.
//

import SwiftUI

struct LandmarkRow: View {
  var landmark: Landmark
    var body: some View {
      HStack {
        landmark.image
          .resizable()
          .frame(width: 50, height: 50)
        Text(landmark.name)
        Spacer()
        if landmark.isFavorite {
          Image(systemName: "star.fill")
            .foregroundColor(.yellow)
        }
      }
    }
}

struct LandmarkRow_Previews: PreviewProvider {
    static var previews: some View {
      let landmarks = ModelData().landmarks
      Group {
        LandmarkRow(landmark: landmarks[0])
      }
    }
}
