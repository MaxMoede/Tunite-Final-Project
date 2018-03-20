//
//  LoginPage.swift
//  Final Project
//
//  Created by Max Moede on 3/3/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginPage: UIViewController, UITextFieldDelegate {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var passwordL: UITextField!
    @IBOutlet weak var usernameL: UITextField!
    var userData : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordL {
            passwordL.text = textField.text
            textField.resignFirstResponder()
            
        }
        if textField == usernameL {
            usernameL.text = textField.text
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        let email = usernameL.text!
        let password = passwordL.text!
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            // ...
            if error != nil {
                print("didn't authenticate")
            } else {
                self.delegate.userData = user!
                self.performSegue(withIdentifier: "gotoHome", sender: self)
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "gotoSignUp", sender: self)
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoHome" {
            //let destVC = segue.destination as! NavigationController
            //destVC.userData = self.userData
            /*let destVC = segue.destination as! SearchResults
            destVC.radius = Int(radiusSlider.value)
            destVC.instrument = firstInstTF.text!
            if (beginnerChecked.text! == "Checked"){
                selectedSkills.append("beginner")
            }
            if (intermediateChecked.text! == "Checked"){
                selectedSkills.append("intermediate")
            }
            if (expertChecked.text! == "Checked"){
                selectedSkills.append("expert")
            }
            destVC.skillLevels = selectedSkills
            destVC.results = "it worked"*/
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
