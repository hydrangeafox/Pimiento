import MagickWand
import Vapor

extension ImageWand {
  var contentType: MediaType? {
    guard let format = self.format else { return nil }
    return MediaType.fileExtension(format)
  }
}

extension ImageWand: ResponseEncodable {
  public func encode(for req:Request) throws -> Future<Response> {
    guard let data        = self.data,
          let contentType = self.contentType else {
      throw Abort(.internalServerError)
    }
    return Future.map(on:req) {
      req.makeResponse(data, as:contentType)
    }
  }
}
