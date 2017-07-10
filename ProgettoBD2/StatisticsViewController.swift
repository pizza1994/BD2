//
//  StatisticsViewController.swift
//  ProgettoBD2
//
//  Created by Elisa on 01/07/2017.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit
import Charts


class StatisticsViewController: UIViewController,IAxisValueFormatter {
    
    var queryView: StatsSettingsView? = nil
    @IBOutlet weak var defaultChart: LineChartView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setDefaultChart()
        
        let queryButton = UIBarButtonItem()
        queryButton.title = "Query"
        queryButton.target = self
    
        navigationItem.rightBarButtonItem = queryButton
        navigationItem.rightBarButtonItem?.action = #selector(openQView)
 

        
        //DB.loadFromDb(nDays: 30)
        defaultChart.noDataText = "You need to provide data for the chart."

    }
    
    @IBAction func showChart(_ sender: Any) {
        navigationItem.rightBarButtonItem?.title = "Query"
        queryView?.isHidden = true
        loadDataFromDB()
    }
    
    func openQView(){
        
        if(queryView == nil){
            queryView = StatsSettingsView.loadFromNibNamed(nibNamed: "StatSettings") as? StatsSettingsView
            queryView?.initializeTextFieldInputView()
            queryView?.temperatureTextField.keyboardType = UIKeyboardType.numberPad
            queryView?.toTemperatureTextField.keyboardType = UIKeyboardType.numberPad
            queryView?.setsTextField.keyboardType = UIKeyboardType.numberPad
            queryView?.toSetsTextField.keyboardType = UIKeyboardType.numberPad
            queryView?.repsTextField.keyboardType = UIKeyboardType.numberPad
            queryView?.toRepsTextField.keyboardType = UIKeyboardType.numberPad
            queryView?.segmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: UIControlState.normal)
            queryView?.segmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: UIControlState.selected)

            self.view.addSubview(queryView!)
            self.view.bringSubview(toFront: queryView!)
        }
        else{
            queryView?.isHidden = false
        }
        navigationItem.rightBarButtonItem?.title = ""
    
        
    }
    

    
    func loadDataFromDB() -> Array<Any>{
        
        let exNames : String? = queryView?.nameTextField.text
        let date : String? = queryView?.dataTextField.text
        let toDate : String? = queryView?.toDataTextField.text
        let temperature : String? = queryView?.temperatureTextField.text
        let toTemperature : String? = queryView?.toTemperatureTextField.text
        let sets : String? = queryView?.setsTextField.text
        let toSets : String? = queryView?.toSetsTextField.text
        let reps : String? = queryView?.repsTextField.text
        let toReps : String? = queryView?.toRepsTextField.text
        var selection: Int? = queryView?.selection
        
        
        if (selection == nil)
        {
            selection = 0
        }
        
        return DB.loadFromDb(name: exNames, dateInterval: [date, toDate], tempInterval: [temperature, toTemperature], setInterval: [sets, toSets], repInterval: [reps, toReps], returnType: selection)
    }
    
       func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
        }
    
    
    /*
    func setChart(dataPoints: [String], values: [Double]) {
        defaultChart.noDataText = "You need to provide data for the chart."
        
        let xAxis = XAxis()
        xAxis.valueFormatter = self
        defaultChart.xAxis.valueFormatter = xAxis.valueFormatter
        defaultChart.xAxis.labelTextColor = UIColor.white

        
        let yValues = unitsSold.enumerated().map { index, element -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(index), y: element)
        }
        
        let chartDataSet = BarChartDataSet(values: yValues, label: "If you want a label; you can also pass nil")
        
        let chartData = BarChartData(dataSet: chartDataSet)
        
        defaultChart.data = chartData
        

        
        
        defaultChart.xAxis.labelPosition = .bottom
        chartDataSet.colors = [UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 1)]

        defaultChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        defaultChart.data = chartData
        
    }
    */
    
    func setDefaultChart(){
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = Date();
        let today : String = dateFormatter.string(from: todayDate)
        let monthAgo : String = dateFormatter.string(from: todayDate.addingTimeInterval(-2592000))
        
        let qResult : Array<(Int, Double)> = DB.loadFromDb(name: "", dateInterval: [monthAgo, today], tempInterval: ["", ""], setInterval: ["", ""], repInterval: ["", ""], returnType: 2) as! Array<(Int, Double)>
    
        defaultChart.noDataText = "You need to provide data for the chart."
        
        let xAxis = XAxis()
        xAxis.valueFormatter = self
        defaultChart.xAxis.valueFormatter = xAxis.valueFormatter
        defaultChart.xAxis.labelTextColor = UIColor.white
        
        let yValues = qResult.map() { date, calories -> ChartDataEntry in
            return ChartDataEntry(x: Double(date), y: calories)
        }
        
        let chartDataSet = LineChartDataSet(values: yValues, label: "If you want a label; you can also pass nil")
        
        let chartData = LineChartData(dataSet: chartDataSet)
        
        defaultChart.data = chartData
        
        
        
        
        defaultChart.xAxis.labelPosition = .bottom
        chartDataSet.colors = [UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 1)]
        
        defaultChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        defaultChart.data = chartData

    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
