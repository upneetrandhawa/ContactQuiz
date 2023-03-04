//
//  AllQuizzesViewController.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-10.
//

import UIKit
import Foundation

class AllQuizzesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var noOfQuizzesLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let allQuizzesCellIdentifier = "allQuizzesCell"
    var allQuizzes = [Quiz]()
    var user: User? = nil
    
    
    override func viewDidLoad() {
        print("\(#fileID) : \(#function): ")
        
        guard let quizzes = user?.allQuizArray else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.presentErrorAlert(title: "Error Occurred", msg: "Please try again later!")
            }
            return
        }
        
        allQuizzes = quizzes
        
        noOfQuizzesLabel.text = String(allQuizzes.count)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.layer.cornerRadius = 15
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.layer.borderWidth = 10.0
        collectionView.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            collectionView.layer.borderColor = UIColor.systemBackground.cgColor
            }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: user?.isVibationOn, style: .soft)
        self.dismiss(animated:true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allQuizzes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reverseIndex = (allQuizzes.count-1) - indexPath.item
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: allQuizzesCellIdentifier, for: indexPath) as! AllQuizzesCollectionViewCell
        
        let quiz = allQuizzes[reverseIndex]
        let score = quiz.score
        
        cell.quizNoLabel.text = "Quiz " + String(reverseIndex + 1)
        cell.dateLabel.text = getStringDateFromDateObject(date: quiz.date)
        cell.noOfQuestionsLabel.text = String(allQuizzes[indexPath.item].noOfQuestions)
        cell.scoreLabel.text = String(score)
        cell.timeTakenLabel.text = convertQuizTimeSecondsToString(timeTakenInSeconds: quiz.timeTakenInSeconds)
        
        cell.layer.cornerRadius = 15
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.95, height: 80.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#fileID) : \(#function): item = ", indexPath.item)
        
        let reverseIndex = (allQuizzes.count-1) - indexPath.item
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .light)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "QuizResultView") as! QuizResultViewController
        destinationVC.user = user
        destinationVC.quizNumber = reverseIndex
        
        self.present(destinationVC, animated: true)
    }
    
    
    
    
}
