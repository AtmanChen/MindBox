//
//  ThoughtList.swift
//
//
//  Created by lambert on 2024/5/21.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Models

@Reducer
public struct ThoughtList {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public private(set) var box: Box
    @Shared var thoughts: IdentifiedArrayOf<Thought>
    var selectedThoughtId: String?
    public init(box: Box, thoughts: Shared<IdentifiedArrayOf<Thought>>) {
      self.box = box
      @Shared(.fileStorage(.thoughts)) var allThoughts: IdentifiedArrayOf<Thought> = []
      self._thoughts = thoughts
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case createNewThoughtButtonTapped
    case delegate(Delegate)
    case didSelectThought(String?)
    case onAppear
    
    public enum Delegate {
      case didSelectThought(String?)
    }
  }
  
  @Dependency(\.uuid) var uuid
  @Dependency(\.date) var date
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .createNewThoughtButtonTapped:
        let thought = Thought(id: uuid(), boxId: state.box.id, updateDate: date.now)
        @Shared(.fileStorage(.thoughts)) var allThoughts: IdentifiedArrayOf<Thought> = []
        allThoughts.append(thought)
        state.thoughts.append(thought)
        return .none
        
      case .onAppear:
//        return .publisher {
//          state.$selectedThoughtId.publisher
//            .receive(on: DispatchQueue.main)
//            .map(Action.didSelectThought)
//        }
        return .none
        
      case .delegate:
        return .none
        
      case let .didSelectThought(thoughtId):
          return .send(.delegate(.didSelectThought(thoughtId)))
      }
    }
  }
}

public struct ThoughtListView: View {
  @Bindable var store: StoreOf<ThoughtList>
  public init(store: StoreOf<ThoughtList>) {
    self.store = store
  }
  public var body: some View {
    Group {
      if store.thoughts.isEmpty {
        ContentUnavailableView("Light your mind up", systemImage: "cube.box")
      } else {
        List(selection: $store.selectedThoughtId.sending(\.didSelectThought)) {
          ForEach(store.$thoughts.elements) { $thought in
            ThoughtRowView(
              store: Store(
                initialState: ThoughtRow.State(thought: $thought),
                reducer: { ThoughtRow() }
              )
            )
          }
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          store.send(.createNewThoughtButtonTapped, animation: .bouncy)
        } label: {
          Image(systemName: "note.text.badge.plus")
            .foregroundStyle(Color(hex: store.box.color.rawValue) ?? Color.primary)
        }
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}
