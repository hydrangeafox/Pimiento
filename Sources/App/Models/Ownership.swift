import Vapor

protocol Ownership {
  var ownerid: User.ID { get }
}

extension Ownership {
  func isOwned(by req:Request) throws -> Bool {
    let uid = try req.requireAuthenticated(User.self).requireID()
    return self.ownerid==uid
  }
}
