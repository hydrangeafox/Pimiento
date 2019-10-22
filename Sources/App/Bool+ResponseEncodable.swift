import Vapor

// TODO: This extension exists just for our testing!
extension Bool: ResponseEncodable {
  public func encode(for req:Request) -> Future<Response> {
    return Future.map(on:req) {
      req.response(self.description)
    }
  }
}
