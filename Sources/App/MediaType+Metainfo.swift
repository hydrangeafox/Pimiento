import Core

extension MediaType {
  static func filename(_ fname:String) -> MediaType? {
    let url = URL(fileURLWithPath:fname, isDirectory:false)
    return MediaType.fileExtension(url.pathExtension)
  }
}
