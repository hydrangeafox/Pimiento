import FluentSQLite

final class EventPhoto: SQLiteModel {
  var id:      Int?
  var eventid: Event.ID
  var photoid: Photo.ID

  init(id:Int?=nil, eventid:Event.ID, photoid:Photo.ID) {
    self.id      = id
    self.eventid = eventid
    self.photoid = photoid
  }
}

extension EventPhoto: Pivot {
  typealias Left  = Event
  typealias Right = Photo

  static let leftIDKey:  LeftIDKey  = \.eventid
  static let rightIDKey: RightIDKey = \.photoid
}

extension EventPhoto: ModifiablePivot {
  convenience init(_ event:Left, _ photo:Right) throws {
    let eventid = try event.requireID()
    let photoid = try photo.requireID()
    self.init(eventid:eventid, photoid:photoid)
  }
}

extension EventPhoto: SQLiteMigration {
  static func prepare(on conn:SQLiteConnection) -> Future<Void> {
    return Database.create(self, on:conn) { builder in
      builder.field(for:idKey, isIdentifier:true)
      builder.field(for:leftIDKey)
      builder.field(for:rightIDKey)
      builder.reference(from:leftIDKey,  to:Left .idKey, onDelete:.cascade)
      builder.reference(from:rightIDKey, to:Right.idKey, onDelete:.cascade)
    }
  }
  static func revert(on conn:SQLiteConnection) ->Future<Void> {
    return Database.delete(self, on:conn)
  }
}
