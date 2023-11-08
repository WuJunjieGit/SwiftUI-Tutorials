//
//  tete.swift
//  SwiftUI-Test-1
//
//  Created by junjie wu on 2023/11/6.
//

import SwiftUI

struct tete: View {
  var progress: Float
  var enable: Bool
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 5.0)
        .opacity(enable ? 0.2 : 0.1)
        .foregroundColor(Color.white)
      if enable {
        Circle()
          .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
          .stroke(LinearGradient(gradient: Gradient(colors: [Color(red: 0.24, green: 0.929, blue: 0.589), Color(red: 0.149, green: 0.816, blue: 0.486)]), startPoint: .topLeading, endPoint: .bottomTrailing),
                  style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
//          .rotationEffect(Angle(degrees: 180))
      }
    }
  }
}

struct tete_Previews: PreviewProvider {
    static var previews: some View {
      tete(progress: 0.8, enable: true)
    }
}
