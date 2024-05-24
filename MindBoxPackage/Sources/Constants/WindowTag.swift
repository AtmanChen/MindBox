//
//  File.swift
//  
//
//  Created by lambert on 2024/5/24.
//

import Foundation

public enum WindowTag {
  
  public static let mainWindowPrefix = "MindBox/MainWindow"
  public static let keywordsWindowPrefix = "MindBox/KeywordsWindow"
  
  case mainWindow
  case keywordsWindow(keywordIdString: String?)
  
  public var windowString: String {
    switch self {
    case .mainWindow: return "myapp://\(WindowTag.mainWindowPrefix)"
    case let .keywordsWindow(keywordIdString):
      if let keywordIdString {
        return "myapp://\(WindowTag.keywordsWindowPrefix)/\(keywordIdString)"
      } else {
        return "myapp://\(WindowTag.keywordsWindowPrefix)"
      }
    }
  }
  
}
