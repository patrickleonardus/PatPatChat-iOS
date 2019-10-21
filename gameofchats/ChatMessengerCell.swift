//
//  ChatMessengerCell.swift
//  gameofchats
//
//  Created by Patrick Leonardus on 06/10/19.
//  Copyright © 2019 letsbuildthatapp. All rights reserved.
//

import UIKit

class ChatMessengerCell: UICollectionViewCell {
    
    let textView : UITextView = {
        let label = UITextView()
        label.text = "Text"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.isEditable = false
        return label
    }()
    
    static let blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView : UIView = {
       let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var bubbleWidthAnchor : NSLayoutConstraint?
    var bubbleViewRightAnchor : NSLayoutConstraint?
    var bubbleViewLeftAnchor : NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12)
        bubbleViewRightAnchor?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 8).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
