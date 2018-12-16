import Vapor

struct DownloadableContent {
  let location: URL
  let filename: String

  var contentType: MediaType? {
    return MediaType.filename(self.filename)
  }
  var contentDisposition: String {
    return "attachment; filename=\"\(self.filename)\""
  }
}

extension DownloadableContent: ResponseEncodable {
  func encode(for req:Request) throws -> Future<Response> {
    guard let contentType = self.contentType else {
      throw Abort(.internalServerError)
    }
    return Future.map(on:req) {
      let reader = try req.fileio().chunkedStream(file:self.location.path)
      let res    = req.response(reader, as:contentType)
      res.http.headers.replaceOrAdd(
        name:.contentDisposition, value:self.contentDisposition
      )
      return res
    }
  }
}
