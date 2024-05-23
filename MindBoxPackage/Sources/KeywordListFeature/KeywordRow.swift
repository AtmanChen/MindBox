//
//  File.swift
//
//
//  Created by lambert on 2024/5/23.
//

import Components
import ComposableArchitecture
import Foundation
import Models
import SwiftUI
import Utils

@Reducer
public struct KeywordRow {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public var keyword: Keyword
    public var thoughts: IdentifiedArrayOf<Thought>
    public init(keyword: Keyword) {
      self.keyword = keyword
      @Shared(.fileStorage(.thoughts)) var allThoughts: IdentifiedArrayOf<Thought> = []
      self.thoughts = allThoughts.filter { keyword.thoughtIds.contains($0.id) }
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case deleteKeywordMenuTapped
    case onAppear
    case openAllThoughtsForKeyword
    case toggleKeywordExpanded
    case updateKeywordThoughts
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce {
      state,
        action in
      switch action {
      case .binding:
        return .none
        
      case .deleteKeywordMenuTapped:
        return .none
        
      case .onAppear:
        return .publisher { [keyword = state.keyword] in
          @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
          return $allKeywords.publisher
            .map { $0.filter { $0.id == keyword.id } }
            .print()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .map { _ in Action.updateKeywordThoughts }
        }
        
      case .openAllThoughtsForKeyword:
        return .none
        
      case .toggleKeywordExpanded:
        state.keyword.expanded.toggle()
        @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
        allKeywords[id: state.keyword.id] = state.keyword
        return .none
        
      case .updateKeywordThoughts:
        @Shared(.fileStorage(.thoughts)) var allThoughts: IdentifiedArrayOf<Thought> = []
        state.thoughts = allThoughts.filter { state.keyword.thoughtIds.contains($0.id) }
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
    HStack {
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
      Spacer()
      
      if !store.keyword.thoughtIds.isEmpty {
        Button {
          store.send(.toggleKeywordExpanded, animation: .bouncy)
        } label: {
          Image(systemName: "chevron.right")
            .rotationEffect(.degrees(store.keyword.expanded ? 90 : 0))
        }
        .buttonStyle(.plain)
      }
    }
    .tag(store.keyword.id.uuidString)
    
    if store.keyword.expanded {
      ForEach(store.thoughts) { thought in
        KeywordThoughtRowView(thought: thought)
          .padding(.leading, 4)
      }
    }
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
