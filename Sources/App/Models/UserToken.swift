import Authentication
import FluentSQLite

final class UserToken: SQLiteModel {
  var id:      Int?
  var userid:  User.ID
  var content: String
  var expires: Date

  var valid: Bool {
    return Date() < self.expires
  }

  init(id:Int?=nil, userid:User.ID, content:String, expires:Date) {
    self.id      = id
    self.userid  = userid
    self.content = content
    self.expires = expires
  }
  convenience init?(user:User, uuid:UUID=UUID(), ttl:TimeInterval=3600) {
    guard let userid = user.id else { return nil }
    let expires = Date(timeIntervalSinceNow:ttl)
    self.init(userid:userid, content:uuid.uuidString, expires:expires)
  }
}

extension UserToken {
  static func sweep(on conn:DatabaseConnectable) -> Future<Void> {
    return UserToken.query(on:conn)
                    .filter(\.expires<Date()).delete(force:true)
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
