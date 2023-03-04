//
//  QuizCollectionViewCell.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-13.
//

import UIKit

class QuizCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var quizQuestionView: UIView!
    @IBOutlet weak var questionNoLabel: UILabel!
    @IBOutlet weak var questionTimerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionValueLabel: UILabel!
    
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    
    var optionsButtons = [UIButton]()
    
    var noOfQuestions: Int?
    var questionNo: Int?
    var questionContact: Contact?
    var optionsContact = [Contact]()
    var questionType: quizQuestionType = .CONTACT_NUMBERS
    var timerValue: Int?
    
    func setup(_noOfQuestions: Int, _currentQuestionNo: Int, _questionContact: Contact, _optionsContact: [Contact], _questionType: quizQuestionType){
        
        print("\(#fileID) : \(#function)")
        
        self.noOfQuestions = _noOfQuestions
        self.questionNo = _currentQuestionNo
        self.questionContact = _questionContact
        self.optionsContact = _optionsContact
        self.questionType = _questionType
        
        
        setupViews()
        
        //add all options buttons to uour button array
        optionsButtons.append(option1Button)
        optionsButtons.append(option2Button)
        optionsButtons.append(option3Button)
        optionsButtons.append(option4Button)
        
        configureData()
        
        
    }
    
    override class func awakeFromNib() {
        print("\(#fileID) : \(#function)")
        
        //add rounding to views
        
        
    }
    
    func setupViews(){
        print("\(#fileID) : \(#function)")
        
        //add rounding to views
        self.containerView.layer.cornerRadius = 25
        self.quizQuestionView.layer.cornerRadius = 25
        self.option1Button.layer.cornerRadius = 15
        self.option2Button.layer.cornerRadius = 15
        self.option3Button.layer.cornerRadius = 15
        self.option4Button.layer.cornerRadius = 15
        
        //set border width for buttons
        self.option1Button.layer.borderWidth = 2
        self.option2Button.layer.borderWidth = 2
        self.option3Button.layer.borderWidth = 2
        self.option4Button.layer.borderWidth = 2
        
        //add border color to buttons
        self.option1Button.layer.borderColor = UIColor.systemIndigo.cgColor
        self.option2Button.layer.borderColor = UIColor.systemIndigo.cgColor
        self.option3Button.layer.borderColor = UIColor.systemIndigo.cgColor
        self.option4Button.layer.borderColor = UIColor.systemIndigo.cgColor
        
        //add shadow to containerView view
        self.containerView.layer.shadowColor = UIColor.systemGray5.cgColor
        self.containerView.layer.shadowOpacity = 1.0
        self.containerView.layer.shadowOffset = .zero
        self.containerView.layer.shadowRadius = 5
        
        //add shadow to quizQuestionView view
        self.quizQuestionView.layer.shadowColor = UIColor.systemIndigo.cgColor
        self.quizQuestionView.layer.shadowOpacity = 0.8
        self.quizQuestionView.layer.shadowOffset = .zero
        self.quizQuestionView.layer.shadowRadius = 7
    }
    
    func configureData(){
        print("\(#fileID) : \(#function)")
        
        //get what should be the question and its value
        print("\(#fileID) : \(#function): currentQuestionType2 SWITCH case : ", questionType)
        guard let questionContact = questionContact else {
            return
        }
        switch questionType {
        case .CONTACT_NUMBERS:
            questionLabel.text = QuestionTitles.forContactName
            let randPhoneNumberIndexToChoose = Int.random(in: 0..<questionContact.phoneNumbersArray.count)
            questionValueLabel.text = questionContact.phoneNumbersArray[randPhoneNumberIndexToChoose].phoneNumber
        case .CONTACT_NAMES:
            questionLabel.text = QuestionTitles.forContactNumber
            questionValueLabel.text = questionContact.fullName
        
        default:
            print("\(#fileID) : \(#function): switch : default, shouldn't be here")
        }
        
        //add values to our options
        for (index,button) in optionsButtons.enumerated() {
            print("\(#fileID) : \(#function): assigning values to button : ", index)
            
            switch questionType {
            case .CONTACT_NUMBERS:
                button.setTitle(optionsContact[index].fullName, for: .normal)
            case .CONTACT_NAMES:
                let randPhoneNumberIndexToChoose = Int.random(in: 0..<optionsContact[index].phoneNumbersArray.count)
                button.setTitle(optionsContact[index].phoneNumbersArray[randPhoneNumberIndexToChoose].phoneNumber, for: .normal)
            
            default:
                print("\(#fileID) : \(#function): switch : default, shouldn't be here")
            }
            
            button.layer.shadowColor = UIColor.clear.cgColor
            button.layer.shadowOpacity = 0.0
            button.layer.shadowOffset = .zero
            button.layer.shadowRadius = 0
        }
        
        //update view
        questionNoLabel.text = "Question " + String((questionNo ?? 0) + 1) + " / " + String(noOfQuestions ?? 0)
    }
    
    override func prepareForReuse() {
        print("\(#fileID) : \(#function)")
        
        questionNo = nil
        questionContact = nil
        optionsContact = [Contact]()
        questionLabel.text = ""
        questionValueLabel.text = ""
        questionTimerLabel.text = ""
        
        for button in optionsButtons {
            button.removeTarget(nil, action: nil, for: .allEvents)
        }
        optionsButtons = [UIButton]()
    }
    
    
}
