//
//  MindBoxApp.swift
//  MindBox
//
//  Created by lambert on 2024/5/20.
//

import AppFeature
import KeywordsWindowFeature
import Constants
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
    .handlesExternalEvents(matching: Set(arrayLiteral: WindowTag.mainWindowPrefix))
    
    WindowGroup("Keywords") {
      KeywordsWindowView(
        store: Store(
          initialState: KeywordsWindow.State(),
          reducer: { KeywordsWindow() }
        )
      )
    }
    .defaultSize(CGSize(width: 600, height: 500))
    .handlesExternalEvents(matching: Set(arrayLiteral: WindowTag.keywordsWindowPrefix))
  }
}
