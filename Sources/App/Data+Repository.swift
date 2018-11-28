import Crypto
import Vapor

extension Data {
  var digest: String? {
    return try? SHA1.hash(self).base64URLEncodedString()
  }
  func write() throws {
    guard let digest = self.digest else {
      throw Abort(.internalServerError)
    }
    let location = URL.location(digest)
    try self.write(to:location)
  }
}
