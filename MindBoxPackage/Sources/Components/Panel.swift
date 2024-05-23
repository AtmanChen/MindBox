//
//  Panel.swift
//  SimpleNoteApp
//
//  Created by Karin Prater on 18/04/2024.
//

import SwiftUI

#if os(macOS)
public extension View {
  func panel<PanelContent: View>(isPresented: Binding<Bool>,
                                 configuration: PanelConfiguration = PanelConfiguration(),
                                 @ViewBuilder content: @escaping () -> PanelContent) -> some View
  {
    modifier(PanelModifier(isPresented: isPresented,
                           configuration: configuration,
                           panelContent: content))
  }
  
//  func panel<PanelContent: View, State, Action>(
//    _ item: Binding<Store<State, Action>?>,
//    configuration: PanelConfiguration = PanelConfiguration(),
//    @ViewBuilder content: @escaping (_ store: Store<State, Action>) -> PanelContent
//  ) -> some View
//  {
//    let store = item.wrappedValue
//    return modifier(
//      PanelModifier(
//        isPresented: item.isPresent(),
//        configuration: configuration,
//        panelContent: {
//          Group {
//            
//          }
//        }
//      )
//    )
//  }
}

public struct PanelConfiguration {
  public var title: String
  public var showToolbar: Bool
  public var styleMask: NSWindow.StyleMask
  public var backing: NSWindow.BackingStoreType
  public var deferPanel: Bool
  public var isFloatingPanel: Bool
  public var becomesKeyOnlyIfNeeded: Bool
  public var hidesOnDeactivate: Bool

  public init(title: String = "Panel Title",
              showToolbar: Bool = true,
              styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable, .utilityWindow],
              backing: NSWindow.BackingStoreType = .buffered,
              deferPanel: Bool = false,
              isFloatingPanel: Bool = true,
              becomesKeyOnlyIfNeeded: Bool = true,
              hidesOnDeactivate: Bool = false)
  {
    self.title = title
    self.showToolbar = true
    self.styleMask = styleMask
    self.backing = backing
    self.deferPanel = deferPanel
    self.isFloatingPanel = isFloatingPanel
    self.becomesKeyOnlyIfNeeded = becomesKeyOnlyIfNeeded
    self.hidesOnDeactivate = hidesOnDeactivate
  }
    
  public static var noToolbar: PanelConfiguration {
    PanelConfiguration(showToolbar: false, styleMask: [.resizable, .closable, .fullSizeContentView, .nonactivatingPanel])
  }
}

fileprivate struct PanelModifier<PanelContent: View>: ViewModifier {
  @Binding var isPresented: Bool
  let configuration: PanelConfiguration
  let panelContent: () -> PanelContent
    
  @State private var panel: NSPanel? = nil
  @State private var panelDelegate: PanelDelegateHelper? = nil
    
  func body(content: Content) -> some View {
    content
      .onChange(of: isPresented) { _, newValue in
        if newValue {
          if let panel {
            panel.makeKeyAndOrderFront(nil)
          } else {
            openPanel()
          }
        } else {
          closePanel()
        }
      }
      .onDisappear {
        // main window is closed >> also close panel
        closePanel()
      }
  }
    
  func openPanel() {
    let panelViewController = NSHostingController(rootView: panelContent())
        
    let panel = NSPanel(
      contentRect: .zero,
      styleMask: configuration.styleMask,
      backing: configuration.backing,
      defer: configuration.deferPanel
    )
        
    panel.contentViewController = panelViewController
    panel.isFloatingPanel = configuration.isFloatingPanel
    if configuration.isFloatingPanel {
      panel.level = .floating
    }
        
    panel.collectionBehavior.insert(.fullScreenAuxiliary)
        
    panel.becomesKeyOnlyIfNeeded = configuration.becomesKeyOnlyIfNeeded
    panel.hidesOnDeactivate = configuration.hidesOnDeactivate
        
    panel.title = configuration.title
    panel.titleVisibility = configuration.showToolbar ? .visible : .hidden

    panel.titlebarAppearsTransparent = !configuration.showToolbar
    panel.isMovableByWindowBackground = true
    panel.backgroundColor = .clear
        
    panel.animationBehavior = .utilityWindow
        
    panel.center()
        
    panelDelegate = PanelDelegateHelper(closeWindow: {
      isPresented = false
    })
    panel.delegate = panelDelegate
        
    panel.makeKeyAndOrderFront(nil)
    self.panel = panel
  }
    
  func closePanel() {
    panel?.close()
    panel = nil
    panelDelegate = nil
  }
}

fileprivate class PanelDelegateHelper: NSObject, NSWindowDelegate {
  var closeWindow: () -> Void
    
  init(closeWindow: @escaping () -> Void) {
    self.closeWindow = closeWindow
  }
    
  func windowWillClose(_ notification: Notification) {
    closeWindow()
  }
}

#endif
