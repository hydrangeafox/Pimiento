import FluentSQLite

struct SeedUsers: SQLiteMigration {
  static func prepare(on conn:SQLiteConnection) -> Future<Void> {
    do {
      let root = try User(name:"root",    password:"diamond")
      let me   = try User(name:"demifox", password:"topaz")
      return root.save(on:conn).and(me.save(on:conn)).transform(to:())
    } catch {
      return conn.eventLoop.newFailedFuture(error:error)
    }
  }
  static func revert(on conn:SQLiteConnection) -> Future<Void> {
    return .done(on:conn)
  }
}
