import UIKit

class MainViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  
  private let messageGateway = RemoteMessageGateway()
  private var messages = [Message]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
    textTextField.delegate = self
    fetchMessages()
  }
  
  private func fetchMessages() {
    messageGateway.messages() { [weak self] result in
      do {
        let messages = try result.get()
        
        DispatchQueue.main.async { [weak self] in
          self?.messages = messages
          self?.tableView.reloadData()
        }
      }
      catch {
        print(error)
      }
    }
  }
  
  private func sendMessage() {
    guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      return
    }
    
    guard let text = textTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
      return
    }
    
    let messageSpec = MessageSpec(
      text: text,
      username: username
    )
    
    messageGateway.addMessage(with: messageSpec) { [weak self] result in
      do {
        try result.get()
        
        DispatchQueue.main.async { [weak self] in
          self?.textTextField.text = nil
          self?.fetchMessages()
        }
      }
      catch {
        print(error)
      }
    }
  }
  
  @IBAction func fetchMessages(_ sender: UIButton) {
    fetchMessages()
  }
  
  @IBAction func sendMessage(_ sender: UIButton) {
    sendMessage()
  }
}

extension MainViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Message", for: indexPath)
    cell.detailTextLabel?.text = messages[indexPath.row].text
    cell.textLabel?.text = messages[indexPath.row].username
    return cell
  }
}

extension MainViewController: UITableViewDelegate {
  
}

extension MainViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    sendMessage()
    return false
  }
}
