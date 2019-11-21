import FluentSQLite
import MagickWand
import Vapor

// We use `MagickWand` because it has `ImageWand.autoOrient()`.
// `SwiftGD` is a good alternative because it has filter and drawing
// methods. However we need above feature to support digital cameras.
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

// MARK: - Thumbnail
extension Photo {
  var thumbnails: Children<Photo,Thumbnail> {
    return self.children(\.id)
  }

  // This method ensures that the content has been stored correctly.
  func thumbnail(height h:Double=120.0, quality q:Int=25) -> Thumbnail? {
    if let id    = self.id,
       let image = self.wand()?.thumbnailed(height:h, quality:q).data {
      return Thumbnail(id:id, image:image)
    } else {
      return nil
    }
  }
}

// MARK: - Comment
extension Photo {
  var comments: Children<Photo,Comment> {
    return self.children(\.photoid)
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

extension Photo: Renderable {
  struct RenderableContent: Content {
    let id:       Photo.ID?
    let filename: String
    let ownerid:  User.ID
  }
  var renderable: RenderableContent {
    return RenderableContent(id:id, filename:filename, ownerid:ownerid)
  }
}

extension Photo: Migration { }
extension Photo: Ownership { }
