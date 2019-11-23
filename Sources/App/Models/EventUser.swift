import FluentSQLite

final class EventUser: SQLiteModel {
  var id:      Int?
  var eventid: Event.ID
  var userid:  User.ID

  init(id:Int?=nil, eventid:Event.ID, userid:User.ID) {
    self.id      = id
    self.eventid = eventid
    self.userid  = userid
  }
}

extension EventUser: Pivot {
  typealias Left  = Event
  typealias Right = User

  static let leftIDKey:  LeftIDKey  = \.eventid
  static let rightIDKey: RightIDKey = \.userid
}

extension EventUser: ModifiablePivot {
  convenience init(_ event:Left, _ user:Right) throws {
    let eventid = try event.requireID()
    let userid  = try user .requireID()
    self.init(eventid:eventid, userid:userid)
  }
}

extension EventUser: SQLiteMigration, LinkableMigration { }
