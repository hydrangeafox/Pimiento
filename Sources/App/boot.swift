import Vapor

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
  let console = try app.make(Console.self)
  let d = 900, t = d - Int(Date.timeIntervalSinceReferenceDate) % d
  app.eventLoop // Sweep on the quarter hour
  .scheduleRepeatedTask(initialDelay:.seconds(t), delay:.seconds(d)) { task in
    app.withPooledConnection(to:.sqlite) { conn in
      UserToken.sweep(on:conn).do { }.catch { err in
        console.report(error:err.localizedDescription, newLine:true)
      }
    }
  }
}
