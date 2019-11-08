import Authentication
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)

    // Endpoint for Basic Authentication
    let basic = User.basicAuthMiddleware(using:BCryptDigest())
    router.grouped(basic).post("auth") { req -> Future<String> in
      let user = try req.requireAuthenticated(User.self)
      guard let token = UserToken(user:user) else {
        throw Abort(.internalServerError)
      }
      return token.save(on:req).map(to:String.self) { $0.content }
    }

    // Endpoint for Bearer Authentication
    let bearer = User.tokenAuthMiddleware()
    router.grouped(bearer).delete("auth") { req -> Future<HTTPStatus> in
      let token = try req.requireAuthenticated(User.TokenType.self)
      let _     = try req.requireAuthenticated(User.self)
      try req.unauthenticate(User.self)
      try req.unauthenticate(User.TokenType.self)
      return token.delete(force:true, on:req).transform(to:.noContent)
    }

    // Endpoint for our main contents
    let guardian = User.guardAuthMiddleware()
    let signed   = router.grouped(bearer,guardian)
    let owned    = signed.grouped(OwnershipMiddleware<Event>.self)
    try signed.grouped("photos").register(collection:PhotoCollection())
    try signed.grouped("events").register(collection:EventCollection())
    try signed.grouped("events",Event.parameter,"users")
              .register(collection:LinkedCollection<EventUser>())
    try signed.grouped("events",Event.parameter,"photos")
              .register(collection:LinkedCollection<EventPhoto>())
    try owned .grouped("events",Event.parameter,"users")
              .register(collection:LinkableCollection<EventUser>())
    try owned .grouped(OwnershipMiddleware<Photo>.self)
              .grouped("events",Event.parameter,"photos")
              .register(collection:LinkableCollection<EventPhoto>())

    // TODO: This route exists just for our testing!
    signed
    .grouped(MembershipMiddleware<EventUser>.self)
    .grouped(EntityMiddleware<EventPhoto>.self)
    .grouped("events",Event.parameter)
        .get("photos",Photo.parameter) { req -> Future<DownloadableContent> in
      let _     = try req.parameters.next(Event.self)
      let photo = try req.parameters.next(Photo.self)
      return photo.map(to:DownloadableContent.self) { $0.packet() }
    }
}
