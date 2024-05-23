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
public struct KeywordRow {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public var keyword: Keyword
    public var expanded: Bool
    public init(keyword: Keyword, expanded: Bool = true) {
      self.keyword = keyword
      self.expanded = expanded
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case deleteKeywordMenuTapped
    case openAllThoughtsForKeyword
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .deleteKeywordMenuTapped:
        return .none
        
      case .openAllThoughtsForKeyword:
        return .none
      }
    }
  }
}

public struct KeywordRowView: View {
  @Bindable var store: StoreOf<KeywordRow>
  public init(store: StoreOf<KeywordRow>) {
    self.store = store
  }
  public var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "tag.fill")
      Text(store.keyword.name)
    }
    .foregroundStyle(Color(.controlTextColor))
    .padding(6)
    .background {
      RoundedRectangle(cornerRadius: 5)
        .fill(Color(hex: store.keyword.color.rawValue)!.gradient)
    }
    .contextMenu {
      Button {
        store.send(.deleteKeywordMenuTapped)
      } label: {
        Label("Destroy this keyword", systemImage: "trash")
      }
      
      Button {
        store.send(.openAllThoughtsForKeyword)
      } label: {
        Label("Show all thoughts for keyword", systemImage: "doc.on.doc.fill")
      }
    }
    .labelStyle(.titleAndIcon)
  }
}

#Preview {
  KeywordRowView(
    store: Store(
      initialState: KeywordRow.State(keyword: Keyword.examples.first!),
      reducer: { KeywordRow() }
    )
  )
}
