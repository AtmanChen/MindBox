import Foundation
import IdentifiedCollections
import Tagged

// public typealias Box = MindBoxSchemaV1.Box
// public typealias Thought = MindBoxSchemaV1.Thought

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

// public struct BoxThemeColor: OptionSet, Identifiable, Codable, Hashable {
//  public var id: Self { self }
//  public let rawValue: Int
//  public init(rawValue: Int) {
//    self.rawValue = rawValue
//  }
//
//  public static let pastel = BoxThemeColor(rawValue: 1 << 0)
//  public static let gold = BoxThemeColor(rawValue: 1 << 1)
//
//  public enum Pastel: Int, CaseIterable, Codable {
//    case lemonSorbet = 0xEADFB4
//    case morningMist = 0x9BB0C1
//    case twilightBlues = 0x51829B
//    case mangoMousse = 0xF6995C
//  }
//
//  public enum Gold: Int, CaseIterable, Codable {
//    case midnightDream = 0x5F0F40
//    case twilightGlow = 0xFB8B24
//    case flamencoFlame = 0xE36414
//    case agateBrown = 0x9A031E
//  }
// }

public enum BoxThemeColor: Identifiable, Codable, CaseIterable, Hashable, CustomStringConvertible {
  public var id: Self { self }

  public enum Pastel: String, CaseIterable, Codable {
    case lemonSorbet = "#EADFB4"
    case morningMist = "#9BB0C1"
    case twilightBlues = "#51829B"
    case mangoMousse = "#F6995C"
  }

  public enum Gold: String, CaseIterable, Codable {
    case midnightDream = "#5F0F40"
    case twilightGlow = "#FB8B24"
    case flamencoFlame = "#E36414"
    case agateBrown = "#9A031E"
  }

  case pastel(Pastel)
  case gold(Gold)

  public var rawValue: String {
    switch self {
    case .pastel(let color):
      return color.rawValue
    case .gold(let color):
      return color.rawValue
    }
  }
  
  public var description: String {
    switch self {
    case .pastel: return "Pastel"
    case .gold: return "Gold"
    }
  }

  public static var allCases: [BoxThemeColor] {
    Pastel.allCases.map {
      .pastel($0)
    } + Gold.allCases.map {
      .gold($0)
    }
  }
  
  public static var sectionCases: [[BoxThemeColor]] {
    [
      Pastel.allCases.map { .pastel($0) },
      Gold.allCases.map { .gold($0) },
    ]
  }
}

public struct Box: Equatable, Identifiable, Codable, Hashable {
  public let id: UUID
  public var name: String = "New Box"
  public var updateDate: Date
  public var parentBoxId: UUID?
  public var color: BoxThemeColor

  public init(id: UUID, updateDate: Date, parentBoxId: UUID? = nil) {
    self.id = id
    self.updateDate = updateDate
    self.parentBoxId = parentBoxId
    self.color = .pastel(.lemonSorbet)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(name)
    hasher.combine(updateDate)
    hasher.combine(parentBoxId)
    hasher.combine(color)
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

// public enum MindBoxSchemaV1: VersionedSchema {
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
// }

// TODO: migration plan will be added when first version completed
// public enum MindBoxMigrationPlan: SchemaMigrationPlan {
//  static public var stages: [MigrationStage] {
//    []
//  }
//  public static var schemas: [any VersionedSchema.Type] {
//    [MindBoxSchemaV1.self]
//  }
//  static let migrate
// }
