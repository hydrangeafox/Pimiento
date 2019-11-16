import Fluent
import Vapor

final class ParentalMiddleware<C,P>: Middleware where
    C:Model, C:Parameter, C.ResolvedParameter==Future<C>,
    P:Model, P:Parameter, P.ResolvedParameter==Future<P> {
  let parentKey: KeyPath<C,P.ID>

  init(_ parentKey:KeyPath<C,P.ID>) {
    self.parentKey = parentKey
  }
  func respond(to req:Request, chainingTo next:Responder) throws
      -> Future<Response> {
    let parent = try req.parameters.find(P.self, on:req)
    let child  = try req.parameters.find(C.self, on:req)
    return flatMap(to:Response.self, parent,child) {
      guard try $0.requireID()==$1[keyPath:self.parentKey] else {
        throw Abort(.conflict)
      }
      return try next.respond(to:req)
    }
  }
}
