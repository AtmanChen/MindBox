//
//  File.swift
//  
//
//  Created by lambert on 2024/5/20.
//

import ComposableArchitecture
import Models
import SwiftUI
import Database

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
    var box: Box
    var name: String
    var focus: Field?
    public init(box: Box) {
      self.box = box
      self.name = box.name
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
    case updateBoxName
  }
  
  @Dependency(\.mindBoxDB) var db
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.focus):
        if state.focus == nil && state.name != state.box.name {
          return .send(.updateBoxName)
        }
        return .none
        
      case .binding:
        return .none
        
      case .createSubBoxButtonTapped:
        return .run { [box = state.box] send in
          try db.addBox("New Box", box)
          @Shared(.inMemory("refreshBoxLocation")) var refreshBoxLocation: RefreshBoxLocation?
          refreshBoxLocation = .box(box.uuid)
        }
        
      case .deleteButtonTapped:
        return .run { [box = state.box] _ in
          try? db.deleteBox(box)
        }
        
      case .destination:
        return .none
        
      case .renameButtonTapped:
        state.focus = .rename
        return .none
        
      case .updateBoxName:
        // TODO: if input is empty, insert New Box as default name and refocus the field
        let validUpdateName = state.name.isEmpty ? "New Box" : state.name
        return .run { @MainActor [box = state.box] _ in
          try db.updateBox(box, validUpdateName)
        }
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
      TextField("Name", text: $store.name)
        .focused($focus, equals: .rename)
      #endif
    }
    .contextMenu {
      Button("Rename") {
        store.send(.renameButtonTapped)
      }
      Button {
        store.send(.createSubBoxButtonTapped)
      } label: {
        Text("Create New Box")
      }
      Divider()
      Button("Delete") {
        store.send(.deleteButtonTapped)
      }
    }
    .confirmationDialog($store.scope(state: \.destination?.deleteConfirmDialog, action: \.destination.deleteConfirmDialog))
//    .sheet(item: $store.scope(state: \.destination?.editFolder, action: \.destination.editFolder)) { editStore in
//
//    }
    .bind($store.focus, to: $focus)
  }
}
