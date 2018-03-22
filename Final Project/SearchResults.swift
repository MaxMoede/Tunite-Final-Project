//
//  SearchResults.swift
//  Final Project
//
//  Created by Max Moede on 3/2/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GeoFire

extension UIView {
    func startRotating(duration: Double = 1) {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(M_PI * 2.0)
            self.layer.add(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animation(forKey: kAnimationKey) != nil {
            self.layer.removeAnimation(forKey: kAnimationKey)
        }
    }
}

class SearchResults: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var newRegion : MKCoordinateRegion?
    var databaseRef : DatabaseReference?
    var geoFire: GeoFire?
    var regionQuery : GFRegionQuery?
    var radius: Int?
    var skillLevels: [String]?
    var instrument: String?
    var thePlayers = [Profile]()
    let locationManager = CLLocationManager()
    //let loaderImage = #imageLiteral(resourceName: "rockRoll.png")
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thePlayers.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlayer = thePlayers[(indexPath as NSIndexPath).row]
        print("name: ")
        print(selectedPlayer.name)
        self.performSegue(withIdentifier: "goToProfile", sender: selectedPlayer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfile" {
            if sender is Profile {
                let dest = segue.destination as! otherProfileView
                dest.sentProfile = sender as? Profile
                
                print("sender is a profile")
            } else {
                print("UH OH sender is not a profile")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aProfile", for: indexPath) as! profileCell
        let thisPlayer = thePlayers[(indexPath as NSIndexPath).row]
        let picToUse = thisPlayer.myPic ?? #imageLiteral(resourceName: "genPic.jpg")
        cell.profPic.image = picToUse
        let ratio = picToUse.size.width / picToUse.size.height
        
        let newHeight = cell.picView.frame.height - 4
        let newWidth = newHeight * ratio
        cell.profPic.frame.size = CGSize(width: newWidth, height: newHeight)
        
        
        cell.nameL.text! = thisPlayer.name
        cell.instrumentL.text! = thisPlayer.instrument
        return cell
        
    }
    
    func configureLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = 1.0
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
    }

    @IBOutlet weak var testLabel: UILabel!
    var results : String?
    
    
    @IBOutlet weak var customLoader: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //customLoader.startAnimating()
        customLoader.startRotating(duration: 1)
        configureLocationManager()
        databaseRef = Database.database().reference().child("users")
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("geofire"))
        print("Here's what showed up...")
        print("Skill levels: ")
        for skill in skillLevels! {
            print("\(skill)")
        }
        print("radius: \(String(describing: radius))")
        print("Instrument: \(String(describing: instrument))")
        let radiusString = radius!
        testLabel.text = "Musicians found within \(radiusString) miles"
        if let currentLocation = locationManager.location?.coordinate {
            newRegion = MKCoordinateRegionMakeWithDistance(currentLocation, (CLLocationDistance(1609 * radius!)), CLLocationDistance(1609 * radius!))
            DispatchQueue.global(qos: .background).async {
                self.updateRegionQuery()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func updateRegionQuery() {
        if let oldQuery = regionQuery {
            oldQuery.removeAllObservers()
        }
        
        regionQuery = geoFire?.query(with: newRegion!)
        
        regionQuery?.observe(.keyEntered, with: { (key, location) in
            self.databaseRef?.queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: { snapshot in
                print("found some great values")
                print("instrument: \(snapshot.key ?? "No Instrument")")
                DispatchQueue.global(qos: .background).async {
                    let newProfile = Profile(location: location, key: key, snapshot: snapshot)
                    self.addProfile(profile: newProfile)
                    
                }
                
            })
        })
    }
    

    
    func addProfile(profile: Profile) {
        DispatchQueue.global(qos: .background).async {
            if let picRef = profile.picRef {
                picRef.getData(maxSize: 1*1024*1024) { data, error in
                    if error != nil {
                        print("error, couldn't download photo \(String(describing: error))")
                        profile.myPic = #imageLiteral(resourceName: "genPic.jpg")
                        DispatchQueue.main.async {
                            self.thePlayers.append(profile)
                            self.tableView.reloadData()
                        }
                    } else {
                        print("did download photo")
                        profile.myPic = UIImage(data: data!)
                        DispatchQueue.main.async {
                            self.thePlayers.append(profile)
                            self.tableView.reloadData()
                            self.customLoader.stopRotating()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.thePlayers.append(profile)
                    self.tableView.reloadData()
                }
            }
        }
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
