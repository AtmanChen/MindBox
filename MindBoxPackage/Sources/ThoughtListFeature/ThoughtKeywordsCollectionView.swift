//
//  File.swift
//
//
//  Created by lambert on 2024/5/22.
//

import Components
import ComposableArchitecture
import Models
import SwiftUI
import Utils

@Reducer
public struct ThoughtKeywordsCollection {
  @Reducer(state: .equatable)
  public enum Destination {
    case deleteConfirmDialog(ConfirmationDialogState<Alert>)
    
    @CasePathable
    public enum Alert {
      case confirmCancel
      case confirmDelete
    }
  }

  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Shared var thought: Thought
    @Shared var keywords: IdentifiedArrayOf<Keyword>
    @Presents var destination: Destination.State?
    public init(thought: Shared<Thought>) {
      self._thought = thought
      @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
      self._keywords = Shared(allKeywords.filter { $0.thoughtIds.contains(thought.wrappedValue.id) })
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case deleteKeywordMenuTapped(Keyword)
    case destination(PresentationAction<Destination.Action>)
    case openAllThoughtsForKeyword(Keyword)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case let .deleteKeywordMenuTapped(keyword):
        state.destination = .deleteConfirmDialog(.deleteKeyword(keyword))
        return .none
        
      case .destination(.presented(.deleteConfirmDialog(.confirmCancel))):
        state.destination = nil
        return .none
        
      case .destination(.presented(.deleteConfirmDialog(.confirmDelete))):
        state.destination = nil
        return .run { _ in
        }

      case .destination:
        return .none
        
      case .openAllThoughtsForKeyword:
        // TODO: open all thoughts for Keyword
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

public struct ThoughtKeywordsCollectionView: View {
  @Bindable var store: StoreOf<ThoughtKeywordsCollection>
  public init(store: StoreOf<ThoughtKeywordsCollection>) {
    self.store = store
  }

  public var body: some View {
    FlowLayout(alignment: .leading, spacing: 4) {
      ForEach(store.$keywords.elements) { $keyword in
        HStack {
          Image(systemName: "tag.fill")
          Text(keyword.name)
        }
        .foregroundStyle((Color(hex: keyword.color.rawValue) ?? .primary).gradient)
        .padding(6)
        .background {
          RoundedRectangle(cornerRadius: 5)
            .fill(Color(.controlBackgroundColor))
        }
        .contextMenu {
          Button {
            store.send(.deleteKeywordMenuTapped(keyword))
          } label: {
            Label("Remove Keyword", systemImage: "")
          }
          
          Button {
            store.send(.openAllThoughtsForKeyword(keyword))
          } label: {
            Label("Show all thoughts for keyword", systemImage: "")
          }
        }
      }
    }
    .confirmationDialog($store.scope(state: \.destination?.deleteConfirmDialog, action: \.destination.deleteConfirmDialog))
  }
}

extension ConfirmationDialogState where Action == ThoughtKeywordsCollection.Destination.Alert {
  static func deleteKeyword(_ keyword: Keyword) -> ConfirmationDialogState {
    ConfirmationDialogState {
      TextState("Delete the keyword \"\(keyword.name)\"?")
    } actions: {
      ButtonState(role: .cancel, action: .confirmCancel) {
        TextState("Cancel")
      }
      ButtonState(role: .destructive, action: .confirmDelete) {
        TextState("Delete")
      }
    } message: {
      TextState("Are you sure to delete \"\(keyword.name)\"?")
    }
  }
}

#Preview {
  @Shared(.fileStorage(.thoughts)) var allThoughts: IdentifiedArrayOf<Thought> = .init(uniqueElements: Thought.examples)
  @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = .init(uniqueElements: Keyword.examples)
  return ThoughtKeywordsCollectionView(
    store: Store(
      initialState: ThoughtKeywordsCollection.State(thought: Shared(Thought.examples.last!)),
      reducer: { ThoughtKeywordsCollection() }
    )
  )
}
