import Foundation

class RemoteChannelGateway: ChannelGateway {
  init?(name: String) {
    guard let url = URL(scheme: "https", host: "replyr.herokuapp.com", pathComponents: ["chat", "channel", name]) else {
      return nil
    }
    
    self.url = url
  }
  
  private let url: URL
  
  func addMessage(with spec: MessageSpec, resultHandler: @escaping ResultHandler<Void, Error>) {
    DispatchQueue.global().async {
      do {
        let httpInput = HTTPInput(
          body: try JSONEncoder().encode(spec),
          head: HTTPInputHead(
            fields: [
              HTTPField(
                name: "Content-Type",
                value: "application/json"
              )
            ],
            method: .post,
            url: self.url.appendingPathComponent("message")
          )
        )
        
        URLSession.shared.httpOutput(withHTTPInput: httpInput) { result in
          do {
            let httpOutput = try result.get()
            
            switch httpOutput.head.statusCode {
            case 201:
              let result = Result<Void, Error>.success(())
              resultHandler(result)
            default:
              throw MessageGatewayError.invalidStatusCode
            }
          }
          catch {
            let result = Result<Void, Error>.failure(error)
            resultHandler(result)
          }
        }
      }
      catch {
        let result = Result<Void, Error>.failure(error)
        resultHandler(result)
      }
    }
  }
  
  func messages(resultHandler: @escaping ResultHandler<[Message], Error>) {
    DispatchQueue.global().async {
      let httpInput = HTTPInput(
        body: nil,
        head: HTTPInputHead(
          fields: [HTTPField](),
          method: .get,
          url: self.url
        )
      )
      
      URLSession.shared.httpOutput(withHTTPInput: httpInput) { result in
        do {
          let httpOutput = try result.get()
          
          switch httpOutput.head.statusCode {
          case 200:
            guard let body = httpOutput.body else {
              throw MessageGatewayError.dataNotFound
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            let messages = try decoder.decode(Channel.self, from: body).messages
            let result = Result<[Message], Error>.success(messages)
            resultHandler(result)
          default:
            throw MessageGatewayError.invalidStatusCode
          }
        }
        catch {
          let result = Result<[Message], Error>.failure(error)
          resultHandler(result)
        }
      }
    }
  }
}

private enum MessageGatewayError: Error {
  case dataNotFound
  case invalidResponse
  case invalidStatusCode
  case urlNotFound
}
