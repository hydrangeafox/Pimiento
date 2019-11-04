import Vapor

final class OwnershipMiddleware<P>: Middleware
    where P:Parameter, P:Ownership, P.ResolvedParameter==Future<P> {
  func respond(to req:Request, chainingTo next:Responder) throws
      -> Future<Response> {
    let entity = try req.parameters.find(P.self, on:req)
    return entity.flatMap(to:Response.self) {
      guard try $0.isOwned(by:req) else { throw Abort(.forbidden) }
      return try next.respond(to:req)
    }
  }
}

extension OwnershipMiddleware: ServiceType {
  public static func makeService(for _:Container) -> OwnershipMiddleware {
    return OwnershipMiddleware()
  }
}
