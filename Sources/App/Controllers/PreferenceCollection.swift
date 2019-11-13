import Authentication
import Fluent
import Vapor

final class PreferenceCollection<T>: RouteCollection where T:ModifiablePivot,
     T.Left:Authenticatable,
    T.Right:Parameter, T.Right.ResolvedParameter==Future<T.Right>,
    // Constraints defined in `Fluent.Siblings`
    T.Database:JoinSupporting,
    T.Left.Database==T.Database, T.Right.Database==T.Database {
  func boot(router:Router) {
    router.post(T.Right.parameter) { req -> Future<HTTPStatus> in
      // FIXME: Register this route with access control middlewares!
      let user   = try req.requireAuthenticated(T.Left.self)
      let entity = try req.parameters.next(T.Right.self)
      return entity.flatMap(to:HTTPStatus.self) {
        user.siblings(through:T.self)
            .attach($0, on:req).transform(to:.created)
      }
    }
  }
}
