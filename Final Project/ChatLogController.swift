//
//  ChatLogController.swift
//  Final Project
//
//  Created by Max Moede on 3/19/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {

    var inputTextField : UITextField?
    var sentProfile: Profile? {
        didSet {
            navigationItem.title = sentProfile?.name
            
            observeMessages()
        }
    }
    
    var allMessages = [Message]()
    
    func observeMessages() {
        let uid = Auth.auth().currentUser?.uid
        let messagesRef = Database.database().reference().child("messages")
        messagesRef.observe(.childAdded) { (snapshot) in
            print(snapshot)
            let newMessage = Message(snapshot: snapshot)
            if newMessage.toId == uid || newMessage.fromId == uid {
                if newMessage.toId == self.sentProfile?.id || newMessage.fromId == self.sentProfile?.id {
                    self.allMessages.append(newMessage)
                    print("added")
                    print(newMessage.text)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("id: ", sentProfile?.id)
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(messageBlip.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(leftMessageBlip.self, forCellWithReuseIdentifier: leftCellId)

        // Do any additional setup after loading the view.
        setupInputComponents()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    let cellId = "cellId"
    let leftCellId = "leftCellId"
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = allMessages[indexPath.row]
        if message.fromId == Auth.auth().currentUser?.uid {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! messageBlip
            print("ran")
            cell.textView.text = message.text
            
            
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: leftCellId, for: indexPath) as! leftMessageBlip
            print("ran")
            cell.textView.text = message.text
            
            
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //get estimated height
        if let text = allMessages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }

    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        return NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        //containerView.backgroundColor = UIColor.red
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        //ios9 anchors
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.heightAnchor).isActive = true
        
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField = textField
        inputTextField?.delegate = self
        containerView.addSubview(inputTextField!)
        
        inputTextField!.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        inputTextField!.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField!.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField!.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.blue//(r: 220, g: 220, b: 220)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLine)
        
        separatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //collectionView?.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        
    }
    
    @objc func handleSend() {
        //print(123)
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = sentProfile?.id
        let fromId = Auth.auth().currentUser?.uid
        let timeStamp = NSDate().timeIntervalSince1970
        let values = ["text": inputTextField!.text,
                      "toId": toId,
                      "fromId": fromId,
                      "timeStamp": timeStamp] as [String : Any]
        childRef.updateChildValues(values)
        self.inputTextField?.text = nil
        print(inputTextField?.text!)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        view.endEditing(true)
        return true
    }
}
