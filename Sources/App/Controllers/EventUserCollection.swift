import Vapor

final class EventUserCollection: RouteCollection {
  func boot(router:Router) {
    router.post(User.parameter) { req -> Future<HTTPStatus> in
      // FIXME: Register this route with access control middlewares!
      let event = try req.parameters.next(Event.self)
      let user  = try req.parameters.next(User.self)
      return flatMap(to:HTTPStatus.self, event,user) { event,user in
        event.users.attach(user, on:req).transform(to:.created)
      }
    }
    router.get(User.parameter) { req -> Future<Bool> in
      // TODO: This route exists just for our testing!
      let event = try req.parameters.next(Event.self)
      let user  = try req.parameters.next(User.self)
      return flatMap(to:Bool.self, event,user) { event,user in
        event.users.isAttached(user, on:req)
      }
    }
    router.delete(User.parameter) { req -> Future<HTTPStatus> in
      // FIXME: Register this route with access control middlewares!
      let event = try req.parameters.next(Event.self)
      let user  = try req.parameters.next(User.self)
      return flatMap(to:HTTPStatus.self, event,user) { event,user in
        event.users.detach(user, on:req).transform(to:.noContent)
      }
    }
  }
}
