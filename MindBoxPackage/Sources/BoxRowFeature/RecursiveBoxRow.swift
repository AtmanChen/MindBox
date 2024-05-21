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
import Utils
import Components

@Reducer
public struct RecursiveBoxRow {
  
  @Reducer(state: .equatable)
  public enum Destination {
    case themePicker(BoxThemePicker)
  }
  
  public init() {}

  @ObservableState
  public struct State: Equatable {
    @Shared var box: Box
    @Shared var subBoxes: IdentifiedArrayOf<Box>
    var showSubBoxes = true
    @Shared(.inMemory("refreshBoxLocation")) var refreshBoxLocation: RefreshBoxLocation?
    @Presents var destination: Destination.State?
    var themePicker: BoxThemePicker.State
    public init(box: Shared<Box>) {
      self._box = box
      let boxId = box.wrappedValue.id
      @Shared(.fileStorage(.boxes)) var boxes: IdentifiedArrayOf<Box> = []
      let subBoxes = try? boxes.filter(#Predicate { $0.parentBoxId == boxId })
      self._subBoxes = Shared(IdentifiedArrayOf(uniqueElements: subBoxes ?? []))
      self.themePicker = BoxThemePicker.State(box: box.wrappedValue)
    }
  }

  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
    case onAppear
    case themePicker(BoxThemePicker.Action)
    case toggleShowSubBoxes
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.themePicker, action: \.themePicker) {
      BoxThemePicker()
    }
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .destination:
        return .none
        
      case .onAppear:
        return .none
        
      case .themePicker:
        return .none

      case .toggleShowSubBoxes:
        state.showSubBoxes.toggle()
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

public struct RecursiveBoxRowView: View {
  @Bindable var store: StoreOf<RecursiveBoxRow>
  public init(store: StoreOf<RecursiveBoxRow>) {
    self.store = store
  }

  public var body: some View {
    HStack {
      BoxThemePickerView(
        store: store.scope(
          state: \.themePicker,
          action: \.themePicker
        )
      )
      BoxRowView(
        store: Store(
          initialState: BoxRowLogic.State(box: store.$box),
          reducer: { BoxRowLogic() }
        )
      )
      Spacer()
      if store.subBoxes.count > 0 {
        Button {
          store.send(.toggleShowSubBoxes, animation: .bouncy)
        } label: {
          Image(systemName: "chevron.right")
            .rotationEffect(.degrees(store.showSubBoxes ? 90 : 0))
        }
        .buttonStyle(.plain)
      } else {
        Color.clear
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
    .tag(store.box.id.uuidString)

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
