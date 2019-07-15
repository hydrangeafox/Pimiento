import Vapor

final class EventCollection: RouteCollection {
  func boot(router:Router) throws {
    router.post(EventManifest.self) { req,manifest -> Future<Event> in
      guard let userid = try req.requireAuthenticated(User.self).id else {
        throw Abort(.internalServerError)
      }
      return Event(name:manifest.name, ownerid:userid).save(on:req)
    }
  }
}
