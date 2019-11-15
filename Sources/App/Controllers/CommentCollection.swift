import Vapor

final class CommentCollection: RouteCollection {
  func boot(router:Router) {
    router.post(CommentManifest.self) { req,manifest -> Future<Comment> in
      let user  = try req.requireAuthenticated(User.self)
      let photo = try req.parameters.next(Photo.self)
      return photo.flatMap(to:Comment.self) {
        let (uid,pid) = try (user.requireID(),$0.requireID())
        return Comment(message:manifest.message, photoid:pid, ownerid:uid)
               .save(on:req)
      }
    }
    router.get() { req -> Future<[Comment]> in
      let photo = try req.parameters.next(Photo.self)
      return photo.flatMap(to:[Comment].self) {
        try $0.comments.query(on:req).sort(\.id).all()
      }
    }
  }
}
