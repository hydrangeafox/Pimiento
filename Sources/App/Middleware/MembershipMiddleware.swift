import Authentication
import Fluent
import Vapor

final class MembershipMiddleware<T>: Middleware where T:Pivot,
     T.Left:Parameter, T.Left.ResolvedParameter==Future<T.Left>,
    T.Right:Authenticatable,
    // Constraints defined in `Fluent.Siblings`
    T.Database:JoinSupporting,
    T.Left.Database==T.Database, T.Right.Database==T.Database {
  func respond(to req:Request, chainingTo next:Responder) throws
      -> Future<Response> {
    let binder = try req.parameters.find(T.Left.self, on:req)
    return binder.flatMap(to:Bool.self) {
      let user = try req.requireAuthenticated(T.Right.self)
      return $0.siblings(through:T.self).isAttached(user, on:req)
    }.flatMap(to:Response.self) { invited in
      guard invited else { throw Abort(.forbidden) }
      return try next.respond(to:req)
    }
  }
}

extension MembershipMiddleware: ServiceType {
  public static func makeService(for worker:Container) throws
      -> MembershipMiddleware {
    return MembershipMiddleware()
  }
}
