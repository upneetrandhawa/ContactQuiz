//
//  ProfileViewController.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-21.
//

import UIKit
import Charts

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ChartViewDelegate {
    

    @IBOutlet weak var averageScoreValueLabel: UILabel!
    
    @IBOutlet weak var statisticsCollectionView: UICollectionView!
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    
    @IBOutlet weak var allQuizzesButton: UIButton!
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    
    var pastQuizzesBarChartView = BarChartView()
    
    var user: User? = nil
    let statisticsTypes = ["Quizzes Attempted","Total Questions Answered", "Correct Questions Answered", "Average Time Per Question", "Total Time For Quizzes", "Quizzes Done Per Day"]
    let chartTypesArray = ["Past Quizzes Score", "Number of Questions", "Types of Questions","Timed Quizzes"]
    
    let statisticsCollectionViewCellName = "statisticsCell"
    let barGraphCollectionViewCellName = "barGraphChartCell"
    let pieCollectionViewCellName = "pieChartCell"
    
    var currentChartSelectedIndex = -1
    
    var chartDataStructureReady = false
    //following data structure needed for our pie charts
    var numberOfQuestionsQuizzesDict = [String: Int]() //Key = noQuestions, Value = quizzes with number of questions equal to noQuestions
    var typesOfQuestionsQuizzesDict = [String: Int]() //Key = typesOfQuestion, Value = quizzes with type of questions equal to typesOfQuestion
    var timedQuizzesDict = [String: Int]() //Key = quizTime, Value = quizzes with timer equal to quizTime
    
    var score:Double = -0.0
    
    var hasViewWillAppearHappened: Bool = false
    
    override func viewDidLoad() {
        print("\(#fileID) : \(#function): ")
        
        loadUserdata()
        
        statisticsCollectionView.delegate = self
        statisticsCollectionView.dataSource = self
        statisticsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        chartsCollectionView.delegate = self
        chartsCollectionView.dataSource = self
        chartsCollectionView.collectionViewLayout = CardsCollectionFlowLayout()
        
        bottomBackgroundView.layer.cornerRadius = 15
        
        allQuizzesButton.layer.cornerRadius = 15
        
        setupViews(reloadChartsAfterFinishing: false)
        
        //add shadow
        bottomBackgroundView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.7, shadowOffset: CGSize(width: 0.0, height: -5.0), shadowRadius: 1.0)
        allQuizzesButton.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 1.0, shadowOffset: CGSize(width: 0.0, height: 3.0), shadowRadius: 1.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("\(#fileID) : \(#function): ")
        
        if !hasViewWillAppearHappened {
            hasViewWillAppearHappened = !hasViewWillAppearHappened
            return
        }
        
        
        let pUser = user
        loadUserdata()
        
        guard let previousUser = pUser else {
            return
        }
        
        guard let nUser = user else {
            return
        }
        
        print("\(#fileID) : \(#function): prev user no quizzes = ", previousUser.allQuizArray.count)
        print("\(#fileID) : \(#function): new user no quizzes = ", nUser.allQuizArray.count)
        
        
        
        if previousUser.allQuizArray.count >= 0 && nUser.allQuizArray.count > 0{
            
            if previousUser.allQuizArray.count == 0 {
                print("\(#fileID) : \(#function): user changed")
                
                self.setupViews(reloadChartsAfterFinishing: true)
            }
            else if previousUser.allQuizArray[previousUser.noOfQuizCompleted-1].date != nUser.allQuizArray[nUser.noOfQuizCompleted-1].date{
                //user object changed, need to update view
                print("\(#fileID) : \(#function): user changed")
                
                self.setupViews(reloadChartsAfterFinishing: true)
            }

        }
        
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // handle theme change here.
            print("\(#fileID) : \(#function): ")
            
            bottomBackgroundView.addShadow(shadowColor: UIColor.systemGray5.cgColor, shadowOpacity: 0.7, shadowOffset: CGSize(width: 0.0, height: -5.0), shadowRadius: 1.0)
            }
    }
    
    @IBAction func allQuizzesButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .light)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "AllQuizzesView") as! AllQuizzesViewController
        destinationVC.user = user
        
        self.present(destinationVC, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == chartsCollectionView {
            return chartTypesArray.count
        }
        return statisticsTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == statisticsCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: statisticsCollectionViewCellName, for: indexPath) as! ProfileStatsCollectionViewCell
            
            cell.statisticName.text = self.statisticsTypes[indexPath.item]
            cell.statisticValue.text = "0"
            
            guard let user = self.user else {
                return cell
            }
            
            switch indexPath.item {
            case 0:
                cell.statisticValue.text = String(user.noOfQuizCompleted)
            case 1:
                cell.statisticValue.text = String(user.noOfQuestionAnswered)
            case 2:
                cell.statisticValue.text = String(user.noOfCorrectAnswers)
            case 3:
                if user.noOfQuizCompleted == 0 {
                    break
                }
                let avgTimePerQuestion = Double(user.totalTimeTakenForQuizzes) / Double(user.noOfQuestionAnswered)
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute, .second]
                formatter.unitsStyle = .abbreviated

                cell.statisticValue.text = formatter.string(from: TimeInterval(avgTimePerQuestion))!
            case 4:
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute, .second]
                formatter.unitsStyle = .abbreviated

                cell.statisticValue.text = formatter.string(from: TimeInterval(user.totalTimeTakenForQuizzes))!
            case 5:
                if user.noOfQuizCompleted == 0 {
                    break
                }
                
                let noOfDays = Calendar.current.dateComponents([.day], from: user.dateJoined, to: Date()).day
                
                if let noDays = noOfDays {
                    cell.statisticValue.text = String(format: "%.2f",(Double(user.noOfQuizCompleted) / Double((noDays == 0) ? 1 : noDays)))
                }
                else {
                    cell.statisticValue.text = "error calculating"
                }
                
                
            default:
                cell.statisticValue.text = ""
                cell.statisticName.text = ""
            }
            
            cell.layer.cornerRadius = 15
            
            return cell
            
        }
        
        //chartsCollectionView
        
        //index 0 for BarGraph, 1-3 for Pie Graph
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: barGraphCollectionViewCellName, for: indexPath) as! BarGraphCollectionViewCell
            
            setupBarGraphCharts(chart: cell.chartView)
            
            cell.chartView.delegate = self
            cell.chartView.isUserInteractionEnabled = false
            
            cell.backgroundColor = .systemIndigo
            
            
            cell.layer.cornerRadius = 15
            return cell
        }
        
        //index 1-3 for Pie Graph
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: pieCollectionViewCellName, for: indexPath) as! PieChartCollectionViewCell
        
        setupPieChart(chart: cell.chartView, chartTypesIndex: indexPath.item)
        
        cell.chartView.delegate = self
        cell.chartView.isUserInteractionEnabled = false
        
        cell.backgroundColor = .systemIndigo
        cell.layer.cornerRadius = 15
        return cell
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == chartsCollectionView {
            print("\(#fileID) : \(#function): chartsCollectionView index = ", indexPath.item)
            currentChartSelectedIndex = indexPath.item
            
            if indexPath.item == 0 { // Bar Graphs
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "BarGraphChartView") as! BarGraphChartViewController
                destinationVC.user = user
                destinationVC.chartTypeSelected = chartTypes(rawValue: indexPath.item) ?? .PAST_QUIZZES_SCORE_BAR_GRAPH_CHART
                
                self.present(destinationVC, animated: true)
            }
            else { //Pie Charts
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "PieChartView") as! PieChartViewController
                destinationVC.user = user
                destinationVC.chartTypeSelected = chartTypes(rawValue: indexPath.item) ?? .NUMBER_OF_QUESTIONS_PIE_CHART
                destinationVC.numberOfQuestionsQuizzesDict = numberOfQuestionsQuizzesDict
                destinationVC.typesOfQuestionsQuizzesDict = typesOfQuestionsQuizzesDict
                destinationVC.timedQuizzesDict = timedQuizzesDict
                
                self.present(destinationVC, animated: true)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == statisticsCollectionView {
            let padding = 10
            let textWidth = statisticsTypes[indexPath.item].size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)]).width
            
            return CGSize(width: textWidth + CGFloat(2*padding), height: 80.00)
        }
        
        return CGSize(width: collectionView.frame.width * 0.7, height: collectionView.frame.height * 0.9)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("\(#fileID) : \(#function): ")
        
        
        guard scrollView == chartsCollectionView else {
                    return
                }
                
        // Changing content offset to where the collection view stops scrolling
        targetContentOffset.pointee = scrollView.contentOffset
            
        let flowLayout = chartsCollectionView.collectionViewLayout as! CardsCollectionFlowLayout
        let cellWidthIncludingSpacing = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
        let offset = targetContentOffset.pointee
        let horizontalVelocity = velocity.x
        
        var selectedIndex = currentChartSelectedIndex
        
        switch horizontalVelocity {
        // On user swiping
        case _ where horizontalVelocity > 0 :
            if currentChartSelectedIndex == chartTypesArray.count - 1 {
                return
            }
            selectedIndex = currentChartSelectedIndex + 1
        case _ where horizontalVelocity < 0:
            if currentChartSelectedIndex == 0 {
                return
            }
            selectedIndex = currentChartSelectedIndex - 1
            
        // On user dragging
        case _ where horizontalVelocity == 0:
            let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
            let roundedIndex = round(index)
            
            selectedIndex = Int(roundedIndex)
        default:
            print("\(#fileID) : \(#function): Incorrect velocity for collection view")
        }
        
        let safeIndex = max(0, min(selectedIndex, chartTypesArray.count - 1))
        let selectedIndexPath = IndexPath(row: safeIndex, section: 0)
        
        flowLayout.collectionView!.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
        
        let previousSelectedIndex = IndexPath(row: Int(currentChartSelectedIndex), section: 0)
        let previousSelectedCell = chartsCollectionView.cellForItem(at: previousSelectedIndex)
        let nextSelectedCell = chartsCollectionView.cellForItem(at: selectedIndexPath)
        
        currentChartSelectedIndex = selectedIndexPath.row
        
        //previousSelectedCell?.transformToStandard()
        //nextSelectedCell?.transformToLarge()
    }
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        self.dismiss(animated:true, completion: nil)
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        
        let appName = Bundle.main.displayName ?? "CONTACTQUIZ"
        
        let quizCompleted = user?.noOfQuizCompleted ?? 0
        
        let message = "I did \(String(quizCompleted)) \(quizCompleted > 1 ? "quizzes" :  "quiz") and scored \(String(format: "%0.2f", score)) %. How well do you know your contacts? Download \(appName) today!\n"
        //Set the link to share.
        if let link = NSURL(string: "http://appstore.com/")
        {
            let objectsToShare = [message,message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.assignToContact,
                                                UIActivity.ActivityType.openInIBooks,
                                                UIActivity.ActivityType.airDrop,
                                                UIActivity.ActivityType.markupAsPDF]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func setupViews(reloadChartsAfterFinishing: Bool){
        //set score
        if let nq = user?.noOfQuestionAnswered {
            if let nc = user?.noOfCorrectAnswers {
                print("\(#fileID) : \(#function): nq = ", nq)
                print("\(#fileID) : \(#function): nc = ", nc)
                score = Double(
                    (100.00 * Double (nc)) / Double (nq)
                )
                print("\(#fileID) : \(#function): score = ", score)
                
                self.averageScoreValueLabel.text = (score.isNaN) ? "0 %" : String(format: "%.2f", score) + " %"
            }
        }
        
        //setup our data structures
        setupChartsDataStructure(reloadChartsAfterFinishing: reloadChartsAfterFinishing)
    }
    
    func setupBarGraphCharts(chart: BarChartView){
        print("\(#fileID) : \(#function): ")
        
        guard let dataArray = user?.allQuizArray else {
            return
        }
        
        let dataEntries = dataArray.map{ $0.transformToPastQuizzesBarChartEntry()}
        
        var colors: [UIColor] = []
        
        for entry in dataEntries {
            
            switch entry.y {
            case 91.00 ... 100:
                colors.append(UIColor.systemGreen)
            case 81.00 ... 90:
                colors.append(UIColor.cyan)
            case 71.00 ... 80:
                colors.append(UIColor.systemTeal)
            case 61.00 ... 70:
                colors.append(UIColor.systemBlue)
            case 51.00 ... 60:
                colors.append(UIColor.systemYellow)
            case 41.00 ... 50:
                colors.append(UIColor.systemOrange)
            case 31.00 ... 40:
                colors.append(UIColor.red)
            case 21.00 ... 30:
                colors.append(UIColor.systemRed)
            case 11.00 ... 20:
                colors.append(UIColor.systemPink)
            case 0.00 ... 10:
                colors.append(UIColor.brown)
            default:
                print("\(#fileID) : \(#function): default")
            }
        }
        
        let set = BarChartDataSet(entries: dataEntries)
        set.colors = colors
        //set.highlightColor = .systemRed
        //set.highlightAlpha = 1
        
        let data = BarChartData(dataSet: set)
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        data.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        //data.setDrawValues(true)
        //data.setValueTextColor(.black)
        
        //let barValueFormatter = formatter(
        //data.setValueFormatter(barValueFormatter)
        chart.data = data
        
        chart.animate(yAxisDuration: 0.5,easingOption: .easeInCubic)
        
        let d = Description()
        d.text = "All Quizzes Score"
        chart.chartDescription = d
    }
    
    func setupPieChart(chart: PieChartView, chartTypesIndex: Int){
        print("\(#fileID) : \(#function): chartTypesIndex = ", chartTypesIndex)
        
        if !chartDataStructureReady {
            setupChartsDataStructure(reloadChartsAfterFinishing: true)
            return
        }
        
        var dictToBeUsed = [String:Int]()
        
        if chartTypesIndex == 1 { //"Number of Questions"
            dictToBeUsed = numberOfQuestionsQuizzesDict
        }
        else if chartTypesIndex == 2 { // "Types of Questions"
            dictToBeUsed = typesOfQuestionsQuizzesDict
        }
        else {
            //index 3 : "Timed Quizzes"
            dictToBeUsed = timedQuizzesDict
        }
        
        var labels = [String]()
        var values = [String]()
        
        for (key, value) in dictToBeUsed {
            labels.append("\(key)")
            values.append("\(value)")
        }
        
        print("\(#fileID) : \(#function): labels = ", labels)
        print("\(#fileID) : \(#function): values = ", values)
        
        var entries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = Double(Int(value) ?? 0)
            entry.label = labels[index]
            entries.append(entry)
        }
        
        

        // 3. chart setup
        let set = PieChartDataSet( entries: entries)
        
        //set.sliceSpace = 3
        set.selectionShift = 5
        
        switch chartTypesIndex {
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

        for _ in 0..<values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        set.colors = colors
        let data = PieChartData(dataSet: set)
        
        chart.data = data
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        data.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        chart.animate(xAxisDuration: 1.0,easingOption: .easeOutCirc)
        chart.entryLabelFont = UIFont.systemFont(ofSize: 20)
        
        chart.drawEntryLabelsEnabled = false
        
        
        let d = Description()
        d.text = chartTypesArray[chartTypesIndex]
        chart.chartDescription = d
        //chart.centerText = "Pie Chart"
        chart.holeRadiusPercent = 0.5
        chart.holeColor = .clear
        
    }
    
    func setupChartsDataStructure(reloadChartsAfterFinishing: Bool){
        print("\(#fileID) : \(#function): ")
        
        numberOfQuestionsQuizzesDict = [String: Int]()
        typesOfQuestionsQuizzesDict = [String: Int]()
        timedQuizzesDict = [String: Int]()

        if let allQuizzes = self.user?.allQuizArray {
            for quiz in allQuizzes {
                
                let noQuestions = String(quiz.noOfQuestions)
                self.numberOfQuestionsQuizzesDict[noQuestions] = (self.numberOfQuestionsQuizzesDict[noQuestions] ?? 0) + 1
                
                let typeOfQuestions = quizQuestionTypeStringArray[quiz.questionType.rawValue]
                self.typesOfQuestionsQuizzesDict[typeOfQuestions] = (self.typesOfQuestionsQuizzesDict[typeOfQuestions] ?? 0) + 1
                
                let quizTImer = quizTimerTypeDictionary[quiz.quizTimerValue.rawValue] ?? "unknown"
                self.timedQuizzesDict[quizTImer] = (self.timedQuizzesDict[quizTImer] ?? 0) + 1
                
                
            }
        }
        print("\(#fileID) : \(#function): numberOfQuestionsQuizzesDict = ", self.numberOfQuestionsQuizzesDict)
        print("\(#fileID) : \(#function): typesOfQuestionsQuizzesDict = ", self.typesOfQuestionsQuizzesDict)
        print("\(#fileID) : \(#function): timedQuizzesDict = ", self.timedQuizzesDict)
        
        self.chartDataStructureReady = true
        
        print("\(#fileID) : \(#function): background queue done")
        
        if reloadChartsAfterFinishing {
            //reload chartsCollectionView
            DispatchQueue.main.async(){
                self.statisticsCollectionView.reloadData()
                self.chartsCollectionView.reloadData()
            }
            
        }
            
        
    }
    
    
    func loadUserdata(){
        print("\(#fileID) : \(#function): ")
        
        
        
        if let userObject = UserDefaults.standard.data(forKey: DefaultsKeys.userObjectKey) {
            //User object exists, which means this is not the first ever launch
            print("\(#fileID) : \(#function): user found!! : ")
            
            do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()

                    // Decode userObject
                    user = try decoder.decode(User.self, from: userObject)
                
                //print("\(#fileID) : \(#function): user = " + user.debugDescription)

                } catch {
                    print("\(#fileID) : \(#function): user found!! : Unable to Decode User (\(error))")
                }
            
            
        }
        
        else {
            self.presentErrorAlert(title: "Error Occured", msg: "Unable to fetch user profile. \n Try Again Later!")
        }
        
    }
    
    
    
    
}
