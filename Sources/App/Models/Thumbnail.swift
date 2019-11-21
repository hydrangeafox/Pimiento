import FluentSQLite

final class Thumbnail: SQLiteModel {
  var id:    Int?
  var image: Data

  init(id:Int?=nil, image:Data) {
    self.id    = id
    self.image = image
  }
}

extension Thumbnail: Migration { }
