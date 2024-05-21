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
    var box: Box
    var thoughts: IdentifiedArrayOf<Thought> = []
    @Shared(.appStorage("selectedThoughtId")) var selectedThoughtId: String?
    public init(box: Box) {
      self.box = box
      @Shared(.fileStorage(.thoughts)) var thoughts: IdentifiedArrayOf<Thought> = []
      self.thoughts = thoughts.filter { $0.boxId == box.id }
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case createNewThoughtButtonTapped
    case didSelectThought(String?)
    case onAppear
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
        
//      case let .didSelectThought(thoughtId):
//        debugPrint("did -->> select thoughtId: \(thoughtId)")
//        return .none
        
      case .onAppear:
        return .publisher {
          state.$selectedThoughtId.publisher
            .receive(on: DispatchQueue.main)
            .map(Action.didSelectThought)
        }
        
      case let .didSelectThought(thoughtId):
        debugPrint("did -->> receive thoughtId: \(thoughtId)")
        return .none
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
    List(selection: $store.selectedThoughtId) {
      ForEach(store.thoughts) { thought in
        ThoughtRowView(
          store: Store(
            initialState: ThoughtRow.State(thought: thought),
            reducer: { ThoughtRow() }
          )
        )
        .tag(thought.id.uuidString)
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
