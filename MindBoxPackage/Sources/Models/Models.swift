import Foundation
import IdentifiedCollections
import Tagged
import Utils
import Dependencies

// public typealias Box = MindBoxSchemaV1.Box
// public typealias Thought = MindBoxSchemaV1.Thought

public enum MindBoxSelectionUpdate: Hashable {
  case box(boxIdString: String?)
  case thought(thoughtIdString: String?)
}

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
  static let keywords = Self.documentsDirectory.appending(component: "keywords.json")
}

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

public enum KeywordThemeColor: String, Identifiable, Codable, CaseIterable, Hashable {
  public var id: Self { self }
  
  case royalPurple = "#5E1675"
  case coralRed = "#EE4266"
  case sunshineYellow = "#FFD23F"
  case forestGreen = "#337357"
  
}

public struct Box: Equatable, Identifiable, Codable, Hashable {
  public let id: UUID
  public var name: String = "New Box"
  public var updateDate: Date
  public var parentBoxId: UUID?
  public var color: BoxThemeColor
  public var expanded: Bool = false

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
    hasher.combine(expanded)
  }
  
  #if DEBUG
  public static var examples: [Box] = [
    Box(id: UUID(0), updateDate: Date(), parentBoxId: nil),
    Box(id: UUID(1), updateDate: Date(), parentBoxId: UUID(0)),
    Box(id: UUID(2), updateDate: Date(), parentBoxId: UUID(3)),
    Box(id: UUID(3), updateDate: Date(), parentBoxId: UUID(0)),
    Box(id: UUID(4), updateDate: Date(), parentBoxId: UUID(1)),
  ]
  #endif
}

public enum Status: Identifiable, CaseIterable, Codable, CustomStringConvertible, Hashable {
  case active
  case archived
  case custom(String)

  public var id: Self { self }
  public var description: String {
    switch self {
    case .active: return "ACTIVE"
    case .archived: return "ARCHIVED"
    case .custom(let status): return status.uppercased()
    }
  }
  public static var allCases: [Status] {
    [.active, .archived, .custom("自定义")]
  }
  public var systemImageName: String {
    switch self {
    case .active: return "checkmark.circle"
    case .archived: return "archivebox"
    case .custom: return "star"
    }
  }
}

public struct Thought: Equatable, Identifiable, Codable, Hashable {
  public let id: UUID
  public var boxId: UUID
  public var title: String
  public var body: String
  public var updateDate: Date
  public var status: Status
  public var formattedBody: Data?
  public var keywords: [Keyword] = []

  public init(
    id: UUID,
    boxId: UUID,
    title: String = "New Thought",
    body: String = "Handle your thought",
    updateDate: Date,
    status: Status = .active
  ) {
    self.id = id
    self.boxId = boxId
    self.title = title
    self.body = body
    self.updateDate = updateDate
    self.status = status
    self.formattedBody = NSAttributedString(string: body).toData()
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(boxId)
    hasher.combine(title)
    hasher.combine(body)
    hasher.combine(updateDate)
    hasher.combine(status)
    hasher.combine(formattedBody)
    hasher.combine(keywords)
  }
  
  public var formattedBodyText: NSAttributedString {
    get {
      formattedBody?.toAttributedString() ?? NSAttributedString(string: "")
    }
    set {
      formattedBody = newValue.toData()
      body = newValue.string.lowercased()
    }
  }
  #if DEBUG
  public static var examples: [Thought] = [
    Thought(id: UUID(10), boxId: UUID(0), updateDate: Date()),
    Thought(id: UUID(11), boxId: UUID(0), updateDate: Date()),
    Thought(id: UUID(12), boxId: UUID(0), updateDate: Date()),
    Thought(id: UUID(13), boxId: UUID(0), updateDate: Date()),
    Thought(id: UUID(14), boxId: UUID(0), updateDate: Date()),
    Thought(id: UUID(15), boxId: UUID(1), updateDate: Date()),
    Thought(id: UUID(16), boxId: UUID(2), updateDate: Date()),
    Thought(id: UUID(17), boxId: UUID(3), updateDate: Date()),
    Thought(id: UUID(18), boxId: UUID(4), updateDate: Date()),
  ]
  #endif
}

public struct Keyword: Equatable, Identifiable, Codable, Hashable {
  public let id: UUID
  public let name: String
  public let color: KeywordThemeColor
  public var thoughtIds: [UUID]
  public var expanded: Bool = false
  
  public init(
    id: UUID,
    name: String,
    color: KeywordThemeColor,
    thoughtIds: [UUID]
  ) {
    self.id = id
    self.name = name
    self.color = color
    self.thoughtIds = thoughtIds
  }
  
  #if DEBUG
  public static var examples: [Keyword] = [
    Keyword(
      id: UUID(20),
      name: "L.O.L",
      color: .coralRed,
      thoughtIds: [
        UUID(10),
        UUID(13),
        UUID(16),
        UUID(11),
        UUID(18),
      ]
    ),
    Keyword(
      id: UUID(21),
      name: "Dota2",
      color: .royalPurple,
      thoughtIds: [
        UUID(12),
        UUID(14),
        UUID(15),
        UUID(18),
      ]
    ),
  ]
  #endif
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
