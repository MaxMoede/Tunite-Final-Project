//
//  Profile.swift
//  Final Project
//
//  Created by Max Moede on 3/3/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import MapKit
import os.log

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest = 0.1
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1
    }
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}

class Profile : NSObject, NSCoding, MKAnnotation {
    var myPic: UIImage?
    var name: String
    var instrument: String
    var skillLevel: String
    var bio: String
    var latitude: Double?
    var longitude: Double?
    var ref: Storage?
    var picRef: StorageReference?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
    }
    
    override init() {
        name = ""
        instrument = ""
        skillLevel = ""
        bio = ""
        latitude = 0.0
        longitude = 0.0
        //myPic = UIImage(named: "genPic.jpg")!
    }
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return bio
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        skillLevel = aDecoder.decodeObject(forKey: "skillLevel") as! String
        instrument = aDecoder.decodeObject(forKey: "instrument") as! String
        bio = aDecoder.decodeObject(forKey: "bio") as! String
        myPic = aDecoder.decodeObject(forKey: "myPic") as? UIImage
    }
    
    init(location: CLLocation, key: String, snapshot: DataSnapshot) {
        ref = Storage.storage()
        let storageRef = ref?.reference()
        print("key: \(key)")
        let imagesRef = storageRef?.child("images").child(key)
        picRef = imagesRef?.child("myPic.jpg")
        
        let snapval = snapshot.value as! [String: AnyObject]
        let snaptemp = snapval[key] as! [String: AnyObject]
        name = snaptemp["name"] as? String ?? "N/A"
        instrument = snaptemp["instrument"] as? String ?? "N/A"
        skillLevel = snaptemp["skillLevel"] as? String ?? "N/A"
        bio = snaptemp["bio"] as? String ?? "N/A"
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        myPic = #imageLiteral(resourceName: "genPic.jpg")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(skillLevel, forKey: "skillLevel")
        aCoder.encode(instrument, forKey: "instrument")
        aCoder.encode(bio, forKey: "bio")
        aCoder.encode(myPic, forKey: "myPic")
    }
}


/*var dlImage : UIImage?
 DispatchQueue.global(qos: .background).async {
 picRef?.getData(maxSize: 1*1024*1024) { data, error in
 if error != nil {
 print("error, couldn't download photo \(String(describing: error))")
 dlImage = #imageLiteral(resourceName: "genPic.jpg")
 } else {
 print("did download photo")
 dlImage = UIImage(data: data!)
 }
 }
 }
 self.myPic = dlImage*/
