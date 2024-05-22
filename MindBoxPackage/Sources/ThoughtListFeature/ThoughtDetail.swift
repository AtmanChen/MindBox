//
//  File.swift
//  
//
//  Created by lambert on 2024/5/21.
//

import SwiftUI
import ComposableArchitecture
import Models
import Utils


@Reducer
public struct ThoughtDetail {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Shared var thought: Thought
    var title: String
    var focus: Field?
    public init(thought: Shared<Thought>) {
      self._thought = thought
      self.title = thought.wrappedValue.title
    }
    
    public enum Field: Hashable {
      case title
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case themeButtonTapped
    case updateThoughtTitle
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.focus):
        if state.focus == nil && state.title != state.thought.title {
          return .send(.updateThoughtTitle)
        }
        return .none
        
      case .binding:
        return .none
        
      case .themeButtonTapped:
        return .none
        
      case .updateThoughtTitle:
        let validTitle = state.title.isEmpty ? "New Thought" : state.title
        state.thought.title = validTitle
        debugPrint("SharedThought -->> Updated: \(state.thought) \(state.thought.title)")
        @Shared(.fileStorage(.thoughts)) var thoughts: IdentifiedArrayOf<Thought> = []
        thoughts[id: state.thought.id] = state.thought
        return .none
      }
    }
  }
}

public struct ThoughtDetailView: View {
  @Bindable var store: StoreOf<ThoughtDetail>
  @FocusState var focus: ThoughtDetail.State.Field?
  public init(store: StoreOf<ThoughtDetail>) {
    self.store = store
  }
  public var body: some View {
    VStack(alignment: .leading) {
      TextField("Thought Title", text: $store.title)
        .focused($focus, equals: .title)
        .textFieldStyle(.roundedBorder)
        .font(.title)
        .frame(height: 44)
    }
    .padding()
    .bind($store.focus, to: $focus)
  }
}
