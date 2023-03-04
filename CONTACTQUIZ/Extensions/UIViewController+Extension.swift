//
//  UIViewController+Extension.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-15.
//

import UIKit
import AVFoundation

extension UIViewController {
    
    
    
    func vibrate(isVibrationOn: Bool?, style: UIImpactFeedbackGenerator.FeedbackStyle){
        
        if !(isVibrationOn ?? true) {
            return
        }
        
        if #available(iOS 10.0, *) {
             UIImpactFeedbackGenerator(style: style).impactOccurred()
          }
    }
    
    func presentErrorAlert(title: String, msg: String){
        print("\(#fileID) : \(#function): ")
        
        let dialogMessage = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        dialogMessage.view.tintColor = .systemIndigo
        
        // Create Close button with action handler
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: { (action) -> Void in
            self.dismiss(animated:true, completion: nil)
        })
        
        //add actions to alert
        dialogMessage.addAction(closeAction)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func convertQuizTimeSecondsToString(timeTakenInSeconds: Int?) -> String {
        
        guard let quizTimeSeconds = timeTakenInSeconds else {
            return ""
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated

        let formattedQuizTimeString = formatter.string(from: TimeInterval(quizTimeSeconds))!
        
        return formattedQuizTimeString
    }
    
    func getStringDateFromDateObject(date: Date) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
}

