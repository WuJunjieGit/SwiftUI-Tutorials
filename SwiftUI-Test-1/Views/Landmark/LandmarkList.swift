//
//  LandmarkList.swift
//  SwiftUI-Test-1
//
//  Created by junjie wu on 2023/10/31.
//

import SwiftUI

struct LandmarkList: View {
  @EnvironmentObject var modelData: ModelData
  @State private var showFavoritesOnly = false
  
  var filteredLandmarks: [Landmark] {
    modelData.landmarks.filter { landmark in
      (!showFavoritesOnly || landmark.isFavorite)
    }
  }
  
  var body: some View {
    NavigationSplitView {
      List {
        Toggle(isOn: $showFavoritesOnly) {
          Text("Favorites only")
        }
        ForEach(filteredLandmarks) { landmark in
          NavigationLink {
            LandmarkDetail(landmark: landmark)
          } label: {
            LandmarkRow(landmark: landmark)
          }
        }
      }
      .navigationTitle("Landmarks")
    } detail: {
      Text("Select a Landmark")
    }
  }
}

struct LandmarkList_Previews: PreviewProvider {
  static var previews: some View {
    LandmarkList().environmentObject(ModelData())
  }
}
