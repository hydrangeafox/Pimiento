import Core
import MagickWand

extension ImageWand {
  func scale(width w:Double) {
    let tangent = Double(self.size.height) / Double(self.size.width)
    self.scale(width:w, height:tangent*w)
  }
  func scale(height h:Double) {
    let cotangent = Double(self.size.width) / Double(self.size.height)
    self.scale(width:cotangent*h, height:h)
  }
  func thumbnailed(height h:Double, quality q:Int) -> Self {
    self.scale(height:h)
    self.format      = MediaType.jpeg.subType
    self.compression = CompressionInfo(compression:.jpeg, quality:q)
    return self
  }
}
