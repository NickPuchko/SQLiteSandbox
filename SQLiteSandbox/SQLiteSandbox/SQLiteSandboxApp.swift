//
//  SQLite_SandboxApp.swift
//  SQLite Sandbox
//
//  Created by Nikolai Puchko on 16.09.2021.
//

import SwiftUI

@main
struct SQLite_SandboxApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(viewModel: ContentViewModel())
    }
  }
}
