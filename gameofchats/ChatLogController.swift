//
//  ChatLogController.swift
//  gameofchats
//
//  Created by Patrick Leonardus on 04/10/19.
//  Copyright © 2019 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var user : User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessageReferences = Database.database().reference().child("user-messages").child(uid)
        
        userMessageReferences.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messageReferences = Database.database().reference().child("messages").child(messageId)
            
            messageReferences.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : AnyObject] else {
                    return
                }
                
                let message = Message()
                message.text = (dictionary["text"] as! String)
                message.fromId = (dictionary["fromId"] as! String)
                message.toId = (dictionary["toId"] as! String)
                message.timestamp = (dictionary["timestamp"] as! NSNumber)
                
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            let item = self.messages.count - 1
                            let insertionIndexPath = IndexPath(item: item, section: 0)
                            self.collectionView.scrollToItem(at: insertionIndexPath, at: .bottom, animated: true)
                        }
                    }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    lazy var inputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.layer.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        textField.layer.cornerRadius = 15
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    lazy var sendButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 65, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        collectionView.register(ChatMessengerCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.keyboardDismissMode = .interactive
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        inputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        setupInputComponent()
        
        setupKeyboardObservers()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification : NSNotification){
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        sendButtonBottomAnchor?.constant = -keyboardFrame!.height
        inputTextBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
       
    }
    
    @objc func handleKeyboardWillHide(notification : NSNotification){
        
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        
        containerViewBottomAnchor?.constant = 0
        sendButtonBottomAnchor?.constant = 0
        inputTextBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        if inputTextField.text!.isEmpty{
            sendButton.isEnabled = false
        }
        else if !(inputTextField.text!.isEmpty){
            if inputTextField.text!.isAlphanumeric{
                sendButton.isEnabled = true
                
            }
        }
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    var sendButtonBottomAnchor: NSLayoutConstraint?
    var inputTextBottomAnchor: NSLayoutConstraint?
    
    
    func setupInputComponent(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        
        view.addSubview(containerView)
        
        if #available(iOS 11.0, *) {
            
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            
            
            containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            containerViewBottomAnchor?.isActive = true
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
        } else {
            // Fallback on earlier versions
        }
        
        
      
        containerView.addSubview(sendButton)
        
        if #available(iOS 11.0, *) {
           
            sendButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant:  8).isActive = true
            sendButtonBottomAnchor = sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8)
            sendButtonBottomAnchor!.isActive = true
            sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            sendButton.heightAnchor.constraint(equalToConstant: 8).isActive = true
            
        } else {
           
            sendButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant:  8).isActive = true
            sendButtonBottomAnchor = sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8)
            sendButtonBottomAnchor!.isActive = true
            sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            sendButton.heightAnchor.constraint(equalToConstant: 8).isActive = true
            
        }
        
     
        containerView.addSubview(inputTextField)
        
        
        if #available(iOS 11.0, *) {
            inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant:  8).isActive = true
            inputTextBottomAnchor = inputTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8)
            inputTextBottomAnchor!.isActive = true
            inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
            inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            inputTextField.widthAnchor.constraint(equalToConstant: 120).isActive = true
            inputTextField.heightAnchor.constraint(equalToConstant: 4).isActive = true
            
        } else {
     
            inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant:  8).isActive = true
            inputTextBottomAnchor = inputTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8)
            inputTextBottomAnchor!.isActive = true
            inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
            inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            inputTextField.widthAnchor.constraint(equalToConstant: 120).isActive = true
            inputTextField.heightAnchor.constraint(equalToConstant: 5).isActive = true
            
        }
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        NSLayoutConstraint.activate([
            separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor),
            separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            separatorLineView.heightAnchor.constraint(equalToConstant: 0.8)
            ])
       
    }
    
    @objc func handleSend(){
        
        let reference = Database.database().reference().child("messages")
        let childReference = reference.childByAutoId()
        
        //ambil id user yg mau dichat
        let toId = user!.id!
        
        //ambil id user yg ngechat
        let fromId = Auth.auth().currentUser!.uid
        
        //ambil waktu chatnya
        let timestamp = Int(Date().timeIntervalSince1970)
        
        let values = ["text": inputTextField.text as Any, "toId": toId, "fromId": fromId, "timestamp": timestamp]
        
        //save ke firebase data seluruhnya
        childReference.updateChildValues(values) { (error, reference) in
            if error != nil{
                print("Error while send messages")
                return
            }
            
            self.inputTextField.text = ""
            
            guard let messageId = childReference.key else {
                return
            }
            //------------------------------------------
            
            let userMessageReferences = Database.database().reference().child("user-messages").child(fromId).child(messageId)
            userMessageReferences.setValue(1)
            
            let recipientUserMessagesReferences = Database.database().reference().child("user-messages").child(toId).child(messageId)
            recipientUserMessagesReferences.setValue(1)
 
            //------------------------------------------
            
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessengerCell
        
        let message = messages[indexPath.item]
        
       setupCell(cell: cell, message: message)
        
        cell.textView.text = message.text
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 28
        
        return cell
    }
    
    private func setupCell(cell: ChatMessengerCell, message: Message){
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessengerCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height : CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text : String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension ChatLogController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}
