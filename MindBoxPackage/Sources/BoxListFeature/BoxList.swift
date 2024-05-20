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
import Database
import BoxRowFeature
import SwiftData

@Reducer
public struct BoxListLogic {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Shared(.inMemory("selectedBox")) var selectedBox: Box?
    var boxes: [Box] = []
    public init() {}
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case createNewBoxButtonTapped
    case fetchTopBoxes
    case onAppear
    case topBoxesUpdated([Box])
  }
  
  @Dependency(\.mindBoxDB) var db
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .createNewBoxButtonTapped:
        return .run { send in
          try? db.addBox("New Box", nil)
          await send(.onAppear, animation: .bouncy)
        }
        
      case .fetchTopBoxes:
        return .run { send in
          let topBoxes = try db.fetchTopBoxes()
          await send(.topBoxesUpdated(topBoxes))
        }
        
      case .onAppear:
        return .send(.fetchTopBoxes)
        
      case let .topBoxesUpdated(boxes):
        state.boxes = boxes
        return .none
        
      }
    }
  }
}

public struct BoxListView: View {
  @Bindable var store: StoreOf<BoxListLogic>
  @Query(FetchDescriptor<Box>(predicate: #Predicate { $0.parentBox == nil }, sortBy: [SortDescriptor(\.creationDate, order: .reverse), SortDescriptor(\.name)]))
  private var topBoxes: [Box] {
    didSet {
      store.send(.topBoxesUpdated(topBoxes), animation: .snappy)
    }
  }
  public init(store: StoreOf<BoxListLogic>) {
    self.store = store
  }
  public var body: some View {
    List(selection: $store.selectedBox) {
      ForEach(store.boxes) { box in
        Section {
          OutlineGroup(box, id: \.uuid, children: \.subBoxs) { subBox in
            BoxRowView(
              store: Store(
                initialState: BoxRowLogic.State(box: subBox),
                reducer: { BoxRowLogic() }
              )
            )
            .tag(subBox)
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
          store.send(.createNewBoxButtonTapped)
        } label: {
          Label("Create new box", systemImage: "rectangle.stack.badge.plus")
        }
      }
    }
  }
}
