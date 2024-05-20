//
//  MindBoxDatabase.swift
//
//
//  Created by lambert on 2024/5/20.
//

import ComposableArchitecture
import Foundation
import Models
import SwiftData

extension DependencyValues {
  public var mindBoxDB: MindBoxDatabase {
    get { self[MindBoxDatabase.self] }
    set { self[MindBoxDatabase.self] = newValue }
  }
}

public struct MindBoxDatabase {
  public var fetchTopBoxes: @Sendable () throws -> [Box]
  public var fetchBox: @Sendable (FetchDescriptor<Box>) throws -> [Box]
  public var fetchThoughts: @Sendable (FetchDescriptor<Thought>) throws -> [Thought]
  public var fetchThoughtsIn: @Sendable (_ box: Box) throws -> [Thought]
  public var addBox: @Sendable (_ name: String, _ parent: Box?) throws -> Void
  public var updateBox: @Sendable (_ box: Box, _ updateName: String) throws -> Void
  public var deleteBox: @Sendable (_ box: Box) throws -> Void
  public var addThoughtInBox: @Sendable (_ box: Box, _ content: String) throws -> Void
  public var deleteThought: @Sendable (Thought) throws -> Void
}

extension MindBoxDatabase: DependencyKey {
  public static var liveValue: MindBoxDatabase = Self(
    fetchTopBoxes: {
      @Dependency(\.database.context) var context
      let mindBoxContext = try context()
      let descriptor = FetchDescriptor<Box>(predicate: #Predicate { $0.parentBox == nil }, 
                                            sortBy: [
                                              SortDescriptor(\.creationDate, order: .reverse), SortDescriptor(\.name),
                                            ]
      )
      return try mindBoxContext.fetch(descriptor)
    },
    fetchBox: { descriptor in
      @Dependency(\.database.context) var context
      let mindBoxContext = try context()
      return try mindBoxContext.fetch(descriptor)
    },
    fetchThoughts: { descriptor in
      @Dependency(\.database.context) var context
      let mindBoxContext = try context()
      return try mindBoxContext.fetch(descriptor)
    },
    fetchThoughtsIn: { box in
      @Dependency(\.database.context) var context
      let mindBoxContext = try context()
      let boxId = box.uuid
      let descriptor = FetchDescriptor<Thought>(predicate: #Predicate { $0.box.uuid == boxId }, sortBy: [
        SortDescriptor(\.creationDate, order: .reverse), SortDescriptor(\.title),
      ])
      return try mindBoxContext.fetch(descriptor)
    },
    addBox: { boxName, parentBox in
      @Dependency(\.database.context) var context
      @Dependency(\.date.now) var now
      @Dependency(\.uuid) var uuid
      let mindBoxContext = try context()
      let box = Box(uuid: uuid(), name: boxName, creationDate: now, parentBox: parentBox)
      mindBoxContext.insert(box)
    },
    updateBox: { box, updateName in
      @Dependency(\.database.context) var context
      let mindBoxContext = try context()
      let updatedBox = box
      updatedBox.name = updateName
      mindBoxContext.insert(updatedBox)
    },
    deleteBox: { box in
      @Dependency(\.database.context) var context
      let mindBoxContext = try context()
      mindBoxContext.delete(box)
    },
    addThoughtInBox: { box, title in
      @Dependency(\.database.context) var context
      @Dependency(\.date.now) var now
      @Dependency(\.uuid) var uuid
      let mindBoxContext = try context()
      let thought = Thought(uuid: uuid(), box: box, title: title, creationDate: now)
      mindBoxContext.insert(thought)
    },
    deleteThought: { thought in
      @Dependency(\.database.context) var context
      let mindBoxContext = try context()
      mindBoxContext.delete(thought)
    }
  )
}

private let appContext: ModelContext = {
  do {
    let url = URL.applicationSupportDirectory.appending(path: "MindBox.sqlite")
    let config = ModelConfiguration(url: url)
    let container = try ModelContainer(
      for: Box.self,
      Thought.self,
      migrationPlan: nil,
      configurations: config
    )
    debugPrint("Database URL: \(url.absoluteString)")
    return ModelContext(container)
  } catch {
    fatalError("Failed to create container.")
  }
}()

private let previewAppContext: ModelContext = {
  do {
    let url = URL.applicationSupportDirectory.appending(path: "MindBox.sqlite")
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
      for: Box.self,
      Thought.self,
      migrationPlan: nil,
      configurations: config
    )
    return ModelContext(container)
  } catch {
    fatalError("Failed to create container.")
  }
}()

public struct Database {
  public var context: () throws -> ModelContext
}

extension Database: DependencyKey {
  public static var liveValue = Self(context: { appContext })
  public static var previewValue = Self(context: { previewAppContext })
}

extension DependencyValues {
  public var database: Database {
    get { self[Database.self] }
    set { self[Database.self] = newValue }
  }
}
