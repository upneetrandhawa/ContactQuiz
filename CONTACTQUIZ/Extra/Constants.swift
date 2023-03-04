//
//  Constants.swift
//  PHONEQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-10.
//

import Foundation

struct Apple {
    static let CFBundleDisplayNameKey = "CFBundleDisplayName"
}

struct DefaultsKeys {
    static let userObjectKey = "userObject"
    static let allContactsKey = "allContacts"
    static let eligibleContactsKey = "eligibleContacts"
    static let nonEligibleContactsKey = "nonEligibleContacts"
}

struct ButtonTitles {
    static let beginQuiz = "BEGINQUIZ"
    static let submit = "SUBMIT"
    static let next = "NEXT"
    static let seeResults = "SEE RESULTS"
    static let allQuizes = "ALL QUIZZES"
}

public enum questionResultType : Int, Codable{
    case CORRECT
    case INCORRECT
}

struct QuestionTitles {
    static let forContactName = "What is the Contact Name for"
    static let forContactNumber = "What is the Contact Number for"
}

public enum quizQuestionType : Int,Codable {
    case CONTACT_NUMBERS
    case CONTACT_NAMES
    case BOTH
}
public var quizQuestionTypeStringArray = ["Contact Numbers", "Contact Names", "Both"]

public enum quizTimerTypes : Int, Codable {
    case NO_TIMER = 0
    case FIVE_SECONDS = 5
    case TEN_SECONDS = 10
    case FIFTEEN_SECONDS = 15
    case THIRTY_SECONDS = 30
}
public var quizTimerTypeDictionary = [0:"No Timer", 5:"5 seconds", 10:"10 seconds", 15:"15 seconds", 30:"30 seconds"]


public enum chartTypes : Int, Codable{
    case PAST_QUIZZES_SCORE_BAR_GRAPH_CHART
    case NUMBER_OF_QUESTIONS_PIE_CHART
    case TYPES_OF_QUESTIONS_PIE_CHART
    case TIMED_QUIZZES_PIE_CHART
}
let chartTypesStringArray = ["Past Quizzes Score", "Number of Questions", "Types of Questions","Timed Quizzes"]

public enum soundTypes : Int{
    case CorrectAnswer
    case WrongAnswer
    case QuizBackgroundScore
    case Option4
    case Option3
    case Option2
    case Option1
}
let soundTypesFileNamesStringArray = ["CorrectAnswer", "WrongAnswer", "QuizBackgroundScore","Option4","Option3","Option2","Option1"]

