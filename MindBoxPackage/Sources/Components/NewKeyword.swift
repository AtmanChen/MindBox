//
//  File.swift
//  
//
//  Created by lambert on 2024/5/22.
//

import SwiftUI
import ComposableArchitecture
import Models
import Utils

@Reducer
public struct NewKeyword {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var searchTerm: String
    var selectedColor: KeywordThemeColor = .royalPurple
    public init(searchTerm: String) {
      self.searchTerm = searchTerm
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case colorDidTapped(KeywordThemeColor)
    case createNewKeywordButtonTapped
		case delegate(Delegate)
		
		public enum Delegate {
			case keywordAdded
		}
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case let .colorDidTapped(color):
        state.selectedColor = color
        return .none
        
      case .createNewKeywordButtonTapped:
        guard !state.searchTerm.isEmpty else {
          return .none
        }
        @Dependency(\.uuid) var uuid
        @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
        let keyword = Keyword(id: uuid(), name: state.searchTerm, color: state.selectedColor, thoughtIds: [])
        allKeywords[id: keyword.id] = keyword
				return .send(.delegate(.keywordAdded), animation: .bouncy)
				
			case .delegate:
				return .none
      }
    }
  }
}

public struct NewKeywordView: View {
  let store: StoreOf<NewKeyword>
  public init(store: StoreOf<NewKeyword>) {
    self.store = store
  }
  public var body: some View {
    VStack {
      HStack {
        ForEach(KeywordThemeColor.allCases) { color in
          Circle()
            .fill(Color(hex: color.rawValue) ?? .primary)
            .frame(width: store.selectedColor == color ? 20 : 15)
            .onTapGesture {
              store.send(.colorDidTapped(color), animation: .bouncy)
            }
        }
        Button {
          store.send(.createNewKeywordButtonTapped)
        } label: {
          Text("Create as new Keyword")
        }
        .disabled(store.searchTerm.isEmpty)
      }
    }
  }
}
