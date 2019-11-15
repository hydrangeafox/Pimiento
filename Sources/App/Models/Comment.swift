import FluentSQLite
import Vapor

final class Comment: SQLiteModel {
  var id:      Int?
  var message: String
  var photoid: Photo.ID
  var ownerid: User.ID

  init(id:Int?=nil, message:String, photoid:Photo.ID, ownerid:User.ID) {
    self.id      = id
    self.message = message
    self.photoid = photoid
    self.ownerid = ownerid
  }
}

extension Comment: Content { }
extension Comment: Migration { }
extension Comment: Ownership { }
