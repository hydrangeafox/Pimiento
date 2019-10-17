import FluentSQLite
import Vapor

final class Event: SQLiteModel {
  var id:      Int?
  var name:    String
  var ownerid: User.ID

  init(id:Int?=nil, name:String, ownerid:User.ID) {
    self.id      = id
    self.name    = name
    self.ownerid = ownerid
  }
  func replace(with content:EventManifest) -> Event {
    self.name = content.name
    return self
  }
}

extension Event: Parameter {
  typealias ResolvedParameter = Future<Event>

  static func resolveParameter(
      _ param:String, on container:Container) throws -> ResolvedParameter {
    guard let id = Int(param) else { throw Abort(.badRequest) }
    return container.withPooledConnection(to:.sqlite) { conn in
      return Event.find(id, on:conn).unwrap(or:Abort(.notFound))
    }
  }
}

extension Event: Content { }

extension Event: Migration { }
