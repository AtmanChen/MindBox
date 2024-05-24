//
//  File.swift
//  
//
//  Created by lambert on 2024/5/20.
//

import Foundation
import ComposableArchitecture
import Models
import BoxListFeature
import SwiftUI
import ThoughtListFeature
import KeywordListFeature
import Combine
import ThoughtDetailFeature

@Reducer
public struct AppLogic {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    var boxList = BoxListLogic.State()
    var keywordList = KeywordList.State()
    var thoughtList: ThoughtList.State?
    var thoughtDetail: ThoughtDetail.State?
    var columnVisibility: NavigationSplitViewVisibility = .all
    @Shared(.fileStorage(.boxes)) var boxes: IdentifiedArrayOf<Box> = []
    @Shared(.fileStorage(.thoughts)) var allThoughts: IdentifiedArrayOf<Thought> = []
    @Shared(.fileStorage(.keywords)) var allKeywords: IdentifiedArrayOf<Keyword> = []
    @Shared(.appStorage("selectedKeywordId")) var selectedKeywordId: String?
    @Shared var thoughts: IdentifiedArrayOf<Thought>
    var selectedBoxId: String?
    var selectedThoughtId: String?
    public init() {
      self._thoughts = Shared([])
    }
  }
  
  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case boxList(BoxListLogic.Action)
    case onAppear
    case keywordList(KeywordList.Action)
    case thoughtDetail(ThoughtDetail.Action)
    case thoughtList(ThoughtList.Action)
    case updateMindBoxSelection(MindBoxSelectionUpdate)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Scope(state: \.boxList, action: \.boxList) {
      BoxListLogic()
    }
    Scope(state: \.keywordList, action: \.keywordList) {
      KeywordList()
    }
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case let .boxList(.delegate(.didSelectBox(boxIdString))):
        state.selectedBoxId = boxIdString
        if let boxIdString,
           let boxId = UUID(uuidString: boxIdString),
           let box = state.boxes[id: boxId] {
          state.thoughts = state.allThoughts.filter { $0.boxId == box.id }
          if state.thoughtList?.box.id != boxId {
            state.selectedThoughtId = nil
            state.thoughtDetail = nil
          }
          state.thoughtList = ThoughtList.State(box: box, thoughts: state.$thoughts)
        } else {
          state.thoughtList = nil
        }
        return .none
        
      case .boxList:
        return .none
        
      case .onAppear:
        return .none
        
//      case .subscribeBoxSelection:
//        return .publisher {
//          state.$selectedBoxId.publisher
//            .map(MindBoxSelectionUpdate.box(boxIdString:))
//            .receive(on: DispatchQueue.main)
//            .map(Action.updateMindBoxSelection)
//        }
        
        
//      case .subscribeThoughtSelection:
//        return .none
//        return .publisher {
//          state.$selectedThoughtId.publisher
//            .map(MindBoxSelectionUpdate.thought(thoughtIdString:))
//            .receive(on: DispatchQueue.main)
//            .map(Action.updateMindBoxSelection)
//        }
      case .keywordList:
        return .none
        
      case .thoughtDetail:
        return .none
        
      case let .thoughtList(.delegate(.didSelectThought(thoughtId))):
        state.selectedThoughtId = thoughtId
        if let thoughtId,
           let thoughtUUID = UUID(uuidString: thoughtId),
           let sharedThought = state.$thoughts[id: thoughtUUID] {
          state.thoughtDetail = ThoughtDetail.State(thought: sharedThought)
        } else {
          state.thoughtDetail = nil
        }
        return .none
        
      case .thoughtList:
        return .none
        
      case let .updateMindBoxSelection(selection):
        switch selection {
        case let .box(boxIdString):
          if let boxIdString,
             let boxId = UUID(uuidString: boxIdString),
             let box = state.boxes[id: boxId] {
            state.thoughts = state.allThoughts.filter { $0.boxId == box.id }
            if state.thoughtList?.box.id != boxId {
              state.selectedThoughtId = nil
              state.thoughtDetail = nil
            }
            state.thoughtList = ThoughtList.State(box: box, thoughts: state.$thoughts)
          } else {
            state.thoughtList = nil
          }
        default: break
//        case let .thought(thoughtIdString):
//          if let thoughtIdString,
//             let thoughtId = UUID(uuidString: thoughtIdString),
//             let thought = state.thoughts[id: thoughtId] {
//            state.thoughtDetail = ThoughtDetail.State(thought: thought)
//          } else {
//            state.thoughtDetail = nil
//          }
        }
        return .none
      }
    }
    .ifLet(\.thoughtList, action: \.thoughtList) {
      ThoughtList()
    }
    .ifLet(\.thoughtDetail, action: \.thoughtDetail) {
      ThoughtDetail()
    }
  }
}

public struct AppView: View {
  @Bindable var store: StoreOf<AppLogic>
  public init(store: StoreOf<AppLogic>) {
    self.store = store
  }
  public var body: some View {
    NavigationSplitView(columnVisibility: $store.columnVisibility) {
      VStack {
        Section {
          BoxListView(store: store.scope(state: \.boxList, action: \.boxList))
        } header: {
          HStack {
            Text("Boxes")
              .font(.title)
              .bold()
            Spacer()
          }
          .padding()
        }
        Section {
          KeywordListView(store: store.scope(state: \.keywordList, action: \.keywordList))
        } header: {
          HStack {
            Text("Keywords")
              .font(.title)
              .bold()
            Spacer()
          }
          .padding()
        }
      }
    } content: {
      if let thoughtListStore = store.scope(state: \.thoughtList, action: \.thoughtList) {
        ThoughtListView(store: thoughtListStore)
      } else {
        ContentUnavailableView("Select a box please.", systemImage: "cube.box")
      }
    } detail: {
      if let thoughtDetailStore = store.scope(state: \.thoughtDetail, action: \.thoughtDetail) {
        ThoughtDetailView(store: thoughtDetailStore)
      } else {
        ContentUnavailableView("Select a thought please.", systemImage: "text.book.closed")
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}
