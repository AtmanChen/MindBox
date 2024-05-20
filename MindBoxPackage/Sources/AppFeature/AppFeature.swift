//
//  File.swift
//  
//
//  Created by lambert on 2024/5/20.
//

import Foundation
import ComposableArchitecture
import Models
import BoxListFeature
import SwiftUI

@Reducer
public struct AppLogic {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var boxList = BoxListLogic.State()
    var columnVisibility: NavigationSplitViewVisibility = .all
    @Shared(.inMemory("selectedBox")) var selectedBox: Box?
    public init() {}
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case boxList(BoxListLogic.Action)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Scope(state: \.boxList, action: \.boxList) {
      BoxListLogic()
    }
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .boxList:
        return .none
      }
    }
  }
}

public struct AppView: View {
  @Bindable var store: StoreOf<AppLogic>
  public init(store: StoreOf<AppLogic>) {
    self.store = store
  }
  public var body: some View {
    NavigationSplitView(columnVisibility: $store.columnVisibility) {
      BoxListView(store: store.scope(state: \.boxList, action: \.boxList))
    } content: {
      ContentUnavailableView("Select a box please.", systemImage: "cube.box")
    } detail: {
      ContentUnavailableView("Select a thought please.", systemImage: "text.book.closed")
    }
  }
}
