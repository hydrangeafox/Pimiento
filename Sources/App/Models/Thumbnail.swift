import FluentSQLite
import Vapor

final class Thumbnail: SQLiteModel {
  var id:    Int?
  var image: Data

  init(id:Int?=nil, image:Data) {
    self.id    = id
    self.image = image
  }
}

extension Thumbnail: ResponseEncodable {
  public func encode(for req:Request) throws -> Future<Response> {
    return Future.map(on:req) {
      req.response(self.image, as:.jpeg)
    }
  }
}

extension Thumbnail: Migration { }
