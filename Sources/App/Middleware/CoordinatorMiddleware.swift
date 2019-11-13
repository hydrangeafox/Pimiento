import Authentication
import Fluent
import Vapor

final class CoordinatorMiddleware<M,E>: Middleware where M:Pivot, E:Pivot,
    M.Left==E.Left,
    M.Right:Authenticatable,
    E.Right:Parameter, E.Right.ResolvedParameter==Future<E.Right>,
    // Constraints defined in `Fluent.Siblings`
    M.Database:JoinSupporting,
    M.Left.Database==M.Database, M.Right.Database==M.Database,
    E.Left.Database==E.Database, E.Right.Database==E.Database {
  func respond(to req:Request, chainingTo next:Responder) throws
      -> Future<Response> {
    let user   = try req.requireAuthenticated(M.Right.self)
    let entity = try req.parameters.find(E.Right.self, on:req)
    return entity.flatMap(to:Int.self) {
      guard let uid = user[keyPath:M.Right.idKey],
            let eid =   $0[keyPath:E.Right.idKey] else {
        throw Abort(.internalServerError)
      }
      return M.query(on:req).join(E.leftIDKey, to:M.leftIDKey)
              .filter(M.rightIDKey==uid)
              .filter(E.rightIDKey==eid)
              .count()
    }.flatMap(to:Response.self) {
      guard $0 > 0 else { throw Abort(.forbidden) }
      return try next.respond(to:req)
    }
  }
}

extension CoordinatorMiddleware: ServiceType {
  public static func makeService(for worker:Container) throws
      -> CoordinatorMiddleware {
    return CoordinatorMiddleware()
  }
}
