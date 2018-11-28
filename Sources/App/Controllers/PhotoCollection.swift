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
  }
}
