import Authentication
import Fluent
import Vapor

final class PreferenceCollection<T>: RouteCollection where T:ModifiablePivot,
     T.Left:Authenticatable, T.Left:Renderable,
    T.Right:Parameter, T.Right.ResolvedParameter==Future<T.Right>,
    // Constraints defined in `Fluent.Siblings`
    T.Database:JoinSupporting,
    T.Left.Database==T.Database, T.Right.Database==T.Database {
  func boot(router:Router) {
    let target = String(describing:T.self).lowercased()
    router.post(T.Right.parameter,target) { req -> Future<HTTPStatus> in
      // FIXME: Register this route with access control middlewares!
      let user   = try req.requireAuthenticated(T.Left.self)
      let entity = try req.parameters.next(T.Right.self)
      return entity.flatMap(to:HTTPStatus.self) {
        user.siblings(through:T.self)
            .attach($0, on:req).transform(to:.created)
      }
    }
    router.get(T.Right.parameter,target) {
        req -> Future<[T.Left.RenderableContent]> in
      // FIXME: Register this route with access control middlewares!
      let entity = try req.parameters.next(T.Right.self)
      return entity.flatMap(to:[T.Left].self) {
        try $0.siblings(through:T.self)
              .query(on:req).sort(T.Left.idKey).all()
      }.map(to:[T.Left.RenderableContent].self) {
        $0.map { user in user.renderable }
      }
    }
    router.delete(T.Right.parameter,target) { req -> Future<HTTPStatus> in
      // FIXME: Register this route with access control middlewares!
      let user   = try req.requireAuthenticated(T.Left.self)
      let entity = try req.parameters.next(T.Right.self)
      return entity.flatMap(to:HTTPStatus.self) {
        user.siblings(through:T.self)
            .detach($0, on:req).transform(to:.noContent)
      }
    }
  }
}
