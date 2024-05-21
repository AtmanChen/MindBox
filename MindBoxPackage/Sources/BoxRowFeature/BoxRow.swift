//
//  File.swift
//  
//
//  Created by lambert on 2024/5/20.
//

import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct BoxRowLogic {
  public init() {}
  
  @Reducer(state: .equatable)
  public enum Destination {
    case deleteConfirmDialog(ConfirmationDialogState<Alert>)
//    case editFolder(FolderEditorLogic)
    
    @CasePathable
    public enum Alert {
      case confirmCancel
      case confirmDelete
    }
  }
  
  @ObservableState
  public struct State: Equatable {
    @Shared var box: Box
    var focus: Field?
    public init(box: Shared<Box>) {
      self._box = box
    }
    @Presents var destination: Destination.State?
    public enum Field: Hashable {
      case rename
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case createSubBoxButtonTapped
    case deleteButtonTapped
    case destination(PresentationAction<Destination.Action>)
    case renameButtonTapped
  }
  
  @Dependency(\.uuid) var uuid
  @Dependency(\.date) var date
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .createSubBoxButtonTapped:
        let newBox = Box(id: uuid(), updateDate: date.now, parentBoxId: state.box.id)
        @Shared(.fileStorage(.boxes)) var boxes: IdentifiedArrayOf<Box> = []
        boxes.append(newBox)
        return .none
        
      case .deleteButtonTapped:
        return .run { [box = state.box] _ in
          @Shared(.fileStorage(.boxes)) var boxes: IdentifiedArrayOf<Box> = []
          boxes.remove(id: box.id)
        }
        
      case .destination:
        return .none
        
      case .renameButtonTapped:
        state.focus = .rename
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

public struct BoxRowView: View {
  @Bindable var store: StoreOf<BoxRowLogic>
  @FocusState var focus: BoxRowLogic.State.Field?
  public init(store: StoreOf<BoxRowLogic>) {
    self.store = store
  }
  public var body: some View {
    Group {
      #if os(iOS)
      Text(store.box.name)
      #else
      TextField("Name", text: $store.box.name)
        .focused($focus, equals: .rename)
      #endif
    }
    .contextMenu {
      Button("Rename") {
        store.send(.renameButtonTapped)
      }
      Button {
        store.send(.createSubBoxButtonTapped, animation: .bouncy)
      } label: {
        Text("Create New Box")
      }
      Divider()
      Button("Delete") {
        store.send(.deleteButtonTapped, animation: .bouncy)
      }
    }
    .confirmationDialog($store.scope(state: \.destination?.deleteConfirmDialog, action: \.destination.deleteConfirmDialog))
//    .sheet(item: $store.scope(state: \.destination?.editFolder, action: \.destination.editFolder)) { editStore in
//
//    }
    .bind($store.focus, to: $focus)
  }
}
