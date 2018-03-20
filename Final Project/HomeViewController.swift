//
//  ViewController.swift
//  Final Project
//
//  Created by Max Moede on 2/28/18.
//  Copyright © 2018 Max Moede. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class HomeViewController: UIViewController, UITextFieldDelegate {

    var selectedSkills = [String]()
    var userData : User?
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var withinLabel: UILabel!
    @IBOutlet weak var expertChecked: UILabel!
    @IBOutlet weak var intermediateChecked: UILabel!
    @IBOutlet weak var beginnerChecked: UILabel!
    @IBOutlet weak var firstInstTF: UITextField!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var guitarChecked: UILabel!
    @IBOutlet weak var bassChecked: UILabel!
    @IBOutlet weak var drumChecked: UILabel!
    @IBOutlet weak var vocalChecked: UILabel!
    
    var autoCompleteInsts = ["Guitar Player", "Drummer", "Bass Player", "Singer", "Vocalist", "Guitarist", "Bassist"]
    var timer = Timer()
    var autoCCharacterCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        testLabel.text = "I'm looking for..."
        beginnerChecked.text = "Unchecked"
        intermediateChecked.text = "Unchecked"
        expertChecked.text = "Unchecked"
        guitarChecked.text = "Unchecked"
        bassChecked.text = "Unchecked"
        drumChecked.text = "Unchecked"
        vocalChecked.text = "Unchecked"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderAdjusted(_ sender: UISlider) {
        let newVal = Int(sender.value)
        withinLabel.text = "\(newVal) miles from my location"
    }
    
    @IBAction func guitarPressed(_ sender: UIButton) {
        buttonPressed(label: guitarChecked)
    }
    
    @IBAction func bassPressed(_ sender: UIButton) {
        buttonPressed(label: bassChecked)
    }
    
    @IBAction func drumPressed(_ sender: UIButton) {
        buttonPressed(label: drumChecked)
    }
    @IBAction func vocalPressed(_ sender: UIButton) {
        buttonPressed(label: vocalChecked)
        
    }
    @IBAction func beginnerButtonPressed(_ sender: UIButton) {
        buttonPressed(label: beginnerChecked)
    }
    
    @IBAction func intermediateButtonPressed(_ sender: UIButton) {
        buttonPressed(label: intermediateChecked)
    }
    @IBAction func expertButtonPressed(_ sender: UIButton) {
        buttonPressed(label: expertChecked)
    }
    
    func buttonPressed(label: UILabel){
        if (label.text! == "Unchecked"){
            label.text = "Checked"
        } else {
            label.text = "Unchecked"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var subString = (firstInstTF.text!.capitalized as NSString).replacingCharacters(in: range, with: string)
        subString = formatSubstring(subString: subString)
        
        if subString.count == 0 {
            resetValues()
        } else {
            searchAutoCEntriesWithSub(substring: subString)
        }
        return true
    }
    func formatSubstring(subString: String) -> String {
        let formatted = String(subString.dropLast(autoCCharacterCount)).lowercased().capitalized
        return formatted
    }
    func resetValues() {
        autoCCharacterCount = 0
        firstInstTF.text = ""
    }
    func searchAutoCEntriesWithSub(substring: String) {
        let userQ = substring
        let suggestions = getAutocompleteSuggestions(userText: substring)
        if suggestions.count > 0 {
            timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { (timer) in
                let autocompleteResult = self.formatAutocompleteResult(substring: substring, possibleMatches: suggestions)
            self.putColourFormattedTextInTextField(autocompleteResult: autocompleteResult, userQuery: userQ)
                self.moveCaretToEndOfUserQueryPosition(userQuery: userQ)
                
            })
        } else {
            timer = .scheduledTimer(withTimeInterval: 0.01, repeats: false, block: {(timer) in
                self.firstInstTF.text = substring
            })
            autoCCharacterCount = 0
        }
    }
    
    func getAutocompleteSuggestions(userText: String) -> [String]{
        var possibleMatches: [String] = []
        for item in autoCompleteInsts {
            let myString:NSString! = item as NSString
            let substringRange:NSRange! = myString.range(of: userText)
            
            if (substringRange.location == 0){
                possibleMatches.append(item)
            }
        }
        return possibleMatches
    }
    
    func putColourFormattedTextInTextField(autocompleteResult: String, userQuery : String) {
        let coloredString:NSMutableAttributedString = NSMutableAttributedString(string: userQuery + autocompleteResult)
        coloredString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.green, range: NSRange(location: userQuery.count, length: autocompleteResult.count))
        self.firstInstTF.attributedText = coloredString
    }
    func moveCaretToEndOfUserQueryPosition(userQuery: String) {
        if let newPosition = self.firstInstTF.position(from: self.firstInstTF.beginningOfDocument, offset: userQuery.count) {
            self.firstInstTF.selectedTextRange = self.firstInstTF.textRange(from: newPosition, to: newPosition)
        }
        let selectedRange: UITextRange? = firstInstTF.selectedTextRange
        firstInstTF.offset(from: firstInstTF.beginningOfDocument, to: (selectedRange?.start)!)
        
    }
    
    func formatAutocompleteResult(substring: String, possibleMatches: [String]) -> String {
        var autoCompleteResult = possibleMatches[0]
        autoCompleteResult.removeSubrange(autoCompleteResult.startIndex..<autoCompleteResult.index(autoCompleteResult.startIndex, offsetBy: substring.count))
        autoCCharacterCount = autoCompleteResult.count
        return autoCompleteResult
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getSearch" {
            let destVC = segue.destination as! SearchResults
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
            destVC.results = "it worked"
        }
    }

}

