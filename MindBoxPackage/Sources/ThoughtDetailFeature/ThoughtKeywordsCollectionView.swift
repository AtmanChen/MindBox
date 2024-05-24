//
//  File.swift
//
//
//  Created by lambert on 2024/5/22.
//

import Components
import ComposableArchitecture
import Constants
import Models
import SwiftUI
import Utils

@Reducer
public struct ThoughtKeywordsCollection {
  @Reducer(state: .equatable)
  public enum Destination {
    case deleteConfirmDialog(ConfirmationDialogState<Alert>)
    
    @CasePathable
    public enum Alert: Hashable {
      case confirmCancel
      case confirmDelete(Keyword, destroy: Bool)
    }
  }

  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Shared var thought: Thought
    @Shared var keywords: IdentifiedArrayOf<Keyword>
    @Presents var destination: Destination.State?
    @Shared(.inMemory("keywordsWindowURL")) var keywordsWindowURL: URL?
    public init(thought: Shared<Thought>) {
      self._thought = thought
      @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
      self._keywords = Shared(allKeywords.filter { $0.thoughtIds.contains(thought.wrappedValue.id) })
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case deleteKeywordMenuTapped(Keyword, destroy: Bool)
    case destination(PresentationAction<Destination.Action>)
    case openAllThoughtsForKeyword(Keyword)
    case openAllKeywords
    case openKeywordWindow(URL)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case let .deleteKeywordMenuTapped(keyword, destroy):
        state.destination = .deleteConfirmDialog(.deleteKeyword(keyword, destroy: destroy))
        return .none
        
      case .destination(.presented(.deleteConfirmDialog(.confirmCancel))):
        state.destination = nil
        return .none
        
      case let .destination(.presented(.deleteConfirmDialog(.confirmDelete(keyword, destroy)))):
        state.destination = nil
        state.keywords.remove(id: keyword.id)
        state.thought.keywords.removeAll(where: { $0.id == keyword.id })
        @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
        @Shared(.fileStorage(.thoughts)) var thoughts: IdentifiedArrayOf<Thought> = []
        thoughts[id: state.thought.id] = state.thought
        if destroy {
          allKeywords.remove(id: keyword.id)
        } else {
          var updateKeyword = keyword
          updateKeyword.thoughtIds.removeAll(where: { $0 == state.thought.id })
          allKeywords[id: keyword.id] = updateKeyword
        }
        return .none

      case .destination:
        return .none
        
      case let .openAllThoughtsForKeyword(keyword):
        #if os(macOS)
        let keywordsWindowString = WindowTag.keywordsWindow(keywordIdString: keyword.id.uuidString).windowString
        guard let keywordsWindowURL = URL(string: keywordsWindowString) else {
          return .none
        }
        return .send(.openKeywordWindow(keywordsWindowURL))
        #else
        return .none
        #endif
        
      case .openAllKeywords:
        #if os(macOS)
        let keywordsWindowString = WindowTag.keywordsWindow(keywordIdString: nil).windowString
        guard let keywordsWindowURL = URL(string: keywordsWindowString) else {
          return .none
        }
        return .send(.openKeywordWindow(keywordsWindowURL))
        #else
        return .none
        #endif
        
      case let .openKeywordWindow(url):
        state.keywordsWindowURL = url
        return .run { @MainActor _ in
          #if os(macOS)
          NSWorkspace.shared.open(url)
          #endif
        }
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
        HStack(spacing: 4) {
          Image(systemName: "tag.fill")
          Text(keyword.name)
        }
        .foregroundStyle(Color(.controlTextColor))
        .padding(6)
        .background {
          RoundedRectangle(cornerRadius: 5)
            .fill(Color(hex: keyword.color.rawValue)!.gradient)
        }
        .contextMenu {
          Button {
            store.send(.deleteKeywordMenuTapped(keyword, destroy: false))
          } label: {
            Label("Remove keyword from this thought", systemImage: "trash.slash")
              .labelStyle(.titleAndIcon)
          }
          
          Button {
            store.send(.deleteKeywordMenuTapped(keyword, destroy: true))
          } label: {
            Label("Destroy this keyword", systemImage: "trash")
              .labelStyle(.titleAndIcon)
          }
          
          Button {
            store.send(.openAllThoughtsForKeyword(keyword))
          } label: {
            Label("Open all thoughts for keyword", systemImage: "")
          }
          
          Button {
            store.send(.openAllKeywords)
          } label: {
            Label("Open all keywords", systemImage: "")
          }
        }
      }
    }
    .confirmationDialog($store.scope(state: \.destination?.deleteConfirmDialog, action: \.destination.deleteConfirmDialog))
  }
}

extension ConfirmationDialogState where Action == ThoughtKeywordsCollection.Destination.Alert {
  static func deleteKeyword(_ keyword: Keyword, destroy: Bool) -> ConfirmationDialogState {
    ConfirmationDialogState {
      TextState(destroy ? "Destroy this keyword?" : "Delete the keyword \"\(keyword.name)\"?")
    } actions: {
      ButtonState(role: .cancel, action: .confirmCancel) {
        TextState("Cancel")
      }
      ButtonState(role: .destructive, action: .confirmDelete(keyword, destroy: destroy)) {
        TextState(destroy ? "Destroy" : "Delete")
      }
    } message: {
      let action = destroy ? "destroy" : "delete"
      return TextState("Are you sure to \(action) \"\(keyword.name)\"?")
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
