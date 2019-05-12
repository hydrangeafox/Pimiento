import Core

extension File {
  func write(on worker:Worker) -> Future<File> {
    let promise = worker.eventLoop.newPromise(File.self)
    DispatchQueue.global().async(execute:DispatchWorkItem(qos:.default) {
      do {
        try self.data.write()
        promise.succeed(result:self)
      } catch {
        promise.fail(error:error)
      }
    })
    return promise.futureResult
  }
}
