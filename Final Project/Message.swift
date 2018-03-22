//
//  Message.swift
//  Final Project
//
//  Created by Max Moede on 3/20/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    var ref: StorageReference?
    
    init(snapshot: DataSnapshot){
        ref = Storage.storage().reference()
        let snapVal = snapshot.value as! [String: AnyObject]
        fromId = snapVal["fromId"] as? String ?? "N/A"
        toId = snapVal["toId"] as? String ?? "N/A"
        text = snapVal["text"] as? String ?? "N/A"
        timestamp = snapVal["timeStamp"] as? NSNumber
        
    }
    
    func chatParterId() -> String? {
        if fromId == Auth.auth().currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
}
