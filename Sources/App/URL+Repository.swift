import Foundation

extension URL {
  static var repository = URL(
    fileURLWithPath:"/Users/demifox/Pictures/Pimiento", isDirectory:true
  )
  static func +(_ left:URL, _ right:String) -> URL {
    return left.appendingPathComponent(right, isDirectory:false)
  }
  static func location(_ digest:String) -> URL {
    return URL.repository + digest
  }
}
