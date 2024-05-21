//
//  File.swift
//
//
//  Created by lambert on 2024/5/21.
//

import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct BoxThemePicker {
  @ObservableState
  public struct State: Equatable {
    var colors = BoxThemeColor.sectionCases
    var box: Box
  }

  public enum Action {
    case didSelectColor(BoxThemeColor)
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case let .didSelectColor(color):
      guard state.box.color != color else {
        return .none
      }
      state.box.color = color
      @Shared(.fileStorage(.boxes)) var boxes: IdentifiedArrayOf<Box> = []
      boxes[id: state.box.id] = state.box
      return .none
    }
  }
}

public struct BoxThemePickerView: View {
  let store: StoreOf<BoxThemePicker>
  public var body: some View {
    Form {
      ForEach(store.colors, id: \.self) { colorSection in
        Section(colorSection.first!.description) {
          HStack {
            ForEach(colorSection) { color in
              ZStack {
                if color == store.box.color {
                  Circle()
                    .stroke(Color(hex: color.rawValue) ?? Color.primary, lineWidth: 2)
                    .frame(width: 18, height: 18)
                  Circle()
                    .fill(Color(hex: color.rawValue) ?? Color.primary)
                    .frame(width: 14, height: 14)
                } else {
                  Circle()
                    .fill(Color(hex: color.rawValue) ?? Color.primary)
                    .frame(width: 18, height: 18)
                }
              }
              .onTapGesture {
                store.send(.didSelectColor(color))
              }
            }
            .padding()
          }
        }
      }
    }
    .padding()
  }
}
