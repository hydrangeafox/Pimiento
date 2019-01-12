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
    router.grouped(basic).post("auth") { req -> String in
      let user = try req.requireAuthenticated(User.self)
      return "Hello, \(user.name)!"
    }

    try router.grouped("photos").register(collection:PhotoCollection())
}
