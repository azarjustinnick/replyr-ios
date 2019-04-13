import UIKit

class MainViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  
  private let messageGateway = MessageGateway()
  private var messages = [Message]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func fetch(_ sender: UIButton) {
    messageGateway.messages() { [weak self] result in
      do {
        let messages = try result.get()
        
        DispatchQueue.main.async { [weak self] in
          self?.messages = messages
          self?.tableView.reloadData()
        }
      }
      catch {
        
      }
    }
  }
  
  @IBAction func send(_ sender: UIButton) {
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
    
    messageGateway.addMessage(with: messageSpec) { result in
      
    }
  }
}

extension MainViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Message", for: indexPath)
    cell.textLabel?.text = messages[indexPath.row].text
    return cell
  }
}

extension MainViewController: UITableViewDelegate {
  
}

