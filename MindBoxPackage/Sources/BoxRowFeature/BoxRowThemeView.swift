//
//  File.swift
//  
//
//  Created by lambert on 2024/5/21.
//

import SwiftUI
import Utils

public struct BoxRowThemeView: View {
  public let hex: String
  public init(hex: String) {
    self.hex = hex
  }
  public var body: some View {
    Circle()
      .fill(Color(hex: hex) ?? .primary)
      .padding(4)
      .background {
        Circle()
          .stroke(Color(hex: hex) ?? .primary, lineWidth: 2)
      }
  }
}

#Preview {
  BoxRowThemeView(hex: "#5F0F40")
    .frame(width: 20, height: 20)
}
