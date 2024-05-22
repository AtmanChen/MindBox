//
//  TextViewIOSWrapper.swift
//
//
//  Created by lambert on 2024/5/22.
//

import Models
import SwiftUI
import Utils

#if os(iOS)
public struct TextViewIOSWrapper: UIViewRepresentable {
  public let thought: Thought
  public init(thought: Thought) {
    self.thought = thought
  }
    
  public func makeCoordinator() -> Coordinator {
    Coordinator(self, thought: thought)
  }
  
  public func makeUIView(context: Context) -> UITextView {
    let view = UITextView()
        
    view.allowsEditingTextAttributes = true
    view.isEditable = true
    view.isSelectable = true
    view.font = UIFont.systemFont(ofSize: 18)
        
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.gray.cgColor
    view.layer.cornerRadius = 5
        
    view.textStorage.setAttributedString(thought.formattedBodyText)
    view.delegate = context.coordinator
        
    return view
  }
    
  public func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.textStorage.setAttributedString(thought.formattedBodyText)
    context.coordinator.thought = thought
  }
    
  public class Coordinator: NSObject, UITextViewDelegate {
    var thought: Thought
    let parent: TextViewIOSWrapper
        
    init(_ parent: TextViewIOSWrapper, thought: Thought) {
      self.parent = parent
      self.thought = thought
    }
        
    public func textViewDidChange(_ textView: UITextView) {
      thought.formattedBodyText = textView.attributedText
    }
  }
}
#endif
