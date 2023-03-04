//
//  QuizResultViewController.swift
//  PHONEQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-12.
//

import UIKit
import Contacts

class QuizResultViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    
    @IBOutlet weak var quizNoResultLabel: UILabel!
    @IBOutlet weak var noOfQuestionsLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeTakenLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User? = nil
    var score:Double = -0.0
    var quizNumber:Int = 0//quiz number begin from 0, this referes the index in User.allQuizArray[]
    var quiz:Quiz? = nil
    var quizResponses = [Question]()
    
    override func viewDidLoad() {
        print("\(#fileID) : \(#function): ")
        print("\(#fileID) : \(#function): totalQuizes = ", user?.allQuizArray.count)
        print("\(#fileID) : \(#function): quizNumber = ", quizNumber)
        
        guard let quiz2 = user?.allQuizArray[quizNumber] else {
            return
        }
        
        
        
        quiz = quiz2
        
        quizNoResultLabel.text = "Quiz " + String(quizNumber + 1) + " Result"
        
        quizResponses = quiz?.quizReponses ?? [Question]()
        
        if quizResponses.count < 1 {
            print("\(#fileID) : \(#function): ERROR: quizResponses null")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.presentErrorAlert(title: "No Results", msg: "You didn't answered any question")
            }
            return
        }
        
        
        noOfQuestionsLabel.text = String(quiz?.noOfQuestions ?? 0)
        score = quiz?.score ?? Double((100.00 * Double(quiz?.noOfCorrectAnswers ?? 0))/(Double(quiz?.noOfQuestions ?? 1)))
        
        scoreLabel.text = String(format: "%.2f",score) + " %"
        timeTakenLabel.text = convertQuizTimeSecondsToString()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.layer.cornerRadius = 15
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.layer.borderWidth = 10.0
        collectionView.layer.borderColor = UIColor.systemBackground.cgColor
        
        //add a menu to more button
        addMenuToMoreButton()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            collectionView.layer.borderColor = UIColor.systemBackground.cgColor
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.quizResponses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "resultsCell", for: indexPath) as! ResultsCollectionViewCell
        
        cell.questionNoLabel.text = "Question " + String(indexPath.item + 1)
        
        cell.questionLabel.text = quizResponses[indexPath.item].questionTitle
        cell.questionValueLabel.text = quizResponses[indexPath.item].questionValue
        cell.userSelectedButton.setTitle(quizResponses[indexPath.item].userSelectedOptionValue, for: .normal)
        cell.correctAnswerButton.setTitle(quizResponses[indexPath.item].correctAnswerValue, for: .normal)
        
        cell.layer.cornerRadius = 15
        cell.backgroundColor = .systemIndigo
        
        cell.userSelectedButton.layer.cornerRadius = 15
        cell.userSelectedButton.layer.borderWidth = 2
        cell.correctAnswerButton.layer.cornerRadius = 15
        cell.correctAnswerButton.layer.borderWidth = 2
        
        if self.traitCollection.userInterfaceStyle == .dark {
            cell.userSelectedButton.layer.borderColor = UIColor.white.cgColor
        }
        else {
            cell.userSelectedButton.layer.borderColor = UIColor.systemIndigo.cgColor
        }
        
        if quizResponses[indexPath.item].questionResult == .CORRECT {
            cell.userSelectedButton.layer.borderColor = UIColor.systemGreen.cgColor
        }
        else {
            cell.userSelectedButton.layer.borderColor = UIColor.systemRed.cgColor
        }
        
        cell.correctAnswerButton.layer.borderColor = UIColor.systemGreen.cgColor
        
        if quizResponses[indexPath.item].didTimerEnded {
            cell.timerButton.isHidden = false
            cell.userSelectedButton.isHidden = true
            cell.selectedTitleLabel.text = "No Selection"
            cell.selectedTitleLabel.textColor = .systemRed
        }
        else {
            self.addMenuToContactsButton(button: cell.userSelectedButton, contact: quizResponses[indexPath.item].userSelectedContact, isNoSelectionButton: false, isTimerButton: false)
        }
        
        
        self.addMenuToContactsButton(button: cell.correctAnswerButton, contact: quizResponses[indexPath.item].correctAnswerContact, isNoSelectionButton: false, isTimerButton: false)
        self.addMenuToContactsButton(button: cell.timerButton, contact: Contact(identifier: "", fullName: "", phoneNumbersArray: []), isNoSelectionButton: false, isTimerButton: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.95, height: 140.0)
    }
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        self.dismiss(animated:true, completion: nil)
    }
    
    func addMenuToContactsButton(button: UIButton, contact: Contact, isNoSelectionButton: Bool, isTimerButton: Bool){
        //print("\(#fileID) : \(#function): ")
        
        if isNoSelectionButton {
            let menu:UIMenu = UIMenu(title: "No Selection", children: [])
            button.showsMenuAsPrimaryAction = true
            button.menu = menu
            return
        }
        
        if isTimerButton {
            //print("\(#fileID) : \(#function): isTimerButton")
            
            let TimerEndedAction = UIAction(title: "Failed to answer",
                                           image: UIImage(systemName: "stopwatch")?.withTintColor(.systemRed,renderingMode: .alwaysOriginal),
                                           attributes: [.disabled],
                                           state: .off,
                                           handler: { (action) -> Void in
                                            print("\(#fileID) : \(#function): TimerEndedAction pressed")
            })
            
            let elements: [UIAction] = [TimerEndedAction]
            
            let menu:UIMenu = UIMenu(title: "Timer Ended", children: elements)
            button.showsMenuAsPrimaryAction = true
            button.menu = menu
            
            return
        }
        
        let contactName = UIAction(title: contact.fullName,
                                       image: UIImage(systemName: "person")?.withTintColor(.systemIndigo,renderingMode: .alwaysOriginal),
                                       attributes: [.disabled],
                                       state: .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): contactName pressed")
        })
        
        var elements: [UIAction] = [contactName]
        
        for phoneNumberObject in contact.phoneNumbersArray {
            
            let contactNumber = UIAction(title: phoneNumberObject.phoneNumber + " " + phoneNumberObject.label,
                                           image: UIImage(systemName: "phone")?.withTintColor(.systemIndigo,renderingMode: .alwaysOriginal),
                                           attributes: [.disabled],
                                           state: .off,
                                           handler: { (action) -> Void in
                                            print("\(#fileID) : \(#function): contactNumber pressed")
            })
            
            elements.append(contactNumber)
        }
        
        
        
        let menu:UIMenu = UIMenu(title: "Contact", children: elements)
        
        
        button.showsMenuAsPrimaryAction = true
        button.menu = menu
        
    }
    
    func addMenuToMoreButton(){
        print("\(#fileID) : \(#function): ")
        
        let appName = Bundle.main.displayName ?? "CONTACTQUIZ"
        
        let shareAction = UIAction(title: "Share",
                                       image: UIImage(systemName: "square.and.arrow.up")?.withTintColor(.systemIndigo,
                                       renderingMode: .alwaysOriginal),
                                       attributes: [],
                                       state: .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): shareAction pressed")
                                        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
                                        
                                        let message = "I scored \(String(format: "%0.2f", self.score)) %. How well do you know your contacts? Download \(appName) today!\n"
                                        //Set the link to share.
                                        if let link = NSURL(string: "http://appstore.com/")
                                        {
                                            let objectsToShare = [message,message,link] as [Any]
                                            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                                            activityVC.excludedActivityTypes = [UIActivity.ActivityType.assignToContact,
                                                                                UIActivity.ActivityType.openInIBooks,
                                                                                UIActivity.ActivityType.airDrop,
                                                                                UIActivity.ActivityType.markupAsPDF]
                                            self.present(activityVC, animated: true, completion: nil)
                                        }
            
        })
        
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
                                        self.updateUserData()
                                        self.addMenuToMoreButton()
            
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
        
        let profileAction = UIAction(title: "Profile",
                                       image: UIImage(systemName: "person")?.withTintColor(.systemIndigo,
                                       renderingMode: .alwaysOriginal),
                                       attributes: [],
                                       state: .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): profileAction pressed")
                                        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let destinationVC = storyboard.instantiateViewController(withIdentifier: "profileView") as! ProfileViewController
                                        destinationVC.user = self.user

                                        self.present(destinationVC, animated: true)
                                        
                                        
            
        })
        
        let elements: [UIAction] = [shareAction, vibrationAction, profileAction]
        
        let menu:UIMenu = UIMenu(title: "Menu", children: elements)
        
        
        moreButton.showsMenuAsPrimaryAction = true
        moreButton.menu = menu
    }
    
    func convertQuizTimeSecondsToString() -> String {
        
        guard let quizTimeSeconds = quiz?.timeTakenInSeconds else {
            return ""
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated

        let formattedQuizTimeString = formatter.string(from: TimeInterval(quizTimeSeconds))!
        
        return formattedQuizTimeString
    }
    
    func updateUserData(){
        print("\(#fileID) : \(#function): ")
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let encodedUser = try encoder.encode(user)

            // Write/Set Data
            UserDefaults.standard.set(encodedUser, forKey: DefaultsKeys.userObjectKey)
            
            print("\(#fileID) : \(#function): new user created!! and added to User Defaults")

        } catch {
            print("\(#fileID) : \(#function): : Unable to Encode Note (\(error))")
        }
        
    }
    
}
