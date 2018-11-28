import Core

extension File {
  func write(on worker:Worker) -> Future<File> {
    return Future.map(on:worker) {
      try self.data.write()
      return self
    }
  }
}
