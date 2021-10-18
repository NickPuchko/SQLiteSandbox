//
//  ContentViewModel.swift
//  ContentViewModel
//
//  Created by Nikolai Puchko on 16.09.2021.
//

import Combine

// MARK: view model
final class ContentViewModel: ObservableObject {
  private let storage: DogsStorage
  @Published var dogs: [Dog]

  init() {
    storage = .init()
    dogs = [] // get from storage by async call
  }

  func createFullDatabase() {
    DogsStorage.Entity.allCases.forEach { entity in
      storage.createDatabase(for: entity)
    }
  }
}

// MARK: model
struct Dog: Identifiable {
  let id: Int
  let name: String
  let sex: Int
  let breed_id: Int
  let owner_id: Int
  let dad_id: Int
  let mod_id: Int
}
