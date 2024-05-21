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
    var thought: Thought
    public init(thought: Thought) {
      self.thought = thought
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case themeButtonTapped
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .themeButtonTapped:
        return .none
      }
    }
  }
}

public struct ThoughtDetailView: View {
  @Bindable var store: StoreOf<ThoughtDetail>
  public init(store: StoreOf<ThoughtDetail>) {
    self.store = store
  }
  public var body: some View {
    VStack(alignment: .leading) {
      TextField("Thought Title", text: $store.thought.title)
        .textFieldStyle(.roundedBorder)
        .font(.title)
    }
  }
}
