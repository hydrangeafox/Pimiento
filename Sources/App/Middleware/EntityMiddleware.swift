import Fluent
import Vapor

final class EntityMiddleware<T>: Middleware where T:Pivot,
     T.Left:Parameter,  T.Left.ResolvedParameter==Future<T.Left>,
    T.Right:Parameter, T.Right.ResolvedParameter==Future<T.Right>,
    // Constraints defined in `Fluent.Siblings`
    T.Database:JoinSupporting,
    T.Left.Database==T.Database, T.Right.Database==T.Database {
  func respond(to req:Request, chainingTo next:Responder) throws
      -> Future<Response> {
    let binder = try req.parameters.find(T.Left.self,  on:req)
    let entity = try req.parameters.find(T.Right.self, on:req)
    return flatMap(to:Bool.self, binder,entity) {
      $0.siblings(through:T.self).isAttached($1, on:req)
    }.flatMap(to:Response.self) { bound in
      guard bound else { throw Abort(.forbidden) }
      return try next.respond(to:req)
    }
  }
}

extension EntityMiddleware: ServiceType {
  public static func makeService(for worker:Container) throws
      -> EntityMiddleware {
    return EntityMiddleware()
  }
}
