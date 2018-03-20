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

class MessagesViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationItem!
    var userData : User?
    var delegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title = delegate.userData?.displayName ?? delegate.userData?.email
        
        

        // Do any additional setup after loading the view.
    }

    
    @IBAction func composeMessage(_ sender: UIBarButtonItem) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
