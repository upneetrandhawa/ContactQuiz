//
//  Question.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-10.
//

import Foundation

public struct Question : Codable {
    let questionType: quizQuestionType
    let questionTitle: String
    let questionValue: String
    let correctAnswerValue: String
    let userSelectedOptionValue: String
    let correctAnswerContact: Contact
    let userSelectedContact: Contact
    let didTimerEnded: Bool
    let questionResult: questionResultType
}
