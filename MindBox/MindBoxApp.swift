//
//  MindBoxApp.swift
//  MindBox
//
//  Created by lambert on 2024/5/20.
//

import AppFeature
import ComposableArchitecture
import SwiftData
import SwiftUI
import Database

@main
struct MindBoxApp: App {
//  @Dependency(\.database) var database
//  private var modelContext: ModelContext {
//    guard let modelContext = try? database.context() else {
//      fatalError("Could not find modelContext")
//    }
//    return modelContext
//  }
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppLogic.State(),
          reducer: {
            AppLogic()
          }
        )
      )
    }
//    .modelContext(modelContext)
  }
}
