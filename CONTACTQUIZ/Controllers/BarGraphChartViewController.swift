//
//  BarGraphChartViewController.swift
//  CONTACTQUIZ
//
//  Created by Upneet  Randhawa on 2020-07-16.
//

import Foundation
import UIKit
import Charts

class BarGraphChartViewController: UIViewController, ChartViewDelegate {
    
    
    @IBOutlet weak var chartTitleLabel: UILabel!
    
    @IBOutlet weak var barGraphChart: BarChartView!
    
    @IBOutlet weak var leftScrollButton: UIButton!
    @IBOutlet weak var rightScrollButton: UIButton!
    
    var user: User? = nil
    var chartTypeSelected: chartTypes = .PAST_QUIZZES_SCORE_BAR_GRAPH_CHART
    
    var dataSet = BarChartDataSet() //dataset containing all entries of the chart
    let maxVisibleXRange = 10.0
    
    override func viewDidLoad() {
        print("\(#fileID) : \(#function): ")
        
        barGraphChart.delegate = self
        
        chartTitleLabel.text = chartTypesStringArray[chartTypeSelected.rawValue]
        
        setupCharts()
        
        if dataSet.count < Int(maxVisibleXRange) {//dont show scroll option if the visibile area is bigger than total count of dataset
            leftScrollButton.isHidden = true
            rightScrollButton.isHidden = true
        }
    }
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        print("\(#fileID) : \(#function): ")
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        self.dismiss(animated:true, completion: nil)
    }
    
    @IBAction func leftScrollButtonPressed(_ sender: Any) {
        
        print("\(#fileID) : \(#function): ")
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        
        if dataSet.count < 1 {
            return
        }
        
        barGraphChart.moveViewToAnimated(xValue: 0.0, yValue: dataSet.yMin, axis: .left, duration: 0.5)
        
        leftScrollButton.isUserInteractionEnabled = false
        leftScrollButton.alpha = 0.5
        
        rightScrollButton.isUserInteractionEnabled = true
        rightScrollButton.alpha = 1.0
    }
    
    @IBAction func rightScrollButtonPressed(_ sender: Any) {
        
        print("\(#fileID) : \(#function): ")
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .soft)
        
        if dataSet.count < 1 {
            return
        }
        
        barGraphChart.moveViewToAnimated(xValue: dataSet.xMax, yValue: dataSet.yMin, axis: .left, duration: 0.5)
        
        leftScrollButton.isUserInteractionEnabled = true
        leftScrollButton.alpha = 1.0
        
        rightScrollButton.isUserInteractionEnabled = false
        rightScrollButton.alpha = 0.5
        
    }
    
    func setupCharts(){
        print("\(#fileID) : \(#function): chart name = ",chartTypesStringArray[chartTypeSelected.rawValue])
        
        guard let dataArray = user?.allQuizArray else {
            return
        }
        
        let dataEntries = dataArray.map{ $0.transformToPastQuizzesBarChartEntry()}
        print("\(#fileID) : \(#function): dataEntries count = ", dataEntries.count)
        
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
        
        dataSet = BarChartDataSet(entries: dataEntries)
        dataSet.colors = colors
        //dataSet.highlightColor = .systemRed
        //dataSet.highlightAlpha = 1
        
        let data = BarChartData(dataSet: dataSet)
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        data.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        //data.setDrawValues(true)
        //data.setValueTextColor(.black)
        
        //let barValueFormatter = formatter(
        //data.setValueFormatter(barValueFormatter)
        barGraphChart.data = data
        
        barGraphChart.animate(yAxisDuration: 0.5,easingOption: .easeInCubic)
        barGraphChart.setVisibleXRangeMaximum(maxVisibleXRange)
        
        let d = Description()
        d.text = chartTypesStringArray[chartTypeSelected.rawValue]
        barGraphChart.chartDescription = d
        
        barGraphChart.moveViewToX(dataSet.xMax)
        rightScrollButton.isUserInteractionEnabled = false
        rightScrollButton.alpha = 0.5
        
    }
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        //print("\(#fileID) : \(#function): curr view highest x = ", barGraphChart.highestVisibleX)
        //print("\(#fileID) : \(#function): curr view lowest x = ", barGraphChart.lowestVisibleX)
        
        //print("\(#fileID) : \(#function): global highest x = ", barGraphChart.chartXMax)
        
        
        if Int(barGraphChart.lowestVisibleX) == 0 { //scrolled to the left most point on the x-axis
            //print("\(#fileID) : \(#function): left most point on x axis")
            
            self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .medium)
            
            leftScrollButton.isUserInteractionEnabled = false
            leftScrollButton.alpha = 0.5
            
            rightScrollButton.isUserInteractionEnabled = true
            rightScrollButton.alpha = 1.0
        }
        else if Int(barGraphChart.highestVisibleX) == Int(barGraphChart.chartXMax){//scrolled to the right most point on the x-axis
            //print("\(#fileID) : \(#function): right most point on x axis")
            
            self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .medium)
            
            leftScrollButton.isUserInteractionEnabled = true
            leftScrollButton.alpha = 1.0
            
            rightScrollButton.isUserInteractionEnabled = false
            rightScrollButton.alpha = 0.5
        }
        else {
            leftScrollButton.isUserInteractionEnabled = true
            leftScrollButton.alpha = 1.0
            
            rightScrollButton.isUserInteractionEnabled = true
            rightScrollButton.alpha = 1.0
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        print("\(#fileID) : \(#function): x = " , Int(highlight.x) , ", y = " , highlight.y)
        
        self.vibrate(isVibrationOn: self.user?.isVibationOn, style: .light)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "QuizResultView") as! QuizResultViewController
        destinationVC.user = user
        destinationVC.quizNumber = Int(highlight.x) - 1
        
        print("\(#fileID) : \(#function): q no = " ,destinationVC.quizNumber)
        
        self.present(destinationVC, animated: true)
    }
    
    
}
