//
//  File.swift
//
//
//  Created by lambert on 2024/5/21.
//

import ComposableArchitecture
import Database
import Foundation
import Models
import SwiftUI
import SwiftData

@Reducer
public struct RecursiveBoxRow {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var box: Box
    var showSubBoxes = true
    @Shared(.inMemory("refreshBoxLocation")) var refreshBoxLocation: RefreshBoxLocation?
    public init(box: Box) {
      self.box = box
    }
  }

  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case fetchSubBoxes
    case onAppear
    case toggleShowSubBoxes
    case updateSubBoxes([Box])
  }
  
  @Dependency(\.mindBoxDB) var db

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .fetchSubBoxes:
        return .run { [currentBoxUUID = state.box.uuid] send in
          let predicate = #Predicate<Box> { $0.parentBox?.uuid == currentBoxUUID }
          let sortDescritors = [
            SortDescriptor<Box>(\.creationDate, order: .reverse),
          ]
          
          let descriptor = FetchDescriptor<Box>(predicate: predicate, sortBy: sortDescritors)
          let subBoxes = try db.fetchBox(descriptor)
          await send(.updateSubBoxes(subBoxes), animation: .snappy)
        }
        
      case .onAppear:
        return .publisher { [currentBoxUUID = state.box.uuid] in
          state.$refreshBoxLocation.publisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .filter { location in
              if case let .box(boxUUID) = location {
                return boxUUID == currentBoxUUID
              }
              return false
            }
            .map { _ in Action.fetchSubBoxes }
        }

      case .toggleShowSubBoxes:
        state.showSubBoxes.toggle()
        return .none
        
      case let .updateSubBoxes(subBoxes):
        state.box.subBoxs = subBoxes
        return .none
      }
    }
  }
}

public struct RecursiveBoxRowView: View {
  @Bindable var store: StoreOf<RecursiveBoxRow>
  public init(store: StoreOf<RecursiveBoxRow>) {
    self.store = store
  }

  public var body: some View {
    HStack {
      Image(systemName: "cube.box.fill")
      BoxRowView(
        store: Store(
          initialState: BoxRowLogic.State(box: store.box),
          reducer: { BoxRowLogic() }
        )
      )
      Spacer()
      if let subBoxes = store.box.subBoxs,
         subBoxes.count > 0
      {
        Button {
          store.send(.toggleShowSubBoxes, animation: .snappy)
        } label: {
          Image(systemName: "chevron.right")
            .rotationEffect(.degrees(store.showSubBoxes ? 90 : 0))
        }
      } else {
        Color.clear
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
    .tag(store.box)

    if let subBoxes = store.box.subBoxs,
       store.showSubBoxes
    {
      ForEach(subBoxes) { subBox in
        RecursiveBoxRowView(
          store: Store(
            initialState: RecursiveBoxRow.State(box: subBox),
            reducer: { RecursiveBoxRow() }
          )
        )
        .padding(.leading)
      }
    }
  }
}
