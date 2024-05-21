//
//  File.swift
//
//
//  Created by lambert on 2024/5/21.
//

import ComposableArchitecture
import Models
import SwiftUI
import Utils


/*Button {
 store.send(.themeButtonTapped)
} label: {
 Circle()
   .fill(Color(hex: store.box.color.rawValue) ?? .primary)
}
.buttonStyle(.plain)
.frame(width: 16, height: 16)
.shadow(color: .primary, radius: 4)
.popover(item: $store.scope(state: \.destination?.themePicker, action: \.destination.themePicker)) { themePickerStore in
 BoxThemePickerView(store: themePickerStore)
}*/


@Reducer
public struct BoxThemePicker {
  public init() {}
  @ObservableState
  public struct State: Equatable {
    var colors = BoxThemeColor.sectionCases
    var box: Box
    var showPicker = false
    public init(box: Box) {
      self.box = box
    }
  }

  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    case didSelectColor(BoxThemeColor)
    case showPickerButtonTapped
  }

  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .binding:
      return .none
      
    case let .didSelectColor(color):
      guard state.box.color != color else {
        return .none
      }
      state.box.color = color
      @Shared(.fileStorage(.boxes)) var boxes: IdentifiedArrayOf<Box> = []
      boxes[id: state.box.id] = state.box
      return .none
      
    case .showPickerButtonTapped:
      state.showPicker = true
      return .none
    }
  }
}

public struct BoxThemePickerView: View {
  @Bindable var store: StoreOf<BoxThemePicker>
  public init(store: StoreOf<BoxThemePicker>) {
    self.store = store
  }
  public var body: some View {
    Button {
      store.send(.showPickerButtonTapped)
    } label: {
     Circle()
       .fill(Color(hex: store.box.color.rawValue) ?? .primary)
    }
    .buttonStyle(.plain)
    .frame(width: 16, height: 16)
    .shadow(color: .primary, radius: 4)
    .popover(isPresented: $store.showPicker) {
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
}
