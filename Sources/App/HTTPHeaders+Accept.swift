import HTTP

extension HTTPHeaders {
  var accept:[MediaType] {
    return self[canonicalForm:HTTPHeaderName.accept.description]
      .compactMap(MediaType.parse)
  }
  func accept(for type:String) -> [MediaType] {
    return self.accept.filter { $0.type == type }
  }
}
