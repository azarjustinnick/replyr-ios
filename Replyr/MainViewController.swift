import UIKit

class MainViewController: UIViewController {
  @IBOutlet weak var keyboardViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  
  private let messageGateway = RemoteChannelGateway(name: "general")!
  private var messages = [Message]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 600
    tableView.dataSource = self
    tableView.delegate = self
    usernameTextField.text = "replyr-ios"
    usernameTextField.delegate = self
    textTextField.delegate = self
    textTextField.becomeFirstResponder()
    fetchMessages()
    
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: nil) { [weak self] notification in
      if let keyboard = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect) {
        self?.keyboardViewHeightConstraint.constant = keyboard.height
      }
    }
    
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
      self?.keyboardViewHeightConstraint.constant = 0
    }
  }
  
  private func fetchMessages() {
    messageGateway.messages() { [weak self] result in
      do {
        let messages = try result.get()
        
        DispatchQueue.main.async { [weak self] in
          self?.messages = messages
          self?.tableView.reloadData()
          
          let indexPath = IndexPath(
            row: 0,
            section: messages.count - 1
          )
          
          self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
    
    let backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: UUID().uuidString)
    
    messageGateway.addMessage(with: messageSpec) { [weak self] result in
      UIApplication.shared.endBackgroundTask(backgroundTaskID)
      
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
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return messages[section].username
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return messages.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Message", for: indexPath) as! MessageCell
    cell.messageTextLabel?.text = messages[indexPath.section].text
    return cell
  }
}

extension MainViewController: UITableViewDelegate {
  
}

extension MainViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTextField {
      textTextField.becomeFirstResponder()
    }
    else if textField == textTextField {
      sendMessage()
    }
    
    return false
  }
}
