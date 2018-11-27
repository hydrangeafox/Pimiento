import App
import Vapor

let a = try app(.detect())
try a.asyncRun().flatMap { () -> Future<Void> in
  let console = try a.make(Console.self)
  if console.confirm("When you need graceful quit, answer yes!") {
    print("Shutting down...")
    try a.runningServer?.close().wait()
  }
  try a.runningServer?.onClose.then { () -> Future<Void> in
    return .done(on:a)
  }.wait()
  return .done(on:a)
}.wait()
