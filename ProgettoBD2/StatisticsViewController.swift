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
    @IBOutlet weak var barChartView: BarChartView!
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        
        let queryButton = UIBarButtonItem()
        queryButton.title = "Query"
        queryButton.target = self
    
        navigationItem.rightBarButtonItem = queryButton
        navigationItem.rightBarButtonItem?.action = #selector(openQView)
 

        
        //DB.loadFromDb(nDays: 30)
        barChartView.noDataText = "You need to provide data for the chart."
        

        
        setChart(dataPoints: months, values: unitsSold)
        
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
    

    
    func loadDataFromDB(){
        
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
        
        let qResults : Array<Any> = DB.loadFromDb(name: exNames, dateInterval: [date, toDate], tempInterval: [temperature, toTemperature], setInterval: [sets, toSets], repInterval: [reps, toReps], returnType: selection)
        
        
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return months[Int(value) % months.count]
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        let xAxis = XAxis()
        xAxis.valueFormatter = self
        barChartView.xAxis.valueFormatter = xAxis.valueFormatter
        barChartView.xAxis.labelTextColor = UIColor.white

        
        let yValues = unitsSold.enumerated().map { index, element -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(index), y: element)
        }
        
        let chartDataSet = BarChartDataSet(values: yValues, label: "If you want a label; you can also pass nil")
        
        let chartData = BarChartData(dataSet: chartDataSet)
        
        barChartView.data = chartData
        

        
        
        barChartView.xAxis.labelPosition = .bottom
        chartDataSet.colors = [UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 1)]

        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChartView.data = chartData
        
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
