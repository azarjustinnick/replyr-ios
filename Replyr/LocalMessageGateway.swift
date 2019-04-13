import Foundation

class LocalMessageGateway: MessageGateway {
  init() {
    self.messages = [Message]()
    self.queue = DispatchQueue(label: "LocalMessageGateway")
  }
  
  private var messages: [Message]
  private let queue: DispatchQueue
  
  func addMessage(with spec: MessageSpec, resultHandler: @escaping ResultHandler<Void, Error>) {
    queue.async {
      let message = Message(
        text: spec.text,
        timestamp: Date(),
        username: spec.username
      )
      
      self.messages.append(message)
      let result = Result<Void, Error>.success(())
      resultHandler(result)
    }
  }
  
  func messages(resultHandler: @escaping ResultHandler<[Message], Error>) {
    queue.async {
      let result = Result<[Message], Error>.success(self.messages)
      resultHandler(result)
    }
  }
}
