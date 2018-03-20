//
//  ChatLogController.swift
//  Final Project
//
//  Created by Max Moede on 3/19/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController {

    var inputTextField : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chat"
        // Do any additional setup after loading the view.
        setupInputComponents()
    }

    func setupInputComponents() {
        let containerView = UIView()
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
        containerView.addSubview(inputTextField!)
        
        inputTextField!.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        inputTextField!.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField!.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField!.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLine)
        
        separatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    @objc func handleSend() {
        //print(123)
        let ref = Database.database().reference().child("messages")
        let values = ["text": inputTextField!.text]
        ref.updateChildValues(values)
        print(inputTextField?.text!)
        
    }
}
