//
//  SwiftUIView.swift
//
//
//  Created by lambert on 2024/5/23.
//

import SwiftUI
import Models

public struct KeywordThoughtRowView: View {
  let thought: Thought
  public init(thought: Thought) {
    self.thought = thought
  }
  public var body: some View {
    VStack(alignment: .leading) {
      HStack {
        HStack(spacing: 4) {
          Image(systemName: thought.status.systemImageName)
          Text(thought.status.description)
          
        }
        .font(.caption)
        .foregroundColor(.white)
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(
          RoundedRectangle(
            cornerRadius: 5,
            style: .continuous
          )
          .fill(Color(.controlBackgroundColor))
        )
        Text(thought.updateDate, format: .dateTime)
          .font(.caption)
        Spacer()
      }
      Text(thought.title)
        .lineLimit(3)
        .bold()
    }
  }
}
