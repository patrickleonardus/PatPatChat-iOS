//
//  newMessageController.swift
//  gameofchats
//
//  Created by Patrick Leonardus on 02/10/19.
//  Copyright © 2019 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

class newMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    
    var messagesController = MessagesController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        navigationItem.title = "Compose a message"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBtn))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
        
    }
    
    @objc func cancelBtn(){
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.name = (dictionary["name"] as! String)
                user.email = (dictionary["email"] as! String)
                user.profileImageUrl = (dictionary["profileImageUrl"] as! String)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
  
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        cell.timeLabel.text = ""
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController.showChatControllerForUser(user: user)
        }
    }
}
