//
//  File.swift
//  
//
//  Created by lambert on 2024/5/24.
//

import Foundation
import Models
import Components
import SwiftUI
import ComposableArchitecture
import KeywordListFeature
import ThoughtDetailFeature

@Reducer
public struct KeywordsWindow {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var keywordList = KeywordList.State()
    var thoughtDetail: ThoughtDetail.State?
    @Shared(.inMemory("selectedThoughtIdInKeyword")) var selectedThoughtIdInKeyword: String?
    public init() {}
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case didSelectThought(String?)
    case keywordList(KeywordList.Action)
    case onAppear
    case thoughtDetail(ThoughtDetail.Action)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Scope(state: \.keywordList, action: \.keywordList) {
      KeywordList()
    }
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case let .didSelectThought(thoughtIdString):
        @Shared(.fileStorage(.thoughts)) var allThoughts: IdentifiedArrayOf<Thought> = []
        if let thoughtIdString,
           let thoughtId = UUID(uuidString: thoughtIdString),
           let thought = $allThoughts[id: thoughtId] {
          state.thoughtDetail = ThoughtDetail.State(thought: thought)
        } else {
          state.thoughtDetail = nil
        }
        return .none
        
      case .keywordList:
        return .none
        
      case .onAppear:
        return .publisher {
          return state.$selectedThoughtIdInKeyword.publisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .map(Action.didSelectThought)
        }
        
      case .thoughtDetail:
        return .none
      }
    }
    .ifLet(\.thoughtDetail, action: \.thoughtDetail) {
      ThoughtDetail()
    }
  }
}

public struct KeywordsWindowView: View {
  @Bindable var store: StoreOf<KeywordsWindow>
  public init(store: StoreOf<KeywordsWindow>) {
    self.store = store
  }
  public var body: some View {
    NavigationSplitView {
      KeywordListView(store: store.scope(state: \.keywordList, action: \.keywordList))
    } detail: {
      if let thoughtDetailStore = store.scope(state: \.thoughtDetail, action: \.thoughtDetail) {
        ThoughtDetailView(store: thoughtDetailStore)
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}
