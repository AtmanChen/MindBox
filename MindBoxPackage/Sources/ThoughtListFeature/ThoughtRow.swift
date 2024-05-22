//
//  ThoughtRow.swift
//
//
//  Created by lambert on 2024/5/21.
//

import ComposableArchitecture
import Foundation
import Models
import SwiftUI
import Utils

@Reducer
public struct ThoughtRow {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    @Shared var thought: Thought
    var box: Box
    public init(thought: Shared<Thought>) {
      self._thought = thought
      @Shared(.fileStorage(.boxes)) var boxes: IdentifiedArrayOf<Box> = []
      self.box = boxes[id: thought.wrappedValue.boxId]!
    }
  }

  public enum Action: BindableAction {
    case binding(BindingAction<State>)
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .binding:
        return .none
      }
    }
  }
}

public struct ThoughtRowView: View {
  let store: StoreOf<ThoughtRow>
  public init(store: StoreOf<ThoughtRow>) {
    self.store = store
  }

  public var body: some View {
    VStack(alignment: .leading) {
      Text(store.thought.title)
        .bold()
      HStack {
        Text(store.thought.updateDate, formatter: itemFormatter)
          .font(.caption)
        HStack(spacing: 4) {
          Image(systemName: store.thought.status.systemImageName)
          Text(store.thought.status.description)
        }
        .font(.caption)
        .foregroundColor(.white)
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(RoundedRectangle(cornerRadius: 5, style: .continuous).fill(Color(hex: store.box.color.rawValue) ?? Color.gray))
      }

      if store.thought.body.count > 0 {
        Text(store.thought.body)
          .lineLimit(3)
      }
    }
    .tag(store.thought.id.uuidString)
  }
}

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()
