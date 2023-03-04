//
//  QuizViewController.swift
//  PHONEQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-12.

import UIKit
import AVFoundation

class QuizViewController: UIViewController {
    
    
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    
    
    @IBOutlet weak var questionsProgressLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionValueLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var closeQuizButton: UIButton!
    @IBOutlet weak var preferencesButton: UIButton!
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var nextSubmitSeeResultsButton: UIButton!
    
    var optionsButtons = [UIButton]()
    
    weak var homeViewControllerDelegate: HomeViewController?
    
    //data structures
    var contacts = [Contact]()//array containing all eligible contacts
    var quizQuestionsContacts = [Contact]()//array containing all quiz questions contacts
    var quizResponses = [Question]()//array containing responses of each question
    var eligibleContactsDict = [String:Contact]()//Store only elibile contacts, i.e. both name and number should not be null. key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    
    var currentQuestionAnswerOptionsIndexForContactsArray = [Int]()//array containing indexes of options relative to the array contacts for the current Question
    var currentQuestionAnswerOptionsContacts = [Contact]()//array containing question options contacts for the current Question
    var quizCorrectAnswersContacts = [Contact]()//array containing correct answer contacts for the whole quiz
    var quizUserAnsweredContacts = [Contact]()//array containing user selected answer contacts for the whole quiz
    
    var quizQuestionTypesSelected:quizQuestionType = .CONTACT_NUMBERS
    var currentQuestionType:quizQuestionType = .CONTACT_NUMBERS
    
    var noOfQuestions:Int = 0
    var currentQuestionNo:Int = -1//start from 0..<noOfQuestions
    var currentQuestionCorrectOptionIndex:Int = -1//
    var optionSelected:Int = 0 // 0 for none, 1 for option 1 etc
    
    var currentQuestionTitle = ""
    var currentQuestionValueTitle = ""
    var currentQuestionCorrectAnswerContact = Contact(identifier: "", fullName: "", phoneNumbersArray: [])
    var currentQuestionUserSelectedAnswerContact = Contact(identifier: "", fullName: "", phoneNumbersArray: [])
    
    var score:Int = 0
    var noOfRightAnswers:Int = 0
    var noOfWrongAnswers:Int = 0
    
    var quizEnded = false
    var quizStartTime = Date()
    
    var quizTimerSelected: quizTimerTypes = quizTimerTypes(rawValue: 0) ?? .NO_TIMER
    var timer = Timer()
    var timerValue = -1
    
    var user: User? = nil
    let userDefaults = UserDefaults.standard
 
    override func viewDidLoad() {
        print("\(#fileID) : \(#function): contacts count = ", eligibleContactsDict.count, ", no of quiz questions = ", noOfQuestions)
        
        //add rounding to views
        self.topBackgroundView.layer.cornerRadius = 25
        self.bottomBackgroundView.layer.cornerRadius = 35
        self.option1Button.layer.cornerRadius = 15
        self.option2Button.layer.cornerRadius = 15
        self.option3Button.layer.cornerRadius = 15
        self.option4Button.layer.cornerRadius = 15
        self.nextSubmitSeeResultsButton.layer.cornerRadius = 15
        
        //set border width for buttons
        self.option1Button.layer.borderWidth = 2
        self.option2Button.layer.borderWidth = 2
        self.option3Button.layer.borderWidth = 2
        self.option4Button.layer.borderWidth = 2
        self.nextSubmitSeeResultsButton.layer.borderWidth = 2
        
        //add border color to buttons
        self.option1Button.layer.borderColor = UIColor.systemIndigo.cgColor
        self.option2Button.layer.borderColor = UIColor.systemIndigo.cgColor
        self.option3Button.layer.borderColor = UIColor.systemIndigo.cgColor
        self.option4Button.layer.borderColor = UIColor.systemIndigo.cgColor
        self.nextSubmitSeeResultsButton.layer.borderColor = UIColor.systemIndigo.cgColor
        
        //add shadow to top background view
        self.topBackgroundView.layer.shadowColor = UIColor.systemIndigo.cgColor
        self.topBackgroundView.layer.shadowOpacity = 0.8
        self.topBackgroundView.layer.shadowOffset = .zero
        self.topBackgroundView.layer.shadowRadius = 7
        
        //add all options buttons to uour button array
        optionsButtons.append(option1Button)
        optionsButtons.append(option2Button)
        optionsButtons.append(option3Button)
        optionsButtons.append(option4Button)
        
        //add a menu to preferences button
        addMenuToPreferencesButton()
        
        contacts = eligibleContactsDict.values.map({$0})
        
        print("\(#fileID) : \(#function): contacts2 count = ",contacts.count)
        
        beginQuiz()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("\(#fileID) : \(#function): ")
        
        super.viewWillDisappear(animated)
        
        print("\(#fileID) : \(#function): isBeingDismissed = ",isBeingDismissed)
        
        if isBeingDismissed {
            
            closeQuizButtonPressed(self)
        }
        
    }
    
    @IBAction func closeQuizButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .heavy)
        
        if !quizEnded {//confirm with user if quiz aint finished
            let dialogMessage = UIAlertController(title: "Alert", message: "Do you want to quit the quiz?", preferredStyle: .alert)
            dialogMessage.view.tintColor = .systemIndigo
            
            // Create Yes button with action handler
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                print("\(#fileID) : \(#function): yesAction pressed")
                self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .heavy)
                self.dismiss(animated:true, completion: nil)
            })
            
            // Create No button with action handlder
            let noAction = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                print("\(#fileID) : \(#function): noAction pressed")
                self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
            }
            
            //add actions to alert
            dialogMessage.addAction(noAction)
            dialogMessage.addAction(yesAction)
            
            self.present(dialogMessage, animated: true, completion: nil)
        }
        else {//close current view controller if quiz is finished
            self.dismiss(animated:true, completion: nil)
        }
        
    }
    
    @IBAction func option1ButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.Option1.rawValue])
        highlightCurrentSelectedOption(selectedOption:1)
    }
    
    @IBAction func option2ButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.Option2.rawValue])
        highlightCurrentSelectedOption(selectedOption:2)
    }
    
    @IBAction func option3ButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.Option3.rawValue])
        highlightCurrentSelectedOption(selectedOption:3)
    }
    
    @IBAction func option4ButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.Option4.rawValue])
        highlightCurrentSelectedOption(selectedOption:4)
    }
    
    
    @IBAction func nextSubmitSeeResultsButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        
        switch nextSubmitSeeResultsButton.title(for: .normal) {
        
        case ButtonTitles.submit:
            print("\(#fileID) : \(#function): ",ButtonTitles.submit)
            validateAnswer()//check the correctness of the selected option
            resetTimer()//reset the question timer
        case ButtonTitles.next:
            print("\(#fileID) : \(#function): ",ButtonTitles.next)
            updateViewWithQuestion2()//push next question
        case ButtonTitles.seeResults:
            print("\(#fileID) : \(#function): ",ButtonTitles.seeResults)
            seeResults()//launch new vc showing the results
        default:
            print("\(#file) : \(#function): shouldn't be here")
        }
    }
    
    func highlightCurrentSelectedOption(selectedOption:Int){
        print("\(#fileID) : \(#function): selectedOption = " + String(selectedOption))
        
        if optionSelected != selectedOption {//user selected a different option than previous
            
            if optionSelected != 0 {//user previously selected an option
                //remove shadow attributes from the previous selected option
                optionsButtons[optionSelected-1].layer.shadowColor = UIColor.clear.cgColor
                optionsButtons[optionSelected-1].layer.shadowOpacity = 0.0
                optionsButtons[optionSelected-1].layer.shadowOffset = .zero
                optionsButtons[optionSelected-1].layer.shadowRadius = 0
            }
            
            optionSelected = selectedOption
            //apply shadow attributes to the current selected option
            optionsButtons[optionSelected-1].layer.shadowColor = UIColor.systemIndigo.cgColor
            optionsButtons[optionSelected-1].layer.shadowOpacity = 0.8
            optionsButtons[optionSelected-1].layer.shadowOffset = .zero
            optionsButtons[optionSelected-1].layer.shadowRadius = 7
            
        }
        
        nextSubmitSeeResultsButton.isHidden = false
    }
    
    func addMenuToPreferencesButton(){
        print("\(#fileID) : \(#function): ")
        
        //Action to set vibrations
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
        
        let soundAction = UIAction(title: String("Sound"),
                                       image: UIImage(systemName: "speaker.zzz")?.withTintColor(.systemIndigo,
                                       renderingMode: .alwaysOriginal),
                                       attributes: [],
                                       state: (self.user?.isSoundOn ?? true) ? .on : .off,
                                       handler: { (action) -> Void in
                                        print("\(#fileID) : \(#function): soundAction pressed")
                                        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)

                                        let beforeVal = self.user?.isSoundOn ?? true
                                        print("\(#fileID) : \(#function): soundAction pressed : before isSoundOn = " + String(beforeVal))
                                        self.user?.isSoundOn = !(beforeVal)
                                        print("\(#fileID) : \(#function): soundAction pressed : after isSoundOn = " + String(self.user?.isSoundOn ?? true))
                                        
                                        
                                        self.user?.updateUserData()
                                        self.checkForAudioPlaying()
                                        self.addMenuToPreferencesButton()

        })
        
        let elements: [UIAction] = [vibrationAction, soundAction]
        let menu:UIMenu = UIMenu(title: "Preferences", children: elements)
        
        preferencesButton.showsMenuAsPrimaryAction = true
        preferencesButton.menu = menu
    }
   
    
    func beginQuiz(){
        print("\(#fileID) : \(#function): ")
        
        quizEnded = false
        user?.updateUserData()
        prepareQuizQuestionsArray()
        updateViewWithQuestion2()
        quizStartTime = Date()
    }
    
    func prepareQuizQuestionsArray(){
        print("\(#fileID) : \(#function): ")
        
        let shuffleContacts = contacts.shuffled()
        quizQuestionsContacts = Array(shuffleContacts[0...noOfQuestions-1])
        print("\(#fileID) : \(#function): quizQuestions2 = ", quizQuestionsContacts)
        
        
    }
    
    func updateViewWithQuestion2(){
        print("\(#fileID) : \(#function): ")
        
        currentQuestionNo += 1
        
        currentQuestionAnswerOptionsIndexForContactsArray = (1...4).map( {_ in Int.random(in: 0...contacts.count-1)} )//generate 4 random numbers which will be an index in contacts array
        print("\(#fileID) : \(#function): currentQuestionAnswerOptionsIndexForContactsArray = ", currentQuestionAnswerOptionsIndexForContactsArray)
        print("\(#fileID) : \(#function): contacts2 count = ", contacts.count)
        currentQuestionAnswerOptionsContacts = [Contact]()
        for index in currentQuestionAnswerOptionsIndexForContactsArray {
            currentQuestionAnswerOptionsContacts.append(contacts[index])//append the options to our array
        }
        
        currentQuestionCorrectOptionIndex = Int.random(in: 0..<4)//choose any spot between 0 and 4 for our correct answer
        
        currentQuestionAnswerOptionsContacts[currentQuestionCorrectOptionIndex] = quizQuestionsContacts[currentQuestionNo]//replace the element with our correct answer
        
        var randQuestionTypeToChooseForQuestionTypeBoth = -1 //to chose random bw question type CONTACT_NUMBERS or CONTACT_NUMBERS for case 2 i.e. both
        
        currentQuestionTitle = ""
        currentQuestionValueTitle = ""
        
        if quizQuestionTypesSelected == .BOTH {//in this case we have to randomly choose between .CONTACT_NUMBERS and .CONTACT_NUMBERS
            randQuestionTypeToChooseForQuestionTypeBoth = Int.random(in: 0...1)
            currentQuestionType = quizQuestionType(rawValue: randQuestionTypeToChooseForQuestionTypeBoth) ?? .CONTACT_NUMBERS
        }
        else {
            currentQuestionType = quizQuestionTypesSelected
        }
        
        //get what should be the question and its value
        print("\(#fileID) : \(#function): currentQuestionType2 SWITCH case : ", currentQuestionType)
        switch currentQuestionType {
        case .CONTACT_NUMBERS:
            currentQuestionTitle = QuestionTitles.forContactName
            let randPhoneNumberIndexToChoose = Int.random(in: 0..<quizQuestionsContacts[currentQuestionNo].phoneNumbersArray.count)
            currentQuestionValueTitle = quizQuestionsContacts[currentQuestionNo].phoneNumbersArray[randPhoneNumberIndexToChoose].phoneNumber
        case .CONTACT_NAMES:
            currentQuestionTitle = QuestionTitles.forContactNumber
            currentQuestionValueTitle = quizQuestionsContacts[currentQuestionNo].fullName
        
        default:
            print("\(#fileID) : \(#function): switch : default, shouldn't be here")
        }
        
        //add values to our options
        for (index,button) in optionsButtons.enumerated() {
            print("\(#fileID) : \(#function): assigning values to button : ", index)
            
            switch currentQuestionType {
            case .CONTACT_NUMBERS:
                button.setTitle(currentQuestionAnswerOptionsContacts[index].fullName, for: .normal)
            case .CONTACT_NAMES:
                let randPhoneNumberIndexToChoose = Int.random(in: 0..<currentQuestionAnswerOptionsContacts[index].phoneNumbersArray.count)
                button.setTitle(currentQuestionAnswerOptionsContacts[index].phoneNumbersArray[randPhoneNumberIndexToChoose].phoneNumber, for: .normal)
            
            default:
                print("\(#fileID) : \(#function): switch : default, shouldn't be here")
            }
            
            button.layer.shadowColor = UIColor.clear.cgColor
            button.layer.shadowOpacity = 0.0
            button.layer.shadowOffset = .zero
            button.layer.shadowRadius = 0
        }
        
        //update view
        questionsProgressLabel.text = "Question " + String(currentQuestionNo+1) + " / " + String(noOfQuestions)
        questionLabel.text = currentQuestionTitle
        questionValueLabel.text = currentQuestionValueTitle
        
        optionSelected = 0
        self.option1Button.isUserInteractionEnabled = true
        self.option2Button.isUserInteractionEnabled = true
        self.option3Button.isUserInteractionEnabled = true
        self.option4Button.isUserInteractionEnabled = true
        
        nextSubmitSeeResultsButton.setTitle(ButtonTitles.submit, for: .normal)
        nextSubmitSeeResultsButton.isHidden = true
        
        startTimer()
    }
    
    func validateAnswer(){
        print("\(#fileID) : \(#function): question number = ", currentQuestionNo)
        //check if selected option is correct
//        if quizQuestions[currentQuestionNo-1].fullName == contacts[answerOptionsIndexForContactsArray[optionSelected-1]].fullName'
        
        var questionResult = questionResultType.INCORRECT
        
        if currentQuestionAnswerOptionsContacts[optionSelected-1].identifier == quizQuestionsContacts[currentQuestionNo].identifier
        {
            //correct answer
            
            
            self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .medium)
            
            //highlight correct answer
            optionsButtons[optionSelected-1].layer.shadowColor = UIColor.systemGreen.cgColor
            optionsButtons[optionSelected-1].layer.shadowOpacity = 0.8
            optionsButtons[optionSelected-1].layer.shadowOffset = .zero
            optionsButtons[optionSelected-1].layer.shadowRadius = 7
            
            if timerValue == 0 {
                print("\(#fileID) : \(#function): Timer ended")
                noOfWrongAnswers += 1
                self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.WrongAnswer.rawValue])
            }
            else {
                noOfRightAnswers += 1
                print("\(#fileID) : \(#function): correct")
                questionResult = questionResultType.CORRECT
                self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.CorrectAnswer.rawValue])
            }
           
        }
        else {
            print("\(#fileID) : \(#function): wrong")
            
            self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .heavy)
            
            
            //highlight correct answer
            optionsButtons[currentQuestionCorrectOptionIndex].layer.shadowColor = UIColor.systemGreen.cgColor
            optionsButtons[currentQuestionCorrectOptionIndex].layer.shadowOpacity = 0.8
            optionsButtons[currentQuestionCorrectOptionIndex].layer.shadowOffset = .zero
            optionsButtons[currentQuestionCorrectOptionIndex].layer.shadowRadius = 7
            
            //highlight wrong answer
            optionsButtons[optionSelected-1].layer.shadowColor = UIColor.systemRed.cgColor
            optionsButtons[optionSelected-1].layer.shadowOpacity = 0.8
            optionsButtons[optionSelected-1].layer.shadowOffset = .zero
            optionsButtons[optionSelected-1].layer.shadowRadius = 7
            
            noOfWrongAnswers += 1
            self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.WrongAnswer.rawValue])
        }
        
        quizResponses.append(Question(questionType: currentQuestionType,
                                       questionTitle: currentQuestionTitle,
                                       questionValue: currentQuestionValueTitle,
                                       correctAnswerValue: optionsButtons[currentQuestionCorrectOptionIndex].title(for: .normal) ?? "",
                                       userSelectedOptionValue: (timerValue == 0) ? "No Selection" : optionsButtons[optionSelected-1].title(for: .normal) ?? "",
                                       correctAnswerContact: quizQuestionsContacts[currentQuestionNo],
                                       userSelectedContact: (timerValue == 0) ? Contact(identifier: "", fullName: "", phoneNumbersArray: []) : currentQuestionAnswerOptionsContacts[optionSelected-1],
                                       didTimerEnded: timerValue == 0,
                                       questionResult: questionResult))
        
        self.option1Button.isUserInteractionEnabled = false
        self.option2Button.isUserInteractionEnabled = false
        self.option3Button.isUserInteractionEnabled = false
        self.option4Button.isUserInteractionEnabled = false
        
        
        if currentQuestionNo + 1 == noOfQuestions {
            nextSubmitSeeResultsButton.setTitle(ButtonTitles.seeResults, for: .normal)
            quizCompleted()
        }
        else {
            nextSubmitSeeResultsButton.setTitle(ButtonTitles.next, for: .normal)
        }
    }
    
    func quizTimerEnded(){
        print("\(#fileID) : \(#function): ")
        
        //select correct answer
        optionsButtons[currentQuestionCorrectOptionIndex].sendActions(for: .touchUpInside)
        
        //submit answer
        nextSubmitSeeResultsButtonPressed(self)
    }
    
    func seeResults(){
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .light)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "QuizResultView") as! QuizResultViewController
        destinationVC.user = user
        destinationVC.quizNumber = (user?.noOfQuizCompleted ?? 1) - 1
        
        self.present(destinationVC, animated: true)
        
    }
    
    func quizCompleted(){
        print("\(#fileID) : \(#function): ")
        let currentQuizTimeTakenSeconds = Int(Date().timeIntervalSince(quizStartTime))
        
        user?.noOfQuizCompleted += 1
        user?.noOfQuestionAnswered += quizQuestionsContacts.count
        user?.noOfCorrectAnswers += noOfRightAnswers
        user?.totalTimeTakenForQuizzes += currentQuizTimeTakenSeconds
        
        let currentNoOfQuizCompleted = user?.noOfQuizCompleted ?? 0
        
        user?.addNewQuiz(_quizNoCompleted: currentNoOfQuizCompleted,
                         _score: 100.00*Double(Double(noOfRightAnswers)/Double(quizQuestionsContacts.count)),
                         _questionType: quizQuestionTypesSelected,
                         _noOfQuestions: quizQuestionsContacts.count,
                         _noOfCorrectAnswers: noOfRightAnswers,
                         _noOfWrongAnswers: noOfWrongAnswers,
                         _timeTakenInSeconds: currentQuizTimeTakenSeconds,
                         _date: Date(),
                         _quizTimerValue: quizTimerSelected,
                         _quizReponses: quizResponses)
        //updateUserData()
        user?.updateUserData()
        print("\(#fileID) : \(#function): noOfQuizzes = ", user?.noOfQuizCompleted)
        quizEnded = true
        
        //print("\(#fileID) : \(#function): user = " + user.debugDescription)
    }
    
    func startTimer(){
        print("\(#fileID) : \(#function): ")
        
        if quizTimerSelected == .NO_TIMER {
            print("\(#fileID) : \(#function): No Timer")
            return
        }
        
        timerValue = quizTimerSelected.rawValue
        print("\(#fileID) : \(#function): timerValue = " + String(timerValue))
        
        timerLabel.text = String(format: "%02d", timerValue)
        timerLabel.textColor = .systemIndigo
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(_ timer: Timer){
        print("\(#fileID) : \(#function): timerValue: " + String(timerValue))
        
        if timerValue < 1 {
            //stop timer
            self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .heavy)
            timer.invalidate()
            quizTimerEnded()
            return
        }
        
        if timerValue < 5 { //start a countdown with viration and change timer color to red
            timerLabel.textColor = .systemRed
            self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        }
        
        
        timerValue -= 1
        timerLabel.text = String(format: "%02d", timerValue)
    }
    
    func resetTimer(){
        print("\(#fileID) : \(#function): ")
        timer.invalidate()
    }
    
    var player: AVAudioPlayer?
    
    func checkForAudioPlaying(){
        print("\(#fileID) : \(#function): ")
        
        if let isSoundOn = user?.isSoundOn {
            print("\(#fileID) : \(#function): isSoundOn = ", isSoundOn)
            
            guard let player = player else { return }
            
            if !isSoundOn {
                player.stop()
            }
            else{
                player.play()
            }
        }
        
        
        
    }
    
    func playSound(fileName: String){
        
        print("\(#fileID) : \(#function): fileName = ", fileName)
        
        if let isSoundOn = user?.isSoundOn {
            print("\(#fileID) : \(#function): isSoundOn = ", isSoundOn)
            
            if !isSoundOn {
                return
            }
        }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "aif") else { return }

        print("\(#fileID) : \(#function): url = ", url)
        
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)

                /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.aiff.rawValue)
                
                

                /* iOS 10 and earlier require the following line:
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

                guard let player = player else { return }

                player.play()

            } catch let error {
                print("\(#fileID) : \(#function): ",error.localizedDescription)
            }
    }
    
}
