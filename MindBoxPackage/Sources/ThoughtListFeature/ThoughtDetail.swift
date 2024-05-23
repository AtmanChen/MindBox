//
//  File.swift
//
//
//  Created by lambert on 2024/5/21.
//

import Components
import ComposableArchitecture
import Models
import SwiftUI
import Utils

@Reducer
public struct ThoughtDetail {
  @Reducer(state: .equatable)
  public enum Destination {
    case keywordPicker(ThoughtKeywordPicker)
  }

  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Shared var thought: Thought
    var title: String
    var focus: Field?
    @Presents var destination: Destination.State?
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
    case destination(PresentationAction<Destination.Action>)
    case keywordPickerButtonTapped
    case themeButtonTapped
    case updateThoughtTitle
    case updateThoughtStatus(Status)
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
        
      case .destination:
        return .none
        
      case .keywordPickerButtonTapped:
        state.destination = .keywordPicker(ThoughtKeywordPicker.State(thought: state.$thought))
        return .none
        
      case .themeButtonTapped:
        return .none
        
      case .updateThoughtTitle:
        let validTitle = state.title.isEmpty ? "New Thought" : state.title
        state.thought.title = validTitle
        @Shared(.fileStorage(.thoughts)) var thoughts: IdentifiedArrayOf<Thought> = []
        thoughts[id: state.thought.id] = state.thought
        return .none
        
      case let .updateThoughtStatus(status):
        state.thought.status = status
        @Shared(.fileStorage(.thoughts)) var thoughts: IdentifiedArrayOf<Thought> = []
        thoughts[id: state.thought.id] = state.thought
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

public struct ThoughtDetailView: View {
  @Bindable var store: StoreOf<ThoughtDetail>
  @FocusState var focus: ThoughtDetail.State.Field?
  public init(store: StoreOf<ThoughtDetail>) {
    self.store = store
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack {
        TextField("Thought Title", text: $store.title)
          .focused($focus, equals: .title)
          .textFieldStyle(.roundedBorder)
          .font(.title)
          .frame(height: 44)
        
        Picker(selection: $store.thought.status.sending(\.updateThoughtStatus)) {
          ForEach(Status.allCases) { status in
            Label(status.description, systemImage: status.systemImageName)
              .labelStyle(.titleAndIcon)
              .tag(status)
          }
        } label: {
          Text("Thought Status")
        }
        .pickerStyle(.menu)
      }

      #if os(iOS)
      TextViewIOSWrapper(thought: store.thought)
      #else
      TextViewMacosWrapper(thought: store.thought)
      #endif
      ThoughtKeywordsCollectionView(
        store: Store(
          initialState: ThoughtKeywordsCollection.State(thought: store.$thought),
          reducer: { ThoughtKeywordsCollection() }
        )
      )
    }
    .padding()
    .bind($store.focus, to: $focus)
    .toolbar {
      ToolbarItem {
        Button {
          store.send(.keywordPickerButtonTapped)
        } label: {
          Image(systemName: "tag")
        }
        
        #if os(macOS)
        .panel(
          isPresented: $store.scope(state: \.destination?.keywordPicker, action: \.destination.keywordPicker).isPresent(),
          configuration: PanelConfiguration(title: "Add Keyword To \(store.thought.title)")
        ) {
          if let keywordPickerStore = store.scope(state: \.destination?.keywordPicker, action: \.destination.keywordPicker) {
            ThoughtKeywordPickerView(store: keywordPickerStore)
              .background(.thinMaterial)
              .frame(minWidth: 300, minHeight: 400)
          }
        }
        #else
        .popover(
            item: $store.scope(state: \.destination?.keywordPicker, action: \.destination.keywordPicker)
          ) { keyworkPickerStore in
            ThoughtKeywordPickerView(store: keyworkPickerStore)
          }
        #endif
      }
    }
  }
}
