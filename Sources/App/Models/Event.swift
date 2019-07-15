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
}

extension Event: Content { }

extension Event: Migration { }
