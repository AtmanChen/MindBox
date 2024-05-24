//
//  MindBoxApp.swift
//  MindBox
//
//  Created by lambert on 2024/5/20.
//

import AppFeature
import KeywordsWindowFeature
import ComposableArchitecture
import SwiftUI

@main
struct MindBoxApp: App {
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
    
    WindowGroup("Keywords") {
      KeywordsWindowView(
        store: Store(
          initialState: KeywordsWindow.State(),
          reducer: { KeywordsWindow() }
        )
      )
    }
    .defaultSize(CGSize(width: 600, height: 500))
  }
}
