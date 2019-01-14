import Authentication
import Crypto
import FluentSQLite

final class User: SQLiteModel {
  var id:       Int?
  var name:     String
  var hashedpw: String

  init(id:Int?=nil, name:String, hashedpw:String) {
    self.id       = id
    self.name     = name
    self.hashedpw = hashedpw
  }
  convenience init(id:Int?=nil, name:String, password:String) throws {
    let hashedpw = try BCrypt.hash(password)
    self.init(id:id, name:name, hashedpw:hashedpw)
  }
}

extension User: PasswordAuthenticatable {
  static var usernameKey: WritableKeyPath<User,String> {
    return \.name
  }
  static var passwordKey: WritableKeyPath<User,String> {
    return \.hashedpw
  }
}

extension User: TokenAuthenticatable {
  typealias TokenType = UserToken
}

extension User: Migration { }
