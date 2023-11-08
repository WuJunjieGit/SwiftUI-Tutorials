//
//  MapView.swift
//  SwiftUI-Test-1
//
//  Created by junjie wu on 2023/10/31.
//

import SwiftUI
import MapKit

struct MapView: View {
  
  var coordinate: CLLocationCoordinate2D
  
  var region: MKCoordinateRegion {
    MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
  }
  
  var body: some View {
    Map(coordinateRegion: .constant(region), interactionModes: .all, userTrackingMode: .constant(MapUserTrackingMode.follow))
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(coordinate: CLLocationCoordinate2D(latitude: 39.915, longitude: 116.397))
  }
}
