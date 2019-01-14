import Authentication
import FluentSQLite

final class UserToken: SQLiteModel {
  var id:      Int?
  var userid:  User.ID
  var content: String

  init(id:Int?=nil, userid:User.ID, content:String) {
    self.id      = id
    self.userid  = userid
    self.content = content
  }
  convenience init?(user:User, uuid:UUID=UUID()) {
    guard let userid = user.id else { return nil }
    self.init(userid:userid, content:uuid.uuidString)
  }
}

extension UserToken: Token {
  typealias UserType = User

  static var tokenKey: WritableKeyPath<UserToken,String> {
    return \.content
  }
  static var userIDKey: WritableKeyPath<UserToken,User.ID> {
    return \.userid
  }
}

extension UserToken: Migration { }
