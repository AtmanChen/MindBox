import Foundation
import Tagged
import IdentifiedCollections

//public typealias Box = MindBoxSchemaV1.Box
//public typealias Thought = MindBoxSchemaV1.Thought

public enum RefreshBoxLocation: Hashable {
  case root
  case box(UUID)
}

public extension URL {
  static let boxes: URL = {
    let url = Self.documentsDirectory.appending(component: "boxes.json")
    print(url.path())
    return url
  }()
  static let thoughts = Self.documentsDirectory.appending(component: "thoughts.json")
}

public struct Box: Equatable, Identifiable, Codable, Hashable {
  public let id: UUID
  public var name: String = "New Box"
  public var updateDate: Date
  public var parentBoxId: UUID?
  
  public init(id: UUID, updateDate: Date, parentBoxId: UUID? = nil) {
    self.id = id
    self.updateDate = updateDate
    self.parentBoxId = parentBoxId
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(name)
    hasher.combine(updateDate)
    hasher.combine(parentBoxId)
  }
}

public struct Thought: Equatable, Identifiable, Codable, Hashable {
  public let id: UUID
  public var boxId: UUID
  public var title: String = "New Thought"
  public var updateDate: Date
  
  public init(id: UUID, boxId: UUID, updateDate: Date) {
    self.id = id
    self.boxId = boxId
    self.updateDate = updateDate
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(boxId)
    hasher.combine(title)
    hasher.combine(updateDate)
  }
}

//public enum MindBoxSchemaV1: VersionedSchema {
//  public static var versionIdentifier = Schema.Version(1, 0, 0)
//  public static var models: [any PersistentModel.Type] {
//    [
//      Box.self,
//      Thought.self
//    ]
//  }
//  
//  @Model
//  public class Box {
//    public var uuid: UUID
//    public var name: String
//    public var creationDate: Date
//    
//    @Relationship(deleteRule: .cascade, inverse: \Box.parentBox)
//    public var subBoxs: [Box]?
//    
//    public var parentBox: Box?
//    
//    @Relationship(deleteRule: .cascade, inverse: \Thought.box)
//    public var thoughts: [Thought]?
//    public init(uuid: UUID, name: String, creationDate: Date, parentBox: Box? = nil) {
//      self.uuid = uuid
//      self.name = name
//      self.creationDate = creationDate
//      self.parentBox = parentBox
//    }
//  }
//  
//  @Model
//  public class Thought {
//    public var uuid: UUID
//    public var box: Box
//    public var title: String
//    public var creationDate: Date
//    public init(uuid: UUID, box: Box, title: String, creationDate: Date) {
//      self.uuid = uuid
//      self.box = box
//      self.title = title
//      self.creationDate = creationDate
//    }
//  }
//}

// TODO: migration plan will be added when first version completed
//public enum MindBoxMigrationPlan: SchemaMigrationPlan {
//  static public var stages: [MigrationStage] {
//    []
//  }
//  public static var schemas: [any VersionedSchema.Type] {
//    [MindBoxSchemaV1.self]
//  }
//  static let migrate
//}
