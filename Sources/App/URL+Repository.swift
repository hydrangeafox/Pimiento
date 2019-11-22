import Foundation
import Service

extension URL {
  static let home = Environment.get("PIMIENTO_HOME")
                 ?? "/var/lib/pimiento"
  static let repository = URL(
    fileURLWithPath:"\(URL.home)/repository", isDirectory:true
  )
  static func +(_ left:URL, _ right:String) -> URL {
    return left.appendingPathComponent(right, isDirectory:false)
  }
  static func location(_ digest:String) -> URL {
    return URL.repository + digest
  }
}
