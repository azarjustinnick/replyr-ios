import Foundation

extension URL {
  init?(scheme: String, host: String, pathComponents: [String]) {
    var components = URLComponents()
    components.scheme = scheme
    components.host = host
    
    guard var url = components.url else {
      return nil
    }
    
    for pathComponent in pathComponents {
      url.appendPathComponent(pathComponent)
    }
    
    self = url
  }
}
