import FluentSQLite

protocol LinkableMigration: Pivot, Migration { }

extension LinkableMigration where Self:SQLiteMigration {
  static func prepare(on conn:SQLiteConnection) -> Future<Void> {
    return Database.create(self, on:conn) { builder in
      builder.field(for:idKey, isIdentifier:true)
      builder.field(for:leftIDKey)
      builder.field(for:rightIDKey)
      builder.reference(from:leftIDKey,  to:Left .idKey, onDelete:.cascade)
      builder.reference(from:rightIDKey, to:Right.idKey, onDelete:.cascade)
    }
  }
  static func revert(on conn:SQLiteConnection) ->Future<Void> {
    return Database.delete(self, on:conn)
  }
}
