import Vapor

extension ParametersContainer {
  func find<P>(_:P.Type, on container:Container) throws
      -> P.ResolvedParameter where P:Parameter {
    guard let id = self.rawValues(for:P.self).first else {
      throw Abort(.internalServerError)
    }
    return try P.resolveParameter(id, on:container)
  }
}
