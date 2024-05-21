//
//  File.swift
//
//
//  Created by lambert on 2024/5/21.
//

import ComposableArchitecture
import Foundation
import Models
import SwiftUI
import SwiftData

@Reducer
public struct RecursiveBoxRow {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    @Shared var box: Box
    @Shared var subBoxes: IdentifiedArrayOf<Box>
    var showSubBoxes = true
    @Shared(.inMemory("refreshBoxLocation")) var refreshBoxLocation: RefreshBoxLocation?
    public init(box: Shared<Box>) {
      self._box = box
      let boxId = box.wrappedValue.id
      @Shared(.fileStorage(.boxes)) var boxes: IdentifiedArrayOf<Box> = []
      let subBoxes = try? boxes.filter(#Predicate { $0.parentBoxId == boxId })
      self._subBoxes = Shared(IdentifiedArrayOf(uniqueElements: subBoxes ?? []))
    }
  }

  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case onAppear
    case toggleShowSubBoxes
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAppear:
        return .none

      case .toggleShowSubBoxes:
        state.showSubBoxes.toggle()
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
          initialState: BoxRowLogic.State(box: store.$box),
          reducer: { BoxRowLogic() }
        )
      )
      Spacer()
      if store.subBoxes.count > 0 {
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

    if store.subBoxes.count > 0,
       store.showSubBoxes {
      ForEach(store.$subBoxes.elements) { $subBox in
        RecursiveBoxRowView(
          store: Store(
            initialState: RecursiveBoxRow.State(box: $subBox),
            reducer: { RecursiveBoxRow() }
          )
        )
        .padding(.leading)
      }
    }
  }
}
