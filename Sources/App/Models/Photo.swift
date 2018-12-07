import FluentSQLite
import MagickWand

final class Photo: SQLiteModel {
  var id:       Int?
  var digest:   String
  var filename: String

  var location: URL {
    return URL.location(self.digest)
  }

  init(id:Int? = nil, digest:String, filename:String) {
    self.id       = id
    self.digest   = digest
    self.filename = filename
  }
  convenience init?(file:File) {
    guard let digest = file.data.digest else { return nil }
    self.init(digest:digest, filename:file.filename)
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

extension Photo: Migration { }
