//
//  QuizTestViewController.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-12.
//

import UIKit
import AVFoundation

class QuizTestViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    
    @IBOutlet weak var quizCollectionView: UICollectionView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var nextSubmitSeeResultsButton: UIButton!
    
    weak var homeViewControllerDelegate: HomeViewController?
    
    var optionsButtons = [UIButton]()
    
    var user: User? = nil
    let userDefaults = UserDefaults.standard
    
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
    var currentQuestionTimerLabel: UILabel?//var which stores the current label for storing timer value
    
    var score:Int = 0
    var noOfRightAnswers:Int = 0
    var noOfWrongAnswers:Int = 0
    
    var quizEnded = false
    var quizStartTime = Date()
    
    var quizTimerSelected: quizTimerTypes = quizTimerTypes(rawValue: 0) ?? .NO_TIMER
    var timer = Timer()
    var timerValue = -1
    
    let quizCellIdentifier = "quizCell"
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(#fileID) : \(#function)")

        // Do any additional setup after loading the view.
        quizCollectionView.delegate = self
        quizCollectionView.dataSource = self
        quizCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        //add rounding to views
        self.nextSubmitSeeResultsButton.layer.cornerRadius = 15
        
        //set border width for buttons
        self.nextSubmitSeeResultsButton.layer.borderWidth = 2
        
        //add border color to buttons
        self.nextSubmitSeeResultsButton.layer.borderColor = UIColor.systemIndigo.cgColor
        
        //add a menu to preferences button
        addMenuToPreferencesButton()
         
        contacts = eligibleContactsDict.values.map({$0})
        
        print("\(#fileID) : \(#function): contacts count = ",contacts.count)
        
        beginQuiz()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("\(#fileID) : \(#function): ")
        
        super.viewWillDisappear(animated)
        
        print("\(#fileID) : \(#function): isBeingDismissed = ",isBeingDismissed)
        
        if isBeingDismissed {
            
            closeButtonPressed(self)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
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
    
    @IBAction func nextSubmitSeeResultsButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        
        switch nextSubmitSeeResultsButton.title(for: .normal) {
        
        case ButtonTitles.submit:
            print("\(#fileID) : \(#function): ",ButtonTitles.submit)
            validateAnswer()//check the correctness of the selected option
            resetTimer()//reset the question timer
        case ButtonTitles.next:
            print("\(#fileID) : \(#function): ",ButtonTitles.next)
            nextButtonPressed()
        case ButtonTitles.seeResults:
            print("\(#fileID) : \(#function): ",ButtonTitles.seeResults)
            seeResults()//launch new vc showing the results
        default:
            print("\(#file) : \(#function): shouldn't be here")
        }
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(#fileID) : \(#function)")
        return noOfQuestions
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("\(#fileID) : \(#function): item = ", indexPath.item)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: quizCellIdentifier, for: indexPath) as! QuizCollectionViewCell
        
        return cell
    }
    var currentQuestionDisplayNo: Int?
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("\(#fileID) : \(#function): item = ", indexPath.item)
        
        currentQuestionDisplayNo = indexPath.item
        
        let cell = cell as! QuizCollectionViewCell
        
        currentQuestionAnswerOptionsIndexForContactsArray = (1...4).map( {_ in Int.random(in: 0...contacts.count-1)} )//generate 4 random numbers which will be an index in contacts array
        //print("\(#fileID) : \(#function): currentQuestionAnswerOptionsIndexForContactsArray = ", currentQuestionAnswerOptionsIndexForContactsArray)
        //print("\(#fileID) : \(#function): contacts2 count = ", contacts.count)
        currentQuestionAnswerOptionsContacts = [Contact]()
        for index in currentQuestionAnswerOptionsIndexForContactsArray {
            currentQuestionAnswerOptionsContacts.append(contacts[index])//append the options to our array
        }
        
        currentQuestionCorrectOptionIndex = Int.random(in: 0..<4)//choose any spot between 0 and 4 for our correct answer
        
        currentQuestionAnswerOptionsContacts[currentQuestionCorrectOptionIndex] = quizQuestionsContacts[indexPath.item]//replace the element with our correct answer
        
        var randQuestionTypeToChooseForQuestionTypeBoth = -1 //to chose random bw question type CONTACT_NUMBERS or CONTACT_NUMBERS for case 2 i.e. both
        
        if quizQuestionTypesSelected == .BOTH {//in this case we have to randomly choose between .CONTACT_NUMBERS and .CONTACT_NUMBERS
            randQuestionTypeToChooseForQuestionTypeBoth = Int.random(in: 0...1)
            currentQuestionType = quizQuestionType(rawValue: randQuestionTypeToChooseForQuestionTypeBoth) ?? .CONTACT_NUMBERS
        }
        else {
            currentQuestionType = quizQuestionTypesSelected
        }
        
        cell.setup(_noOfQuestions: noOfQuestions,
                   _currentQuestionNo: indexPath.item,
                   _questionContact: quizQuestionsContacts[indexPath.item],
                   _optionsContact: currentQuestionAnswerOptionsContacts,
                   _questionType: currentQuestionType)
        
        currentQuestionNo = indexPath.item
        currentQuestionTitle = cell.questionLabel.text ?? ""
        currentQuestionValueTitle = cell.questionValueLabel.text ?? ""
        currentQuestionTimerLabel = cell.questionTimerLabel
        
        optionsButtons = [UIButton]()
        
        //add action trigger for buttons
        cell.option1Button.addTarget(self, action: #selector(option1ButtonPressed), for: .touchUpInside)
        cell.option2Button.addTarget(self, action: #selector(option2ButtonPressed), for: .touchUpInside)
        cell.option3Button.addTarget(self, action: #selector(option3ButtonPressed), for: .touchUpInside)
        cell.option4Button.addTarget(self, action: #selector(option4ButtonPressed), for: .touchUpInside)
        
        optionsButtons.append(cell.option1Button)
        optionsButtons.append(cell.option2Button)
        optionsButtons.append(cell.option3Button)
        optionsButtons.append(cell.option4Button)
        
        for button in optionsButtons {
            button.isUserInteractionEnabled = true
        }
        
        prepareForNextQuestion()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.95 , height: collectionView.frame.height)
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
        
        moreButton.showsMenuAsPrimaryAction = true
        moreButton.menu = menu
    }
    
    @objc func option1ButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.Option1.rawValue])
        highlightCurrentSelectedOption(selectedOption:1)
    }
    
    @objc func option2ButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.Option2.rawValue])
        highlightCurrentSelectedOption(selectedOption:2)
    }
    
    @objc func option3ButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.Option3.rawValue])
        highlightCurrentSelectedOption(selectedOption:3)
    }
    
    @objc func option4ButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .light)
        self.playSound(fileName: soundTypesFileNamesStringArray[soundTypes.Option4.rawValue])
        highlightCurrentSelectedOption(selectedOption:4)
    }
    
    func beginQuiz(){
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        quizEnded = false
        user?.updateUserData()
        prepareQuizQuestionsArray()
        //prepareForNextQuestion()
        quizStartTime = Date()
    }
    
    func prepareQuizQuestionsArray(){
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        let shuffleContacts = contacts.shuffled()
        
        quizQuestionsContacts = Array(shuffleContacts[0...noOfQuestions-1])
        //print("\(#fileID) : \(#function): quizQuestions2 = ", quizQuestionsContacts)
    }
    
    func nextButtonPressed(){
        print("\(#fileID) : \(#function): currentQuestionNo = ", currentQuestionNo)
        
        //currentQuestionNo += 1
        //print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        
        if currentQuestionNo < noOfQuestions{
            quizCollectionView.scrollToItem(at: IndexPath(item: currentQuestionNo + 1, section: 0), at: .centeredHorizontally, animated: true)
        }
        
    }
    
    func prepareForNextQuestion(){
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        
        print("\(#fileID) : \(#function): next QuestionNo = ",currentQuestionNo)
        
        optionSelected = 0
        
        nextSubmitSeeResultsButton.setTitle(ButtonTitles.submit, for: .normal)
        nextSubmitSeeResultsButton.isHidden = true
        
        startTimer()
        
        
    }
    
    func validateAnswer(){
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        print("\(#fileID) : \(#function): optionSelected = ", optionSelected)
        
        var questionResult = questionResultType.INCORRECT
        
        if currentQuestionAnswerOptionsContacts[optionSelected-1].identifier == quizQuestionsContacts[currentQuestionNo].identifier
        {
            //correct answer
            
            
            self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .medium)
            print("\(#fileID) : \(#function): optionsButtons count = ", optionsButtons.count)
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
            
            print("\(#fileID) : \(#function): correct option = ",currentQuestionCorrectOptionIndex + 1)
            
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
        
        for button in optionsButtons {
            button.isUserInteractionEnabled = false
        }
        
        if currentQuestionNo + 1 == noOfQuestions {
            nextSubmitSeeResultsButton.setTitle(ButtonTitles.seeResults, for: .normal)
            quizCompleted()
        }
        else {
            nextSubmitSeeResultsButton.setTitle(ButtonTitles.next, for: .normal)
        }
    }
    
    func quizCompleted(){
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
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
    
    func seeResults(){
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .light)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "QuizResultView") as! QuizResultViewController
        destinationVC.user = user
        destinationVC.quizNumber = (user?.noOfQuizCompleted ?? 1) - 1
        
        self.present(destinationVC, animated: true)
        
    }
    
    func startTimer(){
        print("\(#fileID) : \(#function): currentQuestioNo = ", currentQuestionNo)
        
        if quizTimerSelected == .NO_TIMER {
            print("\(#fileID) : \(#function): No Timer")
            return
        }
        
        timerValue = quizTimerSelected.rawValue
        print("\(#fileID) : \(#function): timerValue = " + String(timerValue))
        
        guard let currentQuestionTimerLabel = currentQuestionTimerLabel else {
            print("\(#fileID) : \(#function): error unwrapping currentQuestionTimerLabel")
            return
        }
        currentQuestionTimerLabel.text = String(format: "%02d", timerValue)
        currentQuestionTimerLabel.textColor = .systemIndigo
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(_ timer: Timer){
        print("\(#fileID) : \(#function): timerValue: " + String(timerValue))
        
        guard let currentQuestionTimerLabel = currentQuestionTimerLabel else {
            print("\(#fileID) : \(#function): error unwrapping currentQuestionTimerLabel")
            return
        }
        
        if timerValue < 1 {
            //stop timer
            self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .heavy)
            timer.invalidate()
            quizTimerEnded()
            return
        }
        
        if timerValue < 5 { //start a countdown with viration and change timer color to red
            currentQuestionTimerLabel.textColor = .systemRed
            self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        }
        
        
        timerValue -= 1
        currentQuestionTimerLabel.text = String(format: "%02d", timerValue)
    }
    
    func resetTimer(){
        print("\(#fileID) : \(#function): ")
        
        timer.invalidate()
    }
    
    func quizTimerEnded(){
        print("\(#fileID) : \(#function): currentQuestionNo = ",currentQuestionNo)
        
        //select correct answer
        optionsButtons[currentQuestionCorrectOptionIndex].sendActions(for: .touchUpInside)
        
        //submit answer
        nextSubmitSeeResultsButtonPressed(self)
    }
    
    
    //Helpers
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
    
    
    
    func checkForAudioPlaying(){
        print("\(#fileID) : \(#function): ")
        
        if let isSoundOn = user?.isSoundOn {
            print("\(#fileID) : \(#function): isSoundOn = ", isSoundOn)
            
            guard let player = player else { return }
            
            player.volume = (isSoundOn) ? 1.0 : 0.0
        }
    }
    
    func playSound(fileName: String){
        
        //print("\(#fileID) : \(#function): fileName = ", fileName)
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "aif") else { return }

        //print("\(#fileID) : \(#function): url = ", url)
        
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)

                /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.aiff.rawValue)

                /* iOS 10 and earlier require the following line:
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

                guard let player = player else { return }
                
                if let isSoundOn = user?.isSoundOn {
                    print("\(#fileID) : \(#function): isSoundOn = ", isSoundOn)

                    player.volume = (isSoundOn) ? 1.0 : 0.0
                }

                player.play()

            } catch let error {
                print("\(#fileID) : \(#function): ",error.localizedDescription)
            }
    }
}
