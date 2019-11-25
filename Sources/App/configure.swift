import Authentication
import FluentSQLite
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Accept uploading higher quality photos
    services.register(NIOServerConfig.default(maxBodySize:5_000_000))

    /// Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(AuthenticationProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    services.register(OwnershipMiddleware<Event>.self)
    services.register(OwnershipMiddleware<Photo>.self)
    services.register(OwnershipMiddleware<Comment>.self)
    services.register(MembershipMiddleware<EventUser>.self)
    services.register(EntityMiddleware<EventPhoto>.self)
    services.register(CoordinatorMiddleware<EventUser,EventPhoto>.self)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage:env == .development
               ? .memory : .file(path:"\(URL.home)/pimiento.db")
    )

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    databases.appendConfigurationHandler(on:.sqlite) { conn in
      conn.query("PRAGMA foreign_keys=ON").transform(to:())
    }
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model:User.self,      database:.sqlite)
    migrations.add(model:UserToken.self, database:.sqlite)
    migrations.add(model:Todo.self,      database:.sqlite)
    migrations.add(model:Event.self,     database:.sqlite)
    migrations.add(model:EventUser.self, database:.sqlite)
    migrations.add(model:EventPhoto.self,database:.sqlite)
    migrations.add(model:Favorite.self,  database:.sqlite)
    migrations.add(model:Comment.self,   database:.sqlite)
    migrations.add(model:Photo.self,     database:.sqlite)
    migrations.add(model:Thumbnail.self, database:.sqlite)
    migrations.add(migration:SeedUsers.self, database:.sqlite)
    services.register(migrations)

}
