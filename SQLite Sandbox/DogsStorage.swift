//
//  DogsStorage.swift
//  DogsStorage
//
//  Created by Nikolai Puchko on 16.09.2021.
//

import Foundation
import SQLite3

protocol Storing {
  associatedtype Entity: EntityType
  func createDatabase(for entity: Entity)
}

protocol EntityType {}

final class DogsStorage: Storing {
  var database: OpaquePointer?
  private let fileManager: FileManager = .default // shared by app process

  init() {
    let databaseURL = try? fileManager.url(
      for: .documentDirectory,
         in: .userDomainMask,
         appropriateFor: nil,
         create: true
    )
      .appendingPathComponent("swift.sqlite")
    database = openDatabase(with: databaseURL)
  }

  public func createDatabase(for entity: Entity) {
    var statement = ""
    statement += "PRAGMA encoding=\"UTF-8\";\n" // https://habr.com/ru/post/150543/
    statement += "CREATE TABLE IF NOT EXISTS `\(entity.rawValue)` (\n"
    statement += "  `id` INTEGER NOT NULL,\n"
    switch entity {
    case .dogs:
      statement += """
        `name` TEXT NOT NULL,
        `sex` INTEGER NOT NULL,
        `color_id` INTEGER NOT NULL,
        `breed_id` INTEGER NOT NULL,
        `owner_id` INTEGER,
        `dad_id` INTEGER,
        `mom_id` INTEGER,
        PRIMARY KEY(`id`),
        FOREIGN KEY(`color_id`) REFERENCES `\(Entity.owners.rawValue)` (`id`),
        FOREIGN KEY(`breed_id`) REFERENCES `\(Entity.breeds.rawValue)` (`id`),
        FOREIGN KEY(`owner_id`) REFERENCES `\(Entity.colors.rawValue)` (`id`),
        FOREIGN KEY(`dad_id`) REFERENCES `\(entity.rawValue)` (`id`),
        FOREIGN KEY(`mom_id`) REFERENCES `\(entity.rawValue)` (`id`),
      """ // SQLite convertes like so: INT -> INTEGER, VARCHAR(255) -> TEXT, etc.
    case .owners:
      statement += """
        `full_name` TEXT NOT NULL,
        `phone_number` TEXT,
        `street` TEXT,
      """
    case .breeds:
      statement += """
        `breed_name` TEXT NOT NULL,
      """
    case .colors:
      statement += """
        `name` TEXT NOT NULL,
      """
    case .champions:
      statement += """
        `dog_id` INTEGER NOT NULL,
        `year` INTEGER NOT NULL,
        FOREIGN KEY(`dog_id`) REFERENCES `\(Entity.dogs.rawValue)` (`id`),
      """
    }
    statement += "  PRIMARY KEY(`id`)\n);"
    NSLog(statement)

    var stepPointer: OpaquePointer?
    guard sqlite3_prepare_v2(
      database,
      statement,
      -1,
      &stepPointer,
      nil
    ) == SQLITE_OK, sqlite3_step(stepPointer) == SQLITE_DONE
    else {
      assertionFailure("Failed to create database: \(entity.rawValue)")
      return
    }
    sqlite3_finalize(stepPointer)
    NSLog("Database \(entity.rawValue) created successfully")
  }

  private func openDatabase(with url: URL?) -> OpaquePointer? {
    var openedDatabase: OpaquePointer? = nil
    let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
    guard let dbPath = url?.cstring,
          sqlite3_open_v2(dbPath, &openedDatabase, flags, nil) == SQLITE_OK else {
      assertionFailure("Failed to open SQLite database")
      return nil
    }
    NSLog("Reached databse with url: \(String(describing: url))")
    return openedDatabase
  }
}

extension DogsStorage {
  enum Entity: String, CaseIterable, EntityType {
    case owners, breeds, colors, champions, dogs // order to create tables
  }
}

extension URL {
  var cstring: [CChar]? {
    self.absoluteString.cString(using: String.Encoding.utf8)
  }
}
