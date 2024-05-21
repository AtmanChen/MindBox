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
import ThoughtListFeature
import Combine

@Reducer
public struct AppLogic {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var boxList = BoxListLogic.State()
    var thoughtList: ThoughtList.State?
    var thoughtDetail: ThoughtDetail.State?
    var columnVisibility: NavigationSplitViewVisibility = .all
    @Shared(.appStorage("selectedBoxId")) var selectedBoxId: String?
    @Shared(.appStorage("selectedThoughtId")) var selectedThoughtId: String?
    public init() {}
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case boxList(BoxListLogic.Action)
    case onAppear
    case thoughtList(ThoughtList.Action)
    case thoughtDetail(ThoughtDetail.Action)
    case updateMindBoxSelection(MindBoxSelectionUpdate)
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
        
      case .onAppear:
        return .publisher {
          let boxSelection = state.$selectedBoxId.publisher
            .map(MindBoxSelectionUpdate.box(boxIdString:))
          
          let thoughtSelection = state.$selectedThoughtId.publisher
            .map(MindBoxSelectionUpdate.thought(thoughtIdString:))
          
          return Publishers.Merge(boxSelection, thoughtSelection)
            .receive(on: DispatchQueue.main)
            .map(Action.updateMindBoxSelection)
        }
        
      case .thoughtDetail:
        return .none
        
      case .thoughtList:
        return .none
        
      case let .updateMindBoxSelection(selection):
        debugPrint("did -->> receive thoughtId: \(selection)")
        switch selection {
        case let .box(boxIdString):
          @Shared(.fileStorage(.boxes)) var boxes: IdentifiedArrayOf<Box> = []
          if let boxIdString,
             let boxId = UUID(uuidString: boxIdString),
             let box = boxes[id: boxId] {
            state.thoughtList = ThoughtList.State(box: box)
          } else {
            state.thoughtList = nil
          }
          
        case let .thought(thoughtIdString):
          @Shared(.fileStorage(.thoughts)) var thoughts: IdentifiedArrayOf<Thought> = []
          if let thoughtIdString,
             let thoughtId = UUID(uuidString: thoughtIdString),
             let thought = thoughts[id: thoughtId] {
            state.thoughtDetail = ThoughtDetail.State(thought: thought)
          } else {
            state.thoughtDetail = nil
          }
        }
        
        return .none
      }
    }
    .ifLet(\.thoughtList, action: \.thoughtList) {
      ThoughtList()
    }
    .ifLet(\.thoughtDetail, action: \.thoughtDetail) {
      ThoughtDetail()
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
      if let thoughtListStore = store.scope(state: \.thoughtList, action: \.thoughtList) {
        ThoughtListView(store: thoughtListStore)
      } else {
        ContentUnavailableView("Select a box please.", systemImage: "cube.box")
      }
    } detail: {
      if let thoughtDetailStore = store.scope(state: \.thoughtDetail, action: \.thoughtDetail) {
        ThoughtDetailView(store: thoughtDetailStore)
      } else {
        ContentUnavailableView("Select a thought please.", systemImage: "text.book.closed")
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}
