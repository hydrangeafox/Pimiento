import FluentSQLite

final class Favorite: SQLiteModel {
  var id:      Int?
  var userid:  User.ID
  var photoid: Photo.ID

  init(id:Int?=nil, userid:User.ID, photoid:Photo.ID) {
    self.id      = id
    self.userid  = userid
    self.photoid = photoid
  }
}

extension Favorite: Pivot {
  typealias Left  = User
  typealias Right = Photo

  static let leftIDKey:  LeftIDKey  = \.userid
  static let rightIDKey: RightIDKey = \.photoid
}

extension Favorite: ModifiablePivot {
  convenience init(_ user:Left, _ photo:Right) throws {
    let userid  = try user .requireID()
    let photoid = try photo.requireID()
    self.init(userid:userid, photoid:photoid)
  }
}

extension Favorite: Migration { }
