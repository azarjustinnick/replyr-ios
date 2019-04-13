import Foundation

protocol MessageGateway {
  func addMessage(with spec: MessageSpec, resultHandler: @escaping ResultHandler<Void, Error>)
  func messages(resultHandler: @escaping ResultHandler<[Message], Error>)
}
