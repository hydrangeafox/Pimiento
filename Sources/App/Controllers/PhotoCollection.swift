import MagickWand
import Vapor

final class PhotoCollection: RouteCollection {
  func boot(router:Router) throws {
    router.post() { req -> Future<HTTPStatus> in
      return try req.content.decode(FormdataPhoto.self)
       .flatMap(to:File.self) { formdata in
        formdata.image.write(on:req)
      }.flatMap(to:Photo.self) { file in
        guard let photo = Photo(file:file) else {
          throw Abort(.internalServerError)
        }
        return photo.create(on:req)
      }.transform(to:.created)
    }
    router.get(Int.parameter) { req -> Future<ImageWand> in
      let id = try req.parameters.next(Int.self)
      return try Photo.find(id, on:req).map(to:ImageWand.self) {
        guard let photo = $0 else { throw Abort(.notFound) }
        guard let wand  = photo.wand() else {
          throw Abort(.internalServerError)
        }
        // We don't use optional chain because we need to separate
        // response status for each causes.
        let mediaType = req.http.headers.accept(for:"image").first
                     ?? MediaType.jpeg
        wand.format = mediaType.subType
        return wand
      }
    }
    router.get(Int.parameter,"download") {
               req -> Future<DownloadableContent> in
      let id = try req.parameters.next(Int.self)
      return try Photo.find(id, on:req).map(to:DownloadableContent.self) {
        guard let content = $0?.packet() else { throw Abort(.notFound) }
        return content
      }
    }
  }
}
