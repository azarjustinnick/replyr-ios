import Foundation

struct HTTPInputHead: Hashable {
  let fields: [HTTPField]
  let method: HTTPInputHeadMethod
  let url: URL
}
