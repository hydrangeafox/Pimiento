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

extension EventPhoto: Migration { }
