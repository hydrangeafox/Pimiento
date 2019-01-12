import FluentSQLite

struct SeedUsers: SQLiteMigration {
  static func prepare(on conn:SQLiteConnection) -> Future<Void> {
    return Future.map(on:conn) {
      try User(name:"demifox", password:"topaz").save(on:conn)
    }.transform(to:())
  }
  static func revert(on conn:SQLiteConnection) -> Future<Void> {
    return .done(on:conn)
  }
}
