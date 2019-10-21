//
//  UserCell.swift
//  gameofchats
//
//  Created by Patrick Leonardus on 05/10/19.
//  Copyright © 2019 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

class UserCell : UITableViewCell {
    
    var message : Message? {
        didSet{
            
            setupNameAndProfile()
            
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
        }
    }
    
    private func setupNameAndProfile(){
        //untuk grup message per id
        
        if let id = message?.chatPartnerId() {
            let reference = Database.database().reference().child("users").child(id)
            
            reference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                    
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 68, y: ((textLabel?.frame.origin.y)! - 2), width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 68 , y: ((detailTextLabel?.frame.origin.y)! + 2), width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
        
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Time"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 24),
            timeLabel.centerYAnchor.constraint(equalTo: textLabel!.centerYAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor)
            ])
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
