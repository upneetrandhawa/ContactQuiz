//
//  PieChartViewController.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-16.
//

import Foundation
import UIKit
import Charts

class PieChartViewController: UIViewController, ChartViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var chartTitleLabel: UILabel!
    
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let allQuizzesCellIdentifier = "allQuizzesCell"
    
    
    
    var user: User? = nil
    var chartTypeSelected: chartTypes = .PAST_QUIZZES_SCORE_BAR_GRAPH_CHART
    var numberOfQuestionsQuizzesDict = [String: Int]() //Key = noQuestions, Value = quizzes with number of questions equal to noQuestions
    var typesOfQuestionsQuizzesDict = [String: Int]() //Key = typesOfQuestion, Value = quizzes with type of questions equal to typesOfQuestion
    var timedQuizzesDict = [String: Int]() //Key = quizTime, Value = quizzes with timer equal to quizTime
    
    var chartLabels = [String]()
    var chartValues = [String]()
    
    var allQuizzes = [Quiz]()
    var filtereDQuizzes = [Quiz]()//data structure containing filtered results based on user selection on the pie chart
    
    override func viewDidLoad() {
        print("\(#fileID) : \(#function): ")
        
        guard let quizzes = user?.allQuizArray else {
            return
        }
        
        allQuizzes = quizzes
        
        pieChart.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.layer.cornerRadius = 15
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.layer.borderWidth = 10.0
        collectionView.layer.borderColor = UIColor.systemBackground.cgColor
        
        chartTitleLabel.text = chartTypesStringArray[chartTypeSelected.rawValue]
        
        setupCharts()
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
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        self.dismiss(animated:true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtereDQuizzes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reverseIndex = (filtereDQuizzes.count-1) - indexPath.item
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: allQuizzesCellIdentifier, for: indexPath) as! AllQuizzesCollectionViewCell
        
        let quiz = filtereDQuizzes[reverseIndex]
        let score = quiz.score
        
        cell.quizNoLabel.text = "Quiz " + String(reverseIndex + 1)
        cell.dateLabel.text = self.getStringDateFromDateObject(date: quiz.date)
        cell.noOfQuestionsLabel.text = String(filtereDQuizzes[indexPath.item].noOfQuestions)
        cell.scoreLabel.text = String(score)
        cell.timeTakenLabel.text = self.convertQuizTimeSecondsToString(timeTakenInSeconds: quiz.timeTakenInSeconds)
        
        cell.layer.cornerRadius = 15
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#fileID) : \(#function): item = ", indexPath.item)
        
        let reverseIndex = (filtereDQuizzes.count-1) - indexPath.item
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .light)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "QuizResultView") as! QuizResultViewController
        destinationVC.user = user
        destinationVC.quizNumber = filtereDQuizzes[reverseIndex].quizNoCompleted - 1
        
        self.present(destinationVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.95, height: 80.0)
    }
    
    func setupCharts(){
        print("\(#fileID) : \(#function): chart name = ",chartTypesStringArray[chartTypeSelected.rawValue])
        
        var dictToBeUsed = [String:Int]()
        
        if chartTypeSelected.rawValue == 1 { //"Number of Questions"
            dictToBeUsed = numberOfQuestionsQuizzesDict
        }
        else if chartTypeSelected.rawValue == 2 { // "Types of Questions"
            dictToBeUsed = typesOfQuestionsQuizzesDict
        }
        else {
            //index 3 : "Timed Quizzes"
            dictToBeUsed = timedQuizzesDict
        }
        
        chartLabels = [String]()
        chartValues = [String]()
        
        for (key, value) in dictToBeUsed {
            chartLabels.append("\(key)")
            chartValues.append("\(value)")
        }
        
        print("\(#fileID) : \(#function): labels = ", chartLabels)
        print("\(#fileID) : \(#function): values = ", chartValues)
        
        var entries = [PieChartDataEntry]()
        var maxIndex = -1
        var maxEntry = PieChartDataEntry()
        
        for (index, value) in chartValues.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = Double(Int(value) ?? 0)
            entry.label = chartLabels[index]
            entries.append(entry)
            
            if maxEntry.value < entry.value {
                maxIndex = index
                maxEntry = entry
            }
        }
        print("\(#fileID) : \(#function): maxIndex = ", maxIndex)
        print("\(#fileID) : \(#function): maxEntry.y = ", maxEntry.y)
        
        

        // 3. chart setup
        let set = PieChartDataSet( entries: entries)
        
        //set.sliceSpace = 3
        set.selectionShift = 5
        
        switch chartTypeSelected.rawValue {
        case 1:
            set.label = "Questions"
        case 2:
            set.label = "Question Type"
        case 3:
            set.label = "Timer Duration"
        default:
            print("\(#fileID) : \(#function): default")
        }
        
        // this is custom extension method. Download the code for more details.
        var colors: [UIColor] = []

        for _ in 0..<chartValues.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        set.colors = colors
        let data = PieChartData(dataSet: set)
        
        pieChart.data = data
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        data.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        pieChart.animate(xAxisDuration: 1.0,easingOption: .easeOutCirc)
        pieChart.entryLabelFont = UIFont.systemFont(ofSize: 30)
        
        pieChart.drawEntryLabelsEnabled = false
        
        
        let d = Description()
        d.text = chartTypesStringArray[chartTypeSelected.rawValue]
        pieChart.chartDescription = d
        //chart.centerText = "Pie Chart"
        pieChart.holeRadiusPercent = 0.5
        pieChart.holeColor = .clear
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            //self.pieChart.highlightValue(x: Double(maxIndex),dataSetIndex: 1)
            print("\(#fileID) : \(#function): highlighting max ")
            //self.pieChart.highlightValue(x: Double(maxIndex), y: maxValueY, dataSetIndex: -1)
            //self.pieChart.highlightValue(Highlight(x: Double(maxIndex), dataSetIndex: <#T##Int#>, stackIndex: <#T##Int#>))
            
            self.chartValueSelected(self.pieChart, entry: maxEntry, highlight: Highlight(x: Double(maxIndex), y: maxEntry.y, dataSetIndex: 0))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            //self.pieChart.highlightValue(x: Double(maxIndex),dataSetIndex: 1)
            print("\(#fileID) : \(#function): highlighting max ")
            //self.pieChart.highlightValue(x: Double(maxIndex), y: maxValueY, dataSetIndex: -1)
            //self.pieChart.highlightValue(Highlight(x: Double(maxIndex), dataSetIndex: <#T##Int#>, stackIndex: <#T##Int#>))
            
            self.pieChart.highlightValue(Highlight(x: Double(maxIndex), y: 0, dataSetIndex: 0))
        }
        
    }
    
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("\(#fileID) : \(#function): x = " , chartLabels[Int(highlight.x)] , ", y = " , highlight.y)
        
        var centerText = "You took \(Int(highlight.y)) \(Int(highlight.y) > 1 ? "quizzes" : "quiz") with \n"
        
        switch chartTypeSelected {
        case .NUMBER_OF_QUESTIONS_PIE_CHART:
            centerText += "\(chartLabels[Int(highlight.x)]) Questions"
        case .TYPES_OF_QUESTIONS_PIE_CHART:
            centerText += "\(chartLabels[Int(highlight.x)]) Questions"
        case .TIMED_QUIZZES_PIE_CHART:
            
            //if quizTimerTypes.NO_TIMER.rawValue == Int(highlight.x)
            if quizTimerTypeDictionary[quizTimerTypes.NO_TIMER.rawValue] == chartLabels[Int(highlight.x)]{
                print("\(#fileID) : \(#function): HEEEEE")
                centerText += "\(chartLabels[Int(highlight.x)])"
            }
            else {
                centerText += "\(chartLabels[Int(highlight.x)]) Timer"
            }
        default:
            print("\(#fileID) : \(#function): Default")
        }
        pieChart.centerText = centerText
        
        filterQuizDataStructure(with: chartLabels[Int(highlight.x)])
    }
    
    func filterQuizDataStructure(with value: String){
        print("\(#fileID) : \(#function): ")
        
        filtereDQuizzes = [Quiz]()
        
            switch chartTypeSelected {
            
            case .NUMBER_OF_QUESTIONS_PIE_CHART:
                for quiz in allQuizzes {
                    if quiz.noOfQuestions == Int(value) {
                        filtereDQuizzes.append(quiz)
                    }
                }
            case .TYPES_OF_QUESTIONS_PIE_CHART:
                for quiz in allQuizzes {
                    if quizQuestionTypeStringArray[quiz.questionType.rawValue] == value {
                        filtereDQuizzes.append(quiz)
                    }
                }
                
            case .TIMED_QUIZZES_PIE_CHART:
                for quiz in allQuizzes {
                    if quizTimerTypeDictionary[quiz.quizTimerValue.rawValue] == value {
                        filtereDQuizzes.append(quiz)
                    }
                }
                
            default:
                print("\(#fileID) : \(#function): Default")
            }
        
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
    
}
