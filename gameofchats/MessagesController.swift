//
//  ViewController.swift
//  gameofchats
//
//  Created by Brian Voong on 6/24/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    
    var timer : Timer?
    
    var messages = [Message]()
    var messageDictionary = [String : Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Compose", style: .plain, target: self, action: #selector(handleNewMessage))
        
        tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        checkIfUserLoggedIn()
        
    }
    
    func observeUserMessage(){
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let reference = Database.database().reference().child("user-messages").child(uid)
        reference.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageReferrence = Database.database().reference().child("messages").child(messageId)
            messageReferrence.observeSingleEvent(of: .value, with: { (snapshot) in
                
                
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    let message = Message()
                    message.fromId = (dictionary["fromId"] as! String)
                    message.text = (dictionary["text"] as! String)
                    message.timestamp = (dictionary["timestamp"] as! NSNumber)
                    message.toId = (dictionary["toId"] as! String)
                    
                    self.messages.append(message)
                    
                    if let chatPartnetId = message.chatPartnerId() {
                        self.messageDictionary[chatPartnetId] = message
                        self.messages = Array(self.messageDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return message1.timestamp!.intValue > message2.timestamp!.intValue
                        })
                    }
                    
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                    
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }

    
    @objc func handleReload(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func handleNewMessage(){
        let newMessage = newMessageController()
        newMessage.messagesController = self
        let navController = UINavigationController(rootViewController: newMessage)
        present(navController, animated: true, completion: nil)
        
    }

    
    func checkIfUserLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            performSelector(inBackground: #selector(handleLogout), with: nil)
        }
        else {
           fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.navigationItem.title = (dictionary["name"] as! String)
                
                let user = User()
                user.name = (dictionary["name"] as! String)
                user.email = (dictionary["email"] as! String)
                user.profileImageUrl = (dictionary["profileImageUrl"] as! String)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User){
        
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessage()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40)
            
            ])
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor)
            ])
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
            ])
        
        self.navigationItem.titleView = titleView
        
    }
    
    @objc func showChatControllerForUser(user : User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout() {
        
        let alert = UIAlertController(title: "Warning", message: "R U Sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
            
            do{
                try Auth.auth().signOut()
            }catch let logoutError{
                print(logoutError)
            }
            
            let loginController = LoginController()
            loginController.messagesController = self
            self.present(loginController, animated: true, completion: nil)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert,animated: true)
    
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
       
        cell.message = message
       
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let references = Database.database().reference().child("users").child(chatPartnerId)
        
        references.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : AnyObject] else {
                return
            }
            
            let user = User()
            user.id = chatPartnerId
            user.name = (dictionary["name"] as! String)
            user.email = (dictionary["email"] as! String)
            user.profileImageUrl = (dictionary["profileImageUrl"] as! String)
            
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        
        if section == 0 {
            title = "Messages"
        }
        
        return title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}
