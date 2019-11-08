import Fluent
import Vapor

final class LinkedCollection<T>: RouteCollection where T:Pivot,
     T.Left:Parameter, T.Left.ResolvedParameter==Future<T.Left>,
    T.Right:Renderable,
    // Constraints defined in `Fluent.Siblings`
    T.Database:JoinSupporting,
    T.Left.Database==T.Database, T.Right.Database==T.Database {
  func boot(router:Router) {
    router.get() { req -> Future<[T.Right.RenderableContent]> in
      let binder = try req.parameters.next(T.Left.self)
      return binder.flatMap(to:[T.Right].self) {
        try $0.siblings(through:T.self)
              .query(on:req).sort(T.Right.idKey).all()
      }.map(to:[T.Right.RenderableContent].self) {
        $0.map { entity in entity.renderable }
      }
    }
  }
}
