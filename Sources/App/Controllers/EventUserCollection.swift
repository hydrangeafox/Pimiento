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
  }
}
