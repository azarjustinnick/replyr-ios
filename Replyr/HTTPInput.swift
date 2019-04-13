import Foundation

struct HTTPInput: Hashable {
  init(body: Data?, head: HTTPInputHead) {
    self.body = body
    self.head = head
  }
  
  let body: Data?
  let head: HTTPInputHead
}
