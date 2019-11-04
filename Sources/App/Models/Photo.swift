import FluentSQLite
import MagickWand
import Vapor

final class Photo: SQLiteModel {
  var id:       Int?
  var digest:   String
  var filename: String
  var ownerid:  User.ID

  var location: URL {
    return URL.location(self.digest)
  }

  init(id:Int?=nil, digest:String, filename:String, ownerid:User.ID) {
    self.id       = id
    self.digest   = digest
    self.filename = filename
    self.ownerid  = ownerid
  }
  convenience init?(file:File, by owner:User) {
    guard let digest = file.data.digest,
          let uid    = owner.id else {
      return nil
    }
    self.init(digest:digest, filename:file.filename, ownerid:uid)
  }
  func wand() -> ImageWand? {
    return ImageWand(filePath:self.location.path)
  }
  func packet() -> DownloadableContent {
    return DownloadableContent(
      location:self.location, filename:self.filename
    )
  }
}

extension Photo: Parameter {
  typealias ResolvedParameter = Future<Photo>

  static func resolveParameter(
      _ param:String, on container:Container) throws -> ResolvedParameter {
    guard let id = Int(param) else { throw Abort(.badRequest) }
    return container.withPooledConnection(to:.sqlite) { conn in
      Photo.find(id, on:conn).unwrap(or:Abort(.notFound))
    }
  }
}

extension Photo: Migration { }
extension Photo: Ownership { }
