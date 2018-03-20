//
//  ProfileViewController.swift
//  Final Project
//
//  Created by Max Moede on 2/28/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import CoreLocation
import MapKit
import GeoFire

extension UIColor {
    convenience init(r: Int, g: Int, b: Int){
        self.init(red: CGFloat(r/255), green: CGFloat(g/255), blue: CGFloat(b/255), alpha: 1)
    }
}


class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    var userRoot : DatabaseReference?
    var geoFire : GeoFire?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager()
    @IBOutlet weak var picView: UIImageView!
    var myProfilePic : UIImage?
    @IBOutlet weak var nameL: UITextField!
    @IBOutlet weak var instrumentL: UITextField!
    var dataRecieved : Profile?
    var myProfile : Profile?
    @IBOutlet weak var bioTF: UITextField!
    @IBOutlet weak var profileL: UILabel!
    
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    //static let archiveURL = documentsDirectory.appendingPathComponent("savedPlayer")
    var dateFormatter = DateFormatter()
    var theDefaults = UserDefaults.standard
    
    func loadInAtts() {
        bioTF.text = myProfile?.bio
        nameL.text = myProfile?.name
        instrumentL.text = myProfile?.instrument
        picView.image = myProfile?.myPic
    }
    
    func toAnyObject(aProfile: Profile) -> Any {
        return [
            "name" : aProfile.name as Any,
            "instrument" : aProfile.instrument as Any,
            "bio" : aProfile.bio as Any,
            "latitude" : aProfile.latitude as Any,
            "longitude" : aProfile.longitude as Any
        ]
    }
    
    
    func configureLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = 1.0
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = (locationManager.location?.coordinate)!
        print("ran")
        updateGeoFire(aLocVal: locValue)
    }
    
    func updateGeoFire(aLocVal: CLLocationCoordinate2D) {
        print("also ran")
        print("latitude: \(aLocVal.latitude), longitude: \(aLocVal.longitude)")
        let userUid = Auth.auth().currentUser?.uid
        self.geoFire?.setLocation(CLLocation(latitude: aLocVal.latitude, longitude: aLocVal.longitude), forKey: userUid!) { (error) in
            if error != nil {
                print("error, \(String(describing: error))")
            } else {
                print("well it says it worked")
            }
        }
    }
    
    override func viewDidLoad() {
        
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("geofire"))
        configureLocationManager()
        print(delegate.userData?.email!)
        let archiveURL = ProfileViewController.documentsDirectory.appendingPathComponent("\(self.delegate.userData?.email! ?? "noData")")
        //static let archiveURL = self.documentsDirectory.appendingPathComponent("savedPlayer")
        profileL.text = "my profile"
        if let lastUpdate = theDefaults.object(forKey: "\(self.delegate.userData?.email! ?? "noData") lastUpdate") as? Date {
            let updateString = dateFormatter.string(from: lastUpdate)
            let dialogString = "Last Update:\n\(updateString)"
            let dialog = UIAlertController(title: "We got some data.", message: dialogString, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            dialog.addAction(action)
            
            present(dialog, animated: true, completion: nil)
            if let profileInfo = NSKeyedUnarchiver.unarchiveObject(withFile: archiveURL.path) as? Profile {
                myProfile = profileInfo
                loadInAtts()
            }
        } else {
            myProfile = Profile()
            loadInAtts()
        }
        super.viewDidLoad()
    }
    
    func updatePersistentStorage() {
        let archiveURL = ProfileViewController.documentsDirectory.appendingPathComponent("\(self.delegate.userData?.email! ?? "noData")")
        NSKeyedArchiver.archiveRootObject(myProfile!, toFile: archiveURL.path)
        
        theDefaults.set(Date(), forKey: "\(self.delegate.userData?.email! ?? "noData") lastUpdate")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editPressed(_ sender: UIButton) {
        bioTF.isEnabled = true
        instrumentL.isEnabled = true
        nameL.isEnabled = true
    }
    @IBAction func savePressed(_ sender: UIButton) {
        bioTF.isEnabled = false
        instrumentL.isEnabled = false
        nameL.isEnabled = false
        myProfile?.instrument = instrumentL.text!
        myProfile?.name = nameL.text!
        myProfile?.bio = bioTF.text!
        myProfile?.myPic = picView.image!
        updatePersistentStorage()
        updateFirebase()
    }
    
    func updateFirebase() {
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
    }
    
    
    
    @IBAction func selectImageFromPhotoLib(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image : \(info)")
        }
        picView.image = selectedImage
        dismiss(animated: true, completion: nil)
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
