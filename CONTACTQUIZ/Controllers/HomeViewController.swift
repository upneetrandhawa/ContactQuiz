//
//  ViewController.swift
//  PHONEQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-10.
//

import UIKit
import Contacts

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    
    @IBOutlet weak var howManyQuestionsLabel: UILabel!
    @IBOutlet weak var questionTypeLabel: UILabel!
    @IBOutlet weak var quizTimerLabel: UILabel!
    
    @IBOutlet weak var noOfQuestionsPicker: UIPickerView!
    @IBOutlet weak var questionTypePicker: UIPickerView!
    @IBOutlet weak var quizTimerPicker: UIPickerView!
    
    @IBOutlet weak var preferencesButton: UIButton!
    @IBOutlet weak var goToSettingsButton: UIButton!
    @IBOutlet weak var eligibleContactsButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    
    var accessToContacts: Bool = false
    
    var allContactsDict = [String:Contact]()//Store all Contacts. key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    var eligibleContactsDict = [String:Contact]()//Store only elibile contacts, i.e. both name and number should not be null. key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    var nonEligibleContactsDict = [String:Contact]()//Store only non-elibile contacts, i.e. etiher name or number is null.key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    
    var noOfQuestionsPickerData: [String] = [String]()
    var questionTypePickerData: [String] = [String]()
    var quizTimerPickerData: [String] = [String]()
    
    var noOfQuestionsPickerSelectedRow = 0
    var questionTypePickerSelectedRow = 0
    var quizTimerPickerSelectedRow = 0
    
    var user: User? = nil
    let userDefaults = UserDefaults.standard
    

    override func viewDidLoad() {
        print("\(#fileID) : \(#function): ")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //disable quiz at first to determine if we have permissions
        disableQuiz()
        
        //picker data
        noOfQuestionsPickerData = []
        questionTypePickerData = ["Contact Numbers", "Contact Names", "Both"]
        quizTimerPickerData = ["No Timer", "5 seconds", "10 seconds", "15 seconds", "30 seconds"]
        
        //connect picker
        self.noOfQuestionsPicker.dataSource = self
        self.noOfQuestionsPicker.delegate = self
        self.questionTypePicker.dataSource = self
        self.questionTypePicker.delegate = self
        self.quizTimerPicker.dataSource = self
        self.quizTimerPicker.delegate = self
        
        self.noOfQuestionsPicker.setValue(UIColor.systemIndigo, forKey: "textColor")
        self.questionTypePicker.setValue(UIColor.systemIndigo, forKey: "textColor")
        self.quizTimerPicker.setValue(UIColor.systemIndigo, forKey: "textColor")
        
        //add rounding to views
        self.bottomBackgroundView.layer.cornerRadius = 50
        self.goToSettingsButton.layer.cornerRadius = 15
        self.eligibleContactsButton.layer.cornerRadius = 15
        self.startButton.layer.cornerRadius = 15
        self.noOfQuestionsPicker.layer.cornerRadius = 15
        self.questionTypePicker.layer.cornerRadius = 15
        self.quizTimerPicker.layer.cornerRadius = 15
        
        //add border to following views
        self.goToSettingsButton.layer.borderWidth = 1
        self.goToSettingsButton.layer.borderColor = UIColor.white.cgColor
        self.eligibleContactsButton.layer.borderWidth = 1
        self.eligibleContactsButton.layer.borderColor = UIColor.white.cgColor
        self.startButton.layer.borderWidth = 2
        self.startButton.layer.borderColor = UIColor.systemIndigo.cgColor
        self.noOfQuestionsPicker.layer.borderWidth = 1
        self.noOfQuestionsPicker.layer.borderColor = UIColor.systemIndigo.cgColor
        self.questionTypePicker.layer.borderWidth = 1
        self.questionTypePicker.layer.borderColor = UIColor.systemIndigo.cgColor
        self.quizTimerPicker.layer.borderWidth = 1
        self.quizTimerPicker.layer.borderColor = UIColor.systemIndigo.cgColor
        
        //add shadow
        bottomBackgroundView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.7, shadowOffset: CGSize(width: 0.0, height: -5.0), shadowRadius: 1.0)
        goToSettingsButton.addShadow(shadowColor: UIColor.white.cgColor, shadowOpacity: 1.0, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
        eligibleContactsButton.addShadow(shadowColor: UIColor.white.cgColor, shadowOpacity: 1.0, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
            
        //load user object
        loadUserdata()
        
        //fetch contacts and prepare data structure
        fetchContacts()
       
        //add a menu to preferences button
        addMenuToPreferencesButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("\(#fileID) : \(#function): ")
        loadUserdata()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            
            bottomBackgroundView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.7, shadowOffset: CGSize(width: 0.0, height: -5.0), shadowRadius: 1.0)
            }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //print("\(#fileID) : \(#function): ")
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //print("\(#fileID) : \(#function): ")
        if pickerView == noOfQuestionsPicker {
            return noOfQuestionsPickerData.count
        }
        else if pickerView == questionTypePicker {
            return questionTypePickerData.count
        }
        return quizTimerPickerData.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == noOfQuestionsPicker {
            return noOfQuestionsPickerData[row]
        }
        else if pickerView == questionTypePicker {
            return questionTypePickerData[row]
        }
        return quizTimerPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(#fileID) : \(#function): didSelectRow row = ", row)
        
        if !accessToContacts {
            presentNoPermissionAlert()
            return
        }
        
        if pickerView == noOfQuestionsPicker {
            print("\(#fileID) : \(#function): Picker type: noOfQuestionsPicker")
            noOfQuestionsPickerSelectedRow = row
        }
        
        else if pickerView == questionTypePicker {
            print("\(#fileID) : \(#function): Picker type: questionTypePicker")
            questionTypePickerSelectedRow = row
        }
        
        else {
            print("\(#fileID) : \(#function): Picker type: quizTimerPicker")
            quizTimerPickerSelectedRow = row
        }
    }
    
    @IBAction func goToSettingsButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func noOfContactsButtonPresed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        
        self.tabBarController?.selectedIndex = 1
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let destinationVC = storyboard.instantiateViewController(withIdentifier: "eligibleContactsView") as! EligibleContactsViewController
//        destinationVC.user = user
//        destinationVC.allContactsDict = allContactsDict
//        destinationVC.eligibleContactsDict = eligibleContactsDict
//        destinationVC.nonEligibleContactsDict = nonEligibleContactsDict
//
//        self.present(destinationVC, animated: true)
        
        
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        if !accessToContacts {
            presentNoPermissionAlert()
            return
        }
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let destinationVC = storyboard.instantiateViewController(withIdentifier: "quizView") as! QuizViewController
//        destinationVC.homeViewControllerDelegate = self
//        destinationVC.user = user
//        destinationVC.eligibleContactsDict = eligibleContactsDict
//        destinationVC.noOfQuestions = Int(noOfQuestionsPickerData[noOfQuestionsPickerSelectedRow]) ?? 0
//        destinationVC.quizQuestionTypesSelected = quizQuestionType(rawValue: questionTypePickerSelectedRow) ?? .CONTACT_NUMBERS
//
//        switch quizTimerPickerSelectedRow {
//        case 0:
//            destinationVC.quizTimerSelected = .NO_TIMER
//        case 1:
//            destinationVC.quizTimerSelected = .FIVE_SECONDS
//        case 2:
//            destinationVC.quizTimerSelected = .TEN_SECONDS
//        case 3:
//            destinationVC.quizTimerSelected = .FIFTEEN_SECONDS
//        case 4:
//            destinationVC.quizTimerSelected = .THIRTY_SECONDS
//        default:
//            print("\(#fileID) : \(#function): DEFAULT")
//        }
//
//        print("\(#fileID) : \(#function): questionTypePickerSelectedRow = " + String(questionTypePickerSelectedRow))
//        self.present(destinationVC, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "quizTestView") as! QuizTestViewController
        destinationVC.homeViewControllerDelegate = self
        destinationVC.user = user
        destinationVC.eligibleContactsDict = eligibleContactsDict
        destinationVC.noOfQuestions = Int(noOfQuestionsPickerData[noOfQuestionsPickerSelectedRow]) ?? 0
        destinationVC.quizQuestionTypesSelected = quizQuestionType(rawValue: questionTypePickerSelectedRow) ?? .CONTACT_NUMBERS
        
        switch quizTimerPickerSelectedRow {
        case 0:
            destinationVC.quizTimerSelected = .NO_TIMER
        case 1:
            destinationVC.quizTimerSelected = .FIVE_SECONDS
        case 2:
            destinationVC.quizTimerSelected = .TEN_SECONDS
        case 3:
            destinationVC.quizTimerSelected = .FIFTEEN_SECONDS
        case 4:
            destinationVC.quizTimerSelected = .THIRTY_SECONDS
        default:
            print("\(#fileID) : \(#function): DEFAULT")
        }
        
        print("\(#fileID) : \(#function): questionTypePickerSelectedRow = " + String(questionTypePickerSelectedRow))
        self.present(destinationVC, animated: true)
        
    }
    
    
    
    func loadUserdata(){
        print("\(#fileID) : \(#function): ")
        
        
        
        if let userObject = userDefaults.data(forKey: DefaultsKeys.userObjectKey) {
            //User object exists, which means this is not the first ever launch
            print("\(#fileID) : \(#function): user found!! : ")
            
            do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()

                    // Decode userObject
                    user = try decoder.decode(User.self, from: userObject)
                
                //print("\(#fileID) : \(#function): user = " + user.debugDescription)

                } catch {
                    print("\(#fileID) : \(#function): user found!! : Unable to Decode User (\(error))")
                }
            
            
        }
        else {
            user = User(name: UIDevice.current.identifierForVendor?.uuidString ?? "",
                        email: "",
                        password: "",
                        dateJoined: Date(),
                        noOfQuizCompleted: 0,
                        noOfQuestionAnswered: 0,
                        noOfCorrectAnswers: 0,
                        totalTimeTakenForQuizzes: 0,
                        allQuizArray: [Quiz](),
                        isSoundOn: true,
                        isVibationOn: true)
            
            do {
                // Create JSON Encoder
                let encoder = JSONEncoder()

                // Encode Note
                let encodedUser = try encoder.encode(user)

                // Write/Set Data
                userDefaults.set(encodedUser, forKey: DefaultsKeys.userObjectKey)
                
                print("\(#fileID) : \(#function): new user created!! and added to User Defaults")

            } catch {
                print("\(#fileID) : \(#function): : Unable to Encode User (\(error))")
            }
            
        }
        
    }
    
    
    private func fetchContacts() {
        print("\(#fileID) : \(#function): ")
       
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("\(#fileID) : \(#function): failed to request access", error)
                return
            }
            if granted {
                
                print("\(#fileID) : \(#function): access Granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey,CNContactNicknameKey, CNContactDepartmentNameKey, CNContactOrganizationNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                   
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        //contact not eligible for quiz if either of name or phone number is null
                        
                        let isNameNull = (contact.givenName == "" && contact.familyName == "" && contact.nickname == "")
                        var isPhoneNumberNull = true
                        var phoneNumbers = [Contact.PhoneNumber]()
                        
                        for phoneNumber in contact.phoneNumbers {
                            
                            if isPhoneNumberNull {
                                if phoneNumber.value.stringValue != "" {
                                    isPhoneNumberNull = false
                                }
                            }
                            phoneNumbers.append(Contact.PhoneNumber(label: CNLabeledValue<NSString>.localizedString(forLabel: String(phoneNumber.label ?? "")), phoneNumber: phoneNumber.value.stringValue ))
                        }
                        
                        if !(isNameNull || isPhoneNumberNull){//Eglibile Contact
                            self.eligibleContactsDict[contact.identifier] = Contact(identifier: contact.identifier,
                                                                            fullName: contact.nickname + " " + contact.givenName + " " + contact.familyName + " " +  contact.organizationName + " " + contact.departmentName,
                                                                            phoneNumbersArray: phoneNumbers)
                        }
                        else {//Non-Eglibile Contact
                            self.nonEligibleContactsDict[contact.identifier] = Contact(identifier: contact.identifier,
                                                                                       fullName: contact.nickname + " " + contact.givenName + " " + contact.familyName + " " +  contact.organizationName + " " + contact.departmentName,
                                                                                       phoneNumbersArray: phoneNumbers)
                        }
                        
                        self.allContactsDict[contact.identifier] = Contact(identifier: contact.identifier,
                                                                           fullName: contact.nickname + " " + contact.givenName + " " + contact.familyName + " " +  contact.organizationName + " " + contact.departmentName,
                                                                           phoneNumbersArray: phoneNumbers)
                    })
                } catch let error {
                    print("\(#fileID) : \(#function): Failed to enumerate contact", error)
                }
                DispatchQueue.main.async {
                    self.permissionsGranted()
                }
                
            } else {
                print("\(#fileID) : \(#function): access Denied")
                self.permissionsDenied()
            }
        }
    }
    
    func addMenuToPreferencesButton(){
        print("\(#fileID) : \(#function): ")
        
        let vibrationAction = UIAction(title: "Vibration",
                                       image: UIImage(systemName: "iphone.radiowaves.left.and.right")?.withTintColor(.systemIndigo,
                                       renderingMode: .alwaysOriginal),
                                       attributes: [],
                                       state: (self.user?.isVibationOn ?? true) ? .on : .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): vibrationAction pressed")
                                        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
                                        
                                        let beforeVal = self.user?.isVibationOn ?? true
                                        print("\(#fileID) : \(#function): vibrationAction pressed : before isVibationOn = " + String(beforeVal))
                                        self.user?.isVibationOn = !(beforeVal)
                                        print("\(#fileID) : \(#function): vibrationAction pressed : after isVibationOn = " + String(self.user?.isVibationOn ?? true))
                                        //self.updateUserData()
                                        self.user?.updateUserData()
                                        self.addMenuToPreferencesButton()
            
        })
        
        //TODO: add the following code when sounds are added to the project
//        let soundAction = UIAction(title: String("Sound"),
//                                       image: UIImage(systemName: "speaker.zzz")?.withTintColor(.systemIndigo,
//                                       renderingMode: .alwaysOriginal),
//                                       attributes: [],
//                                       state: (self.user?.isSoundOn ?? true) ? .on : .off,
//                                       handler: { (action) -> Void in
//                                        print("\(#fileID) : \(#function): soundAction pressed")
//                                        self.vibrate(style: .soft)
//
//                                        let beforeVal = self.user?.isSoundOn ?? true
//                                        print("\(#fileID) : \(#function): soundAction pressed : before isSoundOn = " + String(beforeVal))
//                                        self.user?.isSoundOn = !(beforeVal)
//                                        print("\(#fileID) : \(#function): soundAction pressed : after isSoundOn = " + String(self.user?.isSoundOn ?? true))
//                                        self.updateUserData()
//                                        self.addMenuToPreferencesButton()
//
//        })
        
//        let profileAction = UIAction(title: "Profile",
//                                       image: UIImage(systemName: "person")?.withTintColor(.systemIndigo,
//                                       renderingMode: .alwaysOriginal),
//                                       attributes: [],
//                                       state: .off,
//                                       handler: { (action) -> Void in
//                                        print("\(#fileID) : \(#function): profileAction pressed")
//                                        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
//
//                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                        let destinationVC = storyboard.instantiateViewController(withIdentifier: "profileView") as! ProfileViewController
//                                        destinationVC.user = self.user
//
//                                        self.present(destinationVC, animated: true)
//
//
//
//        })
        
        let elements: [UIAction] = [vibrationAction]
        
        let menu:UIMenu = UIMenu(title: "Menu", children: elements)
        
        
        preferencesButton.showsMenuAsPrimaryAction = true
        preferencesButton.menu = menu
    }
    
    func permissionsGranted(){
        print("\(#fileID) : \(#function): allContactsDict count = ", allContactsDict.count)
        print("\(#fileID) : \(#function): eligibleContactsDict count = ", eligibleContactsDict.count)
        print("\(#fileID) : \(#function): nonEligibleContactsDict count = ", nonEligibleContactsDict.count)
        
        accessToContacts = true
        
        user?.allContactsDict = allContactsDict
        user?.eligibleContactsDict = eligibleContactsDict
        user?.nonEligibleContactsDict = nonEligibleContactsDict
        user?.updateUserData()
        
        //add our data stuctures to userDefaults
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let allContactsEncoded = try encoder.encode(allContactsDict)
            let eligibleContactsEncoded = try encoder.encode(eligibleContactsDict)
            let nonEligibleContactsEncoded = try encoder.encode(nonEligibleContactsDict)

            // Write/Set Data
            UserDefaults.standard.set(allContactsEncoded, forKey: DefaultsKeys.allContactsKey)
            UserDefaults.standard.set(eligibleContactsEncoded, forKey: DefaultsKeys.eligibleContactsKey)
            UserDefaults.standard.set(nonEligibleContactsEncoded, forKey: DefaultsKeys.nonEligibleContactsKey)
            
            print("\(#fileID) : \(#function): SUCCESS : added all data structures to User Defaults")

        } catch {
            print("\(#fileID) : \(#function): Unable to Encode Array of Fetched Contacts (\(error))")
        }
        eligibleContactsButton.isHidden = false
        updateNoOfContactsButtonTitle()
        prepareNoOfQuestionsPickerData()
        enableQuiz()
    }
    
    func permissionsDenied(){
        print("\(#fileID) : \(#function): ")
        
        accessToContacts = false
        eligibleContactsButton.isHidden = true
        disableQuiz()
    }
    
    func disableQuiz(){
        print("\(#fileID) : \(#function): ")
        
        DispatchQueue.main.async {
            self.goToSettingsButton.isHidden = false
            
            self.eligibleContactsButton.alpha = 0.5
            
            self.howManyQuestionsLabel.alpha = 0.5
            
            self.noOfQuestionsPicker.alpha = 0.5
            
            self.questionTypeLabel.alpha = 0.5
            
            self.questionTypePicker.alpha = 0.5
            
            self.quizTimerLabel.alpha = 0.5
            
            self.quizTimerPicker.alpha = 0.5
            
            self.startButton.alpha = 0.5
            
            
            }
    }
    
    func enableQuiz(){
        print("\(#fileID) : \(#function): ")
        
        DispatchQueue.main.async {
            self.goToSettingsButton.isHidden = true
            
            self.eligibleContactsButton.alpha = 1.0
            
            self.howManyQuestionsLabel.alpha = 1.0
            
            self.noOfQuestionsPicker.alpha = 1.0
            
            self.questionTypeLabel.alpha = 1.0
            
            self.questionTypePicker.alpha = 1.0
            
            self.quizTimerLabel.alpha = 1.0
            
            self.quizTimerPicker.alpha = 1.0
            
            self.startButton.alpha = 1.0
            }
    }
    
    func prepareNoOfQuestionsPickerData(){
        print("\(#fileID) : \(#function): ")
        
        //let noContacts = Int.random(in: 0 ... 160)
        //print("prepareNoOfQuestionsPickerData(): noContacts = ", noContacts)
        
        let noContacts = eligibleContactsDict.count
        
        if (noContacts >= 100) {
            noOfQuestionsPickerData = ["5", "10", "25", "50", "100"]
        }
        else if (noContacts > 50 && noContacts < 100){
            noOfQuestionsPickerData = ["5", "10", "25", "50", String(noContacts)]
        }
        else if (noContacts == 50){
            noOfQuestionsPickerData = ["5", "10", "25", "50"]
        }
        else if (noContacts > 25 && noContacts < 50){
            noOfQuestionsPickerData = ["5", "10", "25", String(noContacts)]
        }
        else if (noContacts == 25){
            noOfQuestionsPickerData = ["5", "10", "25"]
        }
        else if (noContacts > 10 && noContacts < 25){
            noOfQuestionsPickerData = ["5", "10", String(noContacts)]
        }
        else if (noContacts == 10){
            noOfQuestionsPickerData = ["5", "10"]
        }
        else if (noContacts > 5 && noContacts < 10){
            noOfQuestionsPickerData = ["5", String(noContacts)]
        }
        else if (noContacts == 5){
            noOfQuestionsPickerData = ["5"]
        }
        else if (noContacts > 0 && noContacts < 5){
            noOfQuestionsPickerData = [String(noContacts)]
        }
        else {
            noOfQuestionsPickerData = []
        }
        DispatchQueue.main.async {
            self.noOfQuestionsPicker.reloadAllComponents()
        }
        
    }
    
    func updateNoOfContactsButtonTitle(){
        print("\(#fileID) : \(#function): ")
        
        if accessToContacts {
            DispatchQueue.main.async {
                self.eligibleContactsButton.setTitle("  You have " + String(self.eligibleContactsDict.count) + " eligible contacts  ", for: .normal)
            }
        }
       
    }
    
    func presentNoPermissionAlert(){
        print("\(#fileID) : \(#function): ")
        
        let dialogMessage = UIAlertController(title: "Access to Contacts Required", message: "Go to App Settings and give access to Contacts", preferredStyle: .alert)
        dialogMessage.view.tintColor = .systemIndigo
        
        // Create Settings button with action handler
        let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            self.goToSettingsButtonPressed(self)
        })
        
        // Create Cancel button with action handlder
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("\(#fileID) : \(#function): Cancel action tapped")
        }
        
        //add actions to alert
        dialogMessage.addAction(settingsAction)
        dialogMessage.addAction(cancelAction)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
}


