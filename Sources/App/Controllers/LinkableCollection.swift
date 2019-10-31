import Fluent
import Vapor

final class LinkableCollection<T>: RouteCollection where T:ModifiablePivot,
     T.Left:Parameter,  T.Left.ResolvedParameter==Future<T.Left>,
    T.Right:Parameter, T.Right.ResolvedParameter==Future<T.Right>,
    // Constraints defined in `Fluent.Siblings`
    T.Database:JoinSupporting,
    T.Left.Database==T.Database, T.Right.Database==T.Database {
  func boot(router:Router) {
    router.on(.OPTIONS, at:T.Right.parameter) { req -> Future<Bool> in
      // TODO: This route exists just for our testing!
      let binder = try req.parameters.next(T.Left.self)
      let entity = try req.parameters.next(T.Right.self)
      return flatMap(to:Bool.self, binder,entity) {
        $0.siblings(through:T.self).isAttached($1, on:req)
      }
    }
    router.post(T.Right.parameter) { req -> Future<HTTPStatus> in
      // FIXME: Register this route with access control middlewares!
      let binder = try req.parameters.next(T.Left.self)
      let entity = try req.parameters.next(T.Right.self)
      return flatMap(to:HTTPStatus.self, binder,entity) {
        $0.siblings(through:T.self)
          .attach($1, on:req).transform(to:.created)
      }
    }
    router.delete(T.Right.parameter) { req -> Future<HTTPStatus> in
      // FIXME: Register this route with access control middlewares!
      let binder = try req.parameters.next(T.Left.self)
      let entity = try req.parameters.next(T.Right.self)
      return flatMap(to:HTTPStatus.self, binder,entity) {
        $0.siblings(through:T.self)
          .detach($1, on:req).transform(to:.noContent)
      }
    }
  }
}
