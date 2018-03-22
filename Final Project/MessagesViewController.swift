//
//  MessagesViewController.swift
//  Final Project
//
//  Created by Max Moede on 2/28/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var messages = [Message]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMessage = messages[(indexPath as NSIndexPath).row]
        self.performSegue(withIdentifier: "goToChat", sender: selectedMessage)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageContact", for: indexPath) as! MessageCell
        cell.heightAnchor.constraint(equalToConstant: 70)
        let message = messages[(indexPath as NSIndexPath).row]
        
        if let toId = message.toId {
            if message.toId == Auth.auth().currentUser?.uid {
                let ref = Database.database().reference().child("users").child(message.fromId!)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let contact = Profile(snapshot: snapshot)
                    cell.nameL.text = contact.name
                })
            } else {
                let ref = Database.database().reference().child("users").child(toId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let contact = Profile(snapshot: snapshot)
                    cell.nameL.text = contact.name
                })
            }
        }
        if let seconds = message.timestamp?.doubleValue {
            let timeStampDate = NSDate(timeIntervalSince1970: seconds)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.timeLabel.text = dateFormatter.string(from: timeStampDate as Date)
        }
        cell.messageL.text = message.text
        //cell.messageL
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChat" {
            let selMes = sender as! Message
            let destVC = segue.destination as! ChatLogController
            if selMes.fromId == Auth.auth().currentUser?.uid{
                let ref = Database.database().reference().child("users").child(selMes.toId!)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let contact = Profile(snapshot: snapshot)
                    destVC.sentProfile = contact
                })
            } else {
                let ref = Database.database().reference().child("users").child(selMes.fromId!)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let contact = Profile(snapshot: snapshot)
                    destVC.sentProfile = contact
                })
            }
        }
    }
    
    
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    var userData : User?
    var delegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title = delegate.userData?.displayName ?? delegate.userData?.email
        observeMessages()
        

        // Do any additional setup after loading the view.
    }
    
    var messagesDictionary = [String: Message]()
    
    func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded) { (snapshot) in
            let message = Message(snapshot: snapshot)
            //print(message.text)
            
            if let toId = message.toId {
                if toId == Auth.auth().currentUser?.uid || message.fromId == Auth.auth().currentUser?.uid{
                    let chatPartner = message.chatParterId()
                    self.messagesDictionary[chatPartner!] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return message1.timestamp!.intValue > message2.timestamp!.intValue
                    })
                }
                
            }
            
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }



}
