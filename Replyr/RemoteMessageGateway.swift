import Foundation

class RemoteMessageGateway: MessageGateway {
  func addMessage(with spec: MessageSpec, resultHandler: @escaping ResultHandler<Void, Error>) {
    do {
      guard let url = URL(scheme: "https", host: "host", pathComponents: [""]) else {
        throw MessageGatewayError.urlNotFound
      }
      
      var request = URLRequest(url: url)
      request.httpBody = try JSONEncoder().encode(spec)
      
      let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        do {
          if let error = error {
            throw error
          }
          
          guard let response = response as? HTTPURLResponse else {
            throw MessageGatewayError.invalidResponse
          }
          
          switch response.statusCode {
          case 200:
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
      
      task.resume()
    }
    catch {
      let result = Result<Void, Error>.failure(error)
      resultHandler(result)
    }
  }
  
  func messages(resultHandler: @escaping ResultHandler<[Message], Error>) {
    DispatchQueue.global().async {
      do {
        guard let url = URL(scheme: "https", host: "host", pathComponents: [""]) else {
          throw MessageGatewayError.urlNotFound
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
          do {
            if let error = error {
              throw error
            }
            
            guard let response = response as? HTTPURLResponse else {
              throw MessageGatewayError.invalidResponse
            }
            
            switch response.statusCode {
            case 200:
              guard let data = data else {
                throw MessageGatewayError.dataNotFound
              }
              
              let messages = try JSONDecoder().decode([Message].self, from: data)
              let result = Result<[Message], Error>.success(messages)
              resultHandler(result)
            default:
              break
            }
          }
          catch {
            let result = Result<[Message], Error>.failure(error)
            resultHandler(result)
          }
        }
        
        task.resume()
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
