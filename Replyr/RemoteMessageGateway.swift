import Foundation

class RemoteMessageGateway: MessageGateway {
  func addMessage(with spec: MessageSpec, resultHandler: @escaping ResultHandler<Void, Error>) {
    do {
      guard let url = URL(scheme: "https", host: "replyr.herokuapp.com", pathComponents: ["chat", "channel", "general", "message"]) else {
        throw MessageGatewayError.urlNotFound
      }
      
      let httpInput = HTTPInput(
        body: try JSONEncoder().encode(spec),
        head: HTTPInputHead(
          fields: [HTTPField](),
          method: .post,
          url: url
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
  
  func messages(resultHandler: @escaping ResultHandler<[Message], Error>) {
    DispatchQueue.global().async {
      do {
        guard let url = URL(scheme: "https", host: "replyr.herokuapp.com", pathComponents: ["chat", "channel", "general"]) else {
          throw MessageGatewayError.urlNotFound
        }
        
        let httpInput = HTTPInput(
          body: nil,
          head: HTTPInputHead(
            fields: [HTTPField](),
            method: .get,
            url: url
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
      catch {
        let result = Result<[Message], Error>.failure(error)
        resultHandler(result)
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
