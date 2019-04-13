import Foundation

struct Message: Codable {
  let text: String
  let timestamp: Date
  let username: String
}
