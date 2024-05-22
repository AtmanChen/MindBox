//
//  TextViewMacosWrapper.swift
//
//
//  Created by lambert on 2024/5/22.
//

import SwiftUI
import Models

#if os(macOS)
public struct TextViewMacosWrapper: NSViewRepresentable {
  let thought: Thought
  public init(thought: Thought) {
    self.thought = thought
  }
    
  public func makeCoordinator() -> Coordinator {
    Coordinator(thought: thought, parent: self)
  }
    
  public func makeNSView(context: Context) -> NSTextView {
    let view = NSTextView()
        
    view.isRichText = true
    view.isEditable = true
    view.isSelectable = true
    view.allowsUndo = true
        
    view.usesInspectorBar = true
        
    view.usesFindPanel = true
    view.usesFindBar = true
    view.isGrammarCheckingEnabled = true
        
    view.isRulerVisible = true
        
    view.delegate = context.coordinator
    return view
  }
    
  public func updateNSView(_ nsView: NSTextView, context: Context) {
    nsView.textStorage?.setAttributedString(thought.formattedBodyText)
    context.coordinator.thought = thought
  }
    
  public class Coordinator: NSObject, NSTextViewDelegate {
    var thought: Thought
    let parent: TextViewMacosWrapper
        
    init(thought: Thought, parent: TextViewMacosWrapper) {
      self.thought = thought
      self.parent = parent
    }
        
    public func textDidChange(_ notification: Notification) {
      if let textview = notification.object as? NSTextView {
        thought.formattedBodyText = textview.attributedString()
      }
    }
  }
}
#endif
