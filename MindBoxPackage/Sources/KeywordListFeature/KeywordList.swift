//
//  File.swift
//  
//
//  Created by lambert on 2024/5/23.
//

import Foundation
import Models
import Utils
import Components
import SwiftUI
import ComposableArchitecture

@Reducer
public struct KeywordList {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var keywords: IdentifiedArrayOf<Keyword>
    public init() {
      @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
      @Shared(.inMemory("keywordsWindowURL")) var keywordsWindowURL: URL?
      if let url = keywordsWindowURL,
         let keywordId = UUID(uuidString: url.lastPathComponent),
         let keyword = allKeywords[id: keywordId] {
        keywords = [keyword]
      } else {
        keywords = allKeywords
      }
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case onAppear
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAppear:
        return .none
      }
    }
  }
}

public struct KeywordListView: View {
  @Bindable var store: StoreOf<KeywordList>
  public init(store: StoreOf<KeywordList>) {
    self.store = store
  }
  public var body: some View {
    List {
      ForEach(store.keywords) { keyword in
        KeywordRowView(
          store: Store(
            initialState: KeywordRow.State(keyword: keyword),
            reducer: { KeywordRow() }
          )
        )
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}
