import Foundation

struct HTTPOutputHead: Hashable {
  let fields: [HTTPField]
  let statusCode: Int
  let url: URL
  let version: String?
}
