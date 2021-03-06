import Vapor

final class EventCollection: RouteCollection {
  func boot(router:Router) throws {
    let invited = router.grouped(MembershipMiddleware<EventUser>.self)
    let owned   = router.grouped(OwnershipMiddleware<Event>.self)
    router.post(EventManifest.self) { req,manifest -> Future<Event> in
      guard let userid = try req.requireAuthenticated(User.self).id else {
        throw Abort(.internalServerError)
      }
      return Event(name:manifest.name, ownerid:userid).save(on:req)
    }
    router.get() { req -> Future<[Event]> in
      try req.requireAuthenticated(User.self).events
             .query(on:req).sort(\.id).all()
    }
    invited.get(Event.parameter) { req -> Future<Event> in
      try req.parameters.next(Event.self)
    }
    owned.put(
        EventManifest.self, at:Event.parameter) { req,mf -> Future<Event> in
      try req.parameters.next(Event.self).flatMap(to:Event.self) {
        $0.replace(with:mf).save(on:req)
      }
    }
    owned.delete(Event.parameter) { req -> Future<HTTPStatus> in
      try req.parameters.next(Event.self)
        .flatMap { $0.delete(force:true, on:req) }
        .transform(to:.noContent)
    }
  }
}
