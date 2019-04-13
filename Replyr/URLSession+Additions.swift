import Foundation

extension URLSession {
  func httpOutput(withHTTPInput httpInput: HTTPInput, resultHandler: @escaping ResultHandler<HTTPOutput, Error>) {
    var request = URLRequest(url: httpInput.head.url)
    request.httpBody = httpInput.body
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      do {
        if let error = error {
          throw error
        }
        
        guard let response = response as? HTTPURLResponse else {
          throw URLSessionExtensionError.invalidResponse
        }
        
        guard let url = response.url else {
          throw URLSessionExtensionError.urlNotFound
        }

        var fields = [HTTPField]()
        
        if let headerFields = response.allHeaderFields as? [String: String] {
          for headerField in headerFields {
            let field = HTTPField(
              name: headerField.key,
              value: headerField.value
            )

            fields.append(field)
          }
        }
        
        let httpOutput = HTTPOutput(
          body: data,
          head: HTTPOutputHead(
            fields: fields,
            statusCode: response.statusCode,
            url: url,
            version: nil
          )
        )
        
        let result = Result<HTTPOutput, Error>.success(httpOutput)
        resultHandler(result)
      }
      catch {
        let result = Result<HTTPOutput, Error>.failure(error)
        resultHandler(result)
      }
    }
    
    task.resume()
  }
}

private enum URLSessionExtensionError: Error {
  case invalidResponse
  case urlNotFound
}
