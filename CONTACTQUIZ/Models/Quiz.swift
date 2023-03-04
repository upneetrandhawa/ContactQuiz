//
//  Quiz.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-10.
//

import Foundation
import Charts

public struct Quiz : Codable {
    let quizNoCompleted: Int
    let score: Double
    let questionType : quizQuestionType
    let noOfQuestions: Int
    let noOfCorrectAnswers: Int
    let noOfWrongAnswers: Int
    let timeTakenInSeconds: Int
    let date: Date
    let quizTimerValue: quizTimerTypes
    let quizReponses: [Question]
    
    func transformToPastQuizzesBarChartEntry () -> BarChartDataEntry {
        return BarChartDataEntry(x: Double(quizNoCompleted), y: score)
    }
    
    
}
