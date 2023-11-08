//
//  SwiftUI_Test_1App.swift
//  SwiftUI-Test-1
//
//  Created by junjie wu on 2023/10/31.
//

import SwiftUI

@main
struct SwiftUI_Test_1App: App {
  @StateObject private var modelData = ModelData()
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(modelData)
        }
    }
}
