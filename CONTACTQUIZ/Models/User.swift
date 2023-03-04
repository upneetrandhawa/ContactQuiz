//
//  User.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-10.
//

import Foundation

public struct User : Codable {
    var name: String
    var email: String
    var password: String
    let dateJoined: Date
    
    var noOfQuizCompleted: Int
    var noOfQuestionAnswered: Int
    var noOfCorrectAnswers: Int
    var totalTimeTakenForQuizzes: Int
    
    var allQuizArray: [Quiz]
    
    var isSoundOn: Bool
    var isVibationOn: Bool
    
    var allContactsDict = [String:Contact]()//Store all Contacts. key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    var eligibleContactsDict = [String:Contact]()//Store only elibile contacts, i.e. both name and number should not be null. key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    var nonEligibleContactsDict = [String:Contact]()//Store only non-elibile contacts, i.e. etiher name or number is null.key = unique identifier of a contact as provided by apple, Value = Our custom Contact Object
    
    public mutating func addNewQuiz(_quizNoCompleted:Int,  _score:Double, _questionType:quizQuestionType,_noOfQuestions:Int, _noOfCorrectAnswers:Int, _noOfWrongAnswers:Int, _timeTakenInSeconds:Int, _date:Date, _quizTimerValue: quizTimerTypes, _quizReponses: [Question]){
        print("\(#fileID) : \(#function): ")
        
        self.allQuizArray.append(Quiz(quizNoCompleted: _quizNoCompleted,
                                      score: _score,
                                      questionType: _questionType,
                                      noOfQuestions: _noOfQuestions,
                                      noOfCorrectAnswers: _noOfCorrectAnswers,
                                      noOfWrongAnswers: _noOfWrongAnswers,
                                      timeTakenInSeconds: _timeTakenInSeconds,
                                      date: _date,
                                      quizTimerValue: _quizTimerValue,
                                      quizReponses: _quizReponses))
        
    }
    
    func updateUserData(){
        print("\(#fileID) : \(#function): ")
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let encodedUser = try encoder.encode(self)

            // Write/Set Data
            UserDefaults.standard.set(encodedUser, forKey: DefaultsKeys.userObjectKey)
            
            print("\(#fileID) : \(#function): user updated!!")

        } catch {
            print("\(#fileID) : \(#function): Unable to Encode Note (\(error))")
        }
        
    }
}
