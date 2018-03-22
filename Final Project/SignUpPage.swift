//
//  SignUpPage.swift
//  Final Project
//
//  Created by Max Moede on 3/3/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpPage: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorL: UILabel!
    @IBOutlet weak var nameL: UITextField!
    @IBOutlet weak var passwordL: UITextField!
    @IBOutlet weak var usernameL: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameL {
            usernameL.text = textField.text
        }
        if textField == passwordL {
            passwordL.text = textField.text
        }
        if textField == nameL {
            nameL.text = textField.text
        }
        textField.resignFirstResponder()
        return true
    }

    
    func toAnyObject(_ aName: String, _ id: String) -> Any {
        return [
            "name" : aName as Any,
            "id" : id as Any
        ]
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        guard let text = usernameL.text, !text.isEmpty else {
            errorL.isHidden = false
            return
        }
        guard let text1 = nameL.text, !text1.isEmpty else {
            errorL.isHidden = false
            return
        }
        guard let text2 = passwordL.text, !text2.isEmpty else {
            errorL.isHidden = false
            return
        }
        errorL.isHidden = true
        let email = usernameL.text!
        let password = passwordL.text!
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("broke, \(error)")
            } else {
                let user = Auth.auth().currentUser
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nameL.text!
                changeRequest?.commitChanges { (error) in
                }
                let userRoot = Database.database().reference(withPath: "users").child((user?.uid)!)
                userRoot.setValue(self.toAnyObject(self.nameL.text!, (user?.uid)!))
                let alert = UIAlertController(title: "myAlert", message: "You've successfully signed up!", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default) { (alert: UIAlertAction!) -> Void in
                    self.performSegue(withIdentifier: "gotoLogin", sender: self)
                }
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /*func updateFirebase() {
        let user = Auth.auth().currentUser
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("images").child((user?.uid)!)
        userRoot = Database.database().reference(withPath: "users")
        print("running")
        if ((user) != nil) {
            let newUserRef = self.userRoot?.child((user?.uid)!)
            newUserRef?.setValue(self.toAnyObject(aProfile: myProfile!))
            let storagePath = imagesRef.child("myPic.jpg")
            let imageData = myProfile?.myPic?.jpeg(.lowest)
            let uploadTask = storagePath.putData(imageData!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    return
                }
                let downloadURL = metadata.downloadURL
            }
        }
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
