//
//  ContentView.swift
//  SQLite Sandbox
//
//  Created by Nikolai Puchko on 16.09.2021.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var viewModel: ContentViewModel
  var body: some View {
    Text("Hello, world!")
      .padding()
      .onAppear {
        viewModel.createFullDatabase()
      }
  }
}
