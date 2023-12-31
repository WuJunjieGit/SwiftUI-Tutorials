//
//  ProfileHost.swift
//  SwiftUI-Test-1
//
//  Created by junjie wu on 2023/11/3.
//

import SwiftUI

struct ProfileHost: View {
  @State private var draftProfile = Profile.default
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      ProfileSummary(profile: draftProfile)
    }
    .padding()
  }
}

struct ProfileHost_Previews: PreviewProvider {
  static var previews: some View {
    ProfileHost().environmentObject(ModelData())
  }
}
