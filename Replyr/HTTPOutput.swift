import Foundation

struct HTTPOutput: Hashable {
  let body: Data?
  let head: HTTPOutputHead
}
