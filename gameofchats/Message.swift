//
//  Message.swift
//  gameofchats
//
//  Created by Patrick Leonardus on 04/10/19.
//  Copyright © 2019 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId : String?
    var text : String?
    var timestamp : NSNumber?
    var toId : String?

    func chatPartnerId() -> String? {
        
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
        
    }
    
}
