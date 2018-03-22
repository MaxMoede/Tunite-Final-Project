//
//  otherProfileView.swift
//  Final Project
//
//  Created by Max Moede on 3/7/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class otherProfileView: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {

    @IBOutlet weak var loginButton: UIButton!
    var sentProfile : Profile?
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var bioText: UITextField!
    @IBOutlet weak var profPic: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LOOK")
        print("name: ")
        print(sentProfile!.name)
        nameL.text = sentProfile!.name
        bioText.text = sentProfile!.bio
        profPic.image = sentProfile!.myPic
        /*if (sentProfile?.myPic?.isEqual(#imageLiteral(resourceName: "genPic.jpg")))!{
            print("FUCK")
        }*/
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(otherProfileView.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func messageClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showChat", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChat" {
            let destVC = segue.destination as! ChatLogController
            destVC.sentProfile = self.sentProfile
        }
    }
    
    
    @objc func updateAfterFirstLogin () {
        
        loginButton.isHidden = true
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            initializaPlayer(authSession: session)
            self.loginButton.isHidden = true
            // self.loadingLabel.isHidden = false
            
        }
        
    }
    
    func initializaPlayer(authSession:SPTSession){
        if self.player == nil {
            
            
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
            
        }
        
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
            
        })
        
    }
        
    func setup() {
        SPTAuth.defaultInstance().clientID = "2467577df1904e879fd1164cefe6e082"
        SPTAuth.defaultInstance().redirectURL = URL(string: "mmoede-tunite-login://returnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func scClicked(_ sender: UIButton) {
        if UIApplication.shared.openURL(loginUrl!) {
            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling
            }
        }
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
