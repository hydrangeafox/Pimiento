import MagickWand
import Vapor

final class PhotoCollection: RouteCollection {
  func boot(router:Router) throws {
    router.post() { req -> Future<HTTPStatus> in
      return try req.content.decode(FormdataPhoto.self)
       .flatMap(to:File.self) { formdata in
        formdata.image.write(on:req)
      }.flatMap(to:Photo.self) { file in
        guard let user  = try req.authenticated(User.self),
              let photo = Photo(file:file, by:user) else {
          throw Abort(.internalServerError)
        }
        return photo.create(on:req)
      }.flatMap(to:Thumbnail.self) { photo in
        guard let thumbnail = photo.thumbnail() else {
          throw Abort(.internalServerError)
        }
        return thumbnail.create(on:req)
      }.transform(to:.created)
    }
    router.get(Photo.parameter) { req -> Future<ImageWand> in
      let photo = try req.parameters.next(Photo.self)
      return photo.map(to:ImageWand.self) {
        guard let wand = $0.wand(), wand.autoOrient() else {
          throw Abort(.internalServerError)
        }
        if let width = req.query[Double.self, at:"width"] {
          wand.scale(width:width)
        }
        // We don't use optional chain because we need to separate
        // response status for each causes.
        let mediaType = req.http.headers.accept(for:"image").first
                     ?? MediaType.jpeg
        wand.format = mediaType.subType
        return wand
      }
    }
    router.get(
        Photo.parameter,"thumbnail") { req -> Future<Thumbnail> in
      let photo = try req.parameters.next(Photo.self)
      return photo.flatMap(to:Thumbnail.self) {
        try $0.thumbnails.query(on:req).first().unwrap(or:Abort(.notFound))
      }
    }
    router.get(
        Photo.parameter,"download") { req -> Future<DownloadableContent> in
      let photo = try req.parameters.next(Photo.self)
      return photo.map(to:DownloadableContent.self) { $0.packet() }
    }
  }
}
