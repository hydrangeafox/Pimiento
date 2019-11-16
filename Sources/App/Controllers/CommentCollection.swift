import Vapor

final class CommentCollection: RouteCollection {
  // We mount a route as `/photos/:pid/comments/:cid` but not a form of
  // `/comments/:cid?photoid=XXX`. Because
  // - Continue to use the `CoordinatorMiddleware`
  // - We may introduce a composite key on the `Comment` model
  func boot(router:Router) {
    let parental
      = router.grouped(ParentalMiddleware<Comment,Photo>(\.photoid))
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
    parental.put(CommentManifest.self, at:Comment.parameter) { req,manifest
        -> Future<Comment> in
      let _       = try req.parameters.next(Photo.self)
      let comment = try req.parameters.next(Comment.self)
      return comment.flatMap(to:Comment.self) {
        $0.replace(with:manifest).save(on:req)
      }
    }
    parental.delete(Comment.parameter) { req -> Future<HTTPStatus> in
      let _       = try req.parameters.next(Photo.self)
      let comment = try req.parameters.next(Comment.self)
      return comment.flatMap(to:HTTPStatus.self) {
        $0.delete(force:true, on:req).transform(to:.noContent)
      }
    }
  }
}
