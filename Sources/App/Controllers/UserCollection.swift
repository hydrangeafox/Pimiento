import Vapor

final class UserCollection: RouteCollection {
  func boot(router:Router) {
    router.get() { req -> Future<[User.RenderableContent]> in
      User.query(on:req).sort(User.idKey).all().map {
        $0.map { user in user.renderable }
      }
    }
    router.put(UserManifest.self) { req,manifest -> Future<HTTPStatus> in
      let user = try req.requireAuthenticated(User.self)
      return try user.replace(with:manifest)
                     .save(on:req).transform(to:.noContent)
    }
  }
}
