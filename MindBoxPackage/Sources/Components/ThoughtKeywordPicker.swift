//
//  ThoughtKeywordPicker.swift
//
//
//  Created by lambert on 2024/5/22.
//

import Models
import Utils
import SwiftUI
import ComposableArchitecture

@Reducer
public struct ThoughtKeywordPicker {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Shared var thought: Thought
		var keywords: IdentifiedArrayOf<Keyword> = []
    var selectedKeywords: Set<Keyword> = []
    var searchTerm: String = ""
		var newKeyword: NewKeyword.State?
    public init(thought: Shared<Thought>) {
      self._thought = thought
			@Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
			self.keywords = allKeywords
    }
  }
  
  public enum Action: BindableAction {
		case addkeywordsToThoughtButtonTapped
    case binding(BindingAction<State>)
    case clearSearchTerm
		case keywordSelectionUpdate(Set<Keyword>)
		case newKeyword(NewKeyword.Action)
		case newKeywordUpdate
		case searchTermUpdate(String)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .addkeywordsToThoughtButtonTapped:
        guard !state.selectedKeywords.isEmpty else {
          return .none
        }
        @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
        for keyword in state.selectedKeywords {
          var updateKeyword = keyword
          updateKeyword.thoughtIds.append(state.thought.id)
          allKeywords[id: updateKeyword.id] = updateKeyword
        }
        return .run { _ in
          @Dependency(\.dismiss) var dismiss
          await dismiss()
        }
        
      case .binding:
        return .none
        
      case .clearSearchTerm:
        state.searchTerm = ""
				return .send(.newKeywordUpdate)
				
			case let .keywordSelectionUpdate(updateSelectedKeywords):
				state.selectedKeywords = updateSelectedKeywords
				return .send(.newKeywordUpdate)
				
			case .newKeyword(.delegate(.keywordAdded)):
				return .send(.searchTermUpdate(""))
				
			case .newKeyword:
				return .none
				
			case .newKeywordUpdate:
				if state.selectedKeywords.isEmpty && state.keywords.isEmpty {
					state.newKeyword = NewKeyword.State(searchTerm: state.searchTerm)
				} else {
					state.newKeyword = nil
				}
				debugPrint("NewKeyword: \(state.newKeyword) \(state.searchTerm)")
				return .none
				
			case let .searchTermUpdate(updateSearchTerm):
				state.searchTerm = updateSearchTerm
				if updateSearchTerm.isEmpty {
					@Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
					state.keywords = allKeywords
				} else {
					state.keywords = state.keywords.filter { $0.name.lowercased().contains(updateSearchTerm.lowercased()) }
				}
				return .send(.newKeywordUpdate)
      }
    }
		.ifLet(\.newKeyword, action: \.newKeyword) {
			NewKeyword()
		}
  }
}

public struct ThoughtKeywordPickerView: View {
  @Bindable var store: StoreOf<ThoughtKeywordPicker>
  public init(store: StoreOf<ThoughtKeywordPicker>) {
    self.store = store
  }
  public var body: some View {
    VStack {
      HStack(spacing: 0) {
        Text("Add keywords to ")
        Text(store.thought.title)
          .bold()
      }
      HStack {
				TextField("Search", text: $store.searchTerm.sending(\.searchTermUpdate))
          .textFieldStyle(.roundedBorder)
        if !store.searchTerm.isEmpty {
          Button {
            store.send(.clearSearchTerm)
          } label: {
            Text("Clear")
          }
          .foregroundStyle(.pink)
        }
      }
			List(selection: $store.selectedKeywords.sending(\.keywordSelectionUpdate)) {
        ForEach(store.keywords) { keyword in
          HStack {
            Image(systemName: "tag.fill")
              .foregroundStyle((Color(hex: keyword.color.rawValue) ?? Color.primary).gradient)
            Text(keyword.name)
          }
          .tag(keyword)
        }
      }
      .listStyle(.plain)
      .frame(minHeight: 150)
      
      
      if !store.selectedKeywords.isEmpty {
        Button {
          store.send(.addkeywordsToThoughtButtonTapped)
        } label: {
          Text("Add keywords to thought")
        }
      } else if store.keywords.isEmpty {
//        NewKeywordView(
//          store: Store(
//            initialState: NewKeyword.State(searchTerm: store.searchTerm),
//            reducer: { NewKeyword() }
//          )
//        )
				if let newKeywordStore = store.scope(state: \.newKeyword, action: \.newKeyword) {
					NewKeywordView(store: newKeywordStore)
				}
      }
      
    }
    .padding()
  }
}
