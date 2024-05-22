//
//  File.swift
//  
//
//  Created by lambert on 2024/5/20.
//

import Foundation
import Models
import ComposableArchitecture
import SwiftUI
import BoxRowFeature

@Reducer
public struct BoxListLogic {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {
      @Shared(.fileStorage(.boxes)) var allBoxes: IdentifiedArrayOf<Box> = []
      self.boxes = allBoxes.filter { $0.parentBoxId == nil }
    }
    var boxes: IdentifiedArrayOf<Box>
    @Shared(.appStorage("selectedBoxId")) var selectedBoxId: String?
    @Shared(.inMemory("refreshBoxLocation")) var refreshBoxLocation: RefreshBoxLocation?
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case createNewBoxButtonTapped
    case onAppear
  }
  
  @Dependency(\.uuid) var uuid
  @Dependency(\.date) var date
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .createNewBoxButtonTapped:
        let newBox = Box(id: uuid(), updateDate: date.now, parentBoxId: nil)
        @Shared(.fileStorage(.boxes)) var allBoxes: IdentifiedArrayOf<Box> = []
        allBoxes[id: newBox.id] = newBox
        state.boxes.append(newBox)
        return .none
        
      case .onAppear:
        return .none
        
      }
    }
  }
}

public struct BoxListView: View {
  @Bindable var store: StoreOf<BoxListLogic>
  public init(store: StoreOf<BoxListLogic>) {
    self.store = store
  }
  public var body: some View {
    Group {
      if store.boxes.isEmpty {
        ContentUnavailableView("Create A New Mind Box", systemImage: "lightbulb.2.fill")
      } else {
        List(selection: $store.selectedBoxId) {
          ForEach(store.boxes) { box in
            RecursiveBoxRowView(
              store: Store(
                initialState: RecursiveBoxRow.State(box: Shared(box)),
                reducer: { RecursiveBoxRow() }
              )
            )
          }
        }
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          store.send(.createNewBoxButtonTapped, animation: .bouncy)
        } label: {
          Label("Create new box", systemImage: "rectangle.stack.badge.plus")
        }
      }
    }
  }
}
