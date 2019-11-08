import Vapor

protocol Renderable {
  associatedtype RenderableContent: Content
  var renderable:RenderableContent { get }
}
