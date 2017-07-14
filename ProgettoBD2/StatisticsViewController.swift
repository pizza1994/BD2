//
//  StatisticsViewController.swift
//  ProgettoBD2
//
//  Created by Elisa on 01/07/2017.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit
import Charts


class StatisticsViewController: UIViewController, ChartViewDelegate, IAxisValueFormatter {
    
    var queryView: StatsSettingsView? = nil
    @IBOutlet weak var statsChart: LineChartView!
    var minDate : Double = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let queryButton = UIBarButtonItem()
        queryButton.title = "Query"
        queryButton.target = self
    
        navigationItem.rightBarButtonItem = queryButton
        navigationItem.rightBarButtonItem?.action = #selector(openQView)
 

        
        //DB.loadFromDb(nDays: 30)
        statsChart.noDataText = "You need to provide data for the chart."
        statsChart.delegate = self
        setDefaultChart()


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
            //queryView?.repsTextField.keyboardType = UIKeyboardType.numberPad
            //queryView?.toRepsTextField.keyboardType = UIKeyboardType.numberPad
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
        //let reps : String? = queryView?.repsTextField.text
        //let toReps : String? = queryView?.toRepsTextField.text
        var selection: Int? = queryView?.selection
        
        
        if (selection == nil)
        {
            selection = 0
        }
        
        DB.loadFromDb(name: exNames, dateInterval: [date, toDate], tempInterval: [temperature, toTemperature], setInterval: [sets, toSets], returnType: selection)
        
        if(DB.qResult.count == 0){
            self.queryError()
        }
        else{
            switch selection!{
                case 0:
                    self.setAvgForceChart()
                case 1:
                    self.setAvgForceOnTempChart()
                case 2:
                    self.setCaloriesChart()
                default:
                    break

            }
        }

            
        
    }
    
    func queryError(){
        
        let alert = UIAlertController(title: "Error", message: "No results for your request", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        openQView()
    }

    func setAvgForceOnTempChart(){
        
        let qResult: Array<(Double, Double)> = DB.qResult as! Array<(Double, Double)>
        self.statsChart.noDataText = "You need to provide data for the chart."
        
        let xAxis = XAxis()
        xAxis.valueFormatter = self
        self.statsChart.xAxis.valueFormatter = xAxis.valueFormatter
        self.statsChart.xAxis.labelTextColor = UIColor.white
        statsChart.leftAxis.labelTextColor = UIColor.white
        statsChart.rightAxis.labelTextColor = UIColor.clear
        let yFormatter = NumberFormatter()
        yFormatter.positiveSuffix = " g"
        statsChart.leftAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: yFormatter)
        statsChart.chartDescription?.text = ""
        

        
        let yVals1 = qResult.map
        {x, y in
            return ChartDataEntry(x:x, y:y)
        }
        
        let set1: LineChartDataSet = LineChartDataSet(values: yVals1, label: "First Set")
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 0.5))
        set1.setCircleColor(UIColor.orange)
        set1.lineWidth = 4.0
        set1.circleRadius = 10.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 1)
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        
        self.statsChart.xAxis.labelPosition = .bottom
        
        
        let data = LineChartData(dataSets: dataSets)
        data.setValueTextColor(UIColor.white)
        
        self.statsChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        self.statsChart.data = data
        statsChart.leftAxis.resetCustomAxisMin()
        statsChart.leftAxis.resetCustomAxisMax()
        statsChart.leftAxis.axisMaximum = 2
        statsChart.leftAxis.axisMinimum = statsChart.data!.yMin-0.5
        statsChart.leftAxis.labelCount = 2
        statsChart.leftAxis.drawZeroLineEnabled = false

        
    }
    
    func setAvgForceChart() {
        
        let qResult: Array<(Int, Double)> = DB.qResult as! Array<(Int, Double)>
        self.statsChart.noDataText = "You need to provide data for the chart."
       
        let xAxis = XAxis()
        xAxis.valueFormatter = self
        self.statsChart.xAxis.valueFormatter = xAxis.valueFormatter
        self.statsChart.xAxis.labelTextColor = UIColor.white
        let yFormatter = NumberFormatter()
        yFormatter.positiveSuffix = " g"
        statsChart.leftAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: yFormatter)
        
        statsChart.chartDescription?.text = ""
        statsChart.leftAxis.labelTextColor = UIColor.white
        statsChart.rightAxis.labelTextColor = UIColor.clear

        
        minDate = Double(qResult[0].0)
        
        let yVals1 = qResult.map
        {x, y in
            return ChartDataEntry(x:(  (Double(x) - minDate) / (3600 * 24) ), y:y)
        }
        
        let set1: LineChartDataSet = LineChartDataSet(values: yVals1, label: "First Set")
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 0.5))
        set1.setCircleColor(UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 1))
        set1.lineWidth = 4.0
        set1.circleRadius = 10.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 1)
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        
        self.statsChart.xAxis.labelPosition = .bottom
        
        
        let data = LineChartData(dataSets: dataSets)
        data.setValueTextColor(UIColor.white)
        
        self.statsChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        self.statsChart.data = data
        
        statsChart.leftAxis.resetCustomAxisMin()
        statsChart.leftAxis.resetCustomAxisMax()
        statsChart.leftAxis.axisMaximum = 2
        statsChart.leftAxis.axisMinimum = statsChart.data!.yMin-0.5
        statsChart.leftAxis.labelCount = 2
        statsChart.leftAxis.drawZeroLineEnabled = false
    }
    
    
    
    
    
    func setCaloriesChart() {
        
        let qResult: Array<(Int, Double)> = DB.qResult as! Array<(Int, Double)>
        
        self.statsChart.noDataText = "You need to provide data for the chart."

        let xAxis = XAxis()
        xAxis.valueFormatter = self
        self.statsChart.xAxis.valueFormatter = xAxis.valueFormatter
        self.statsChart.xAxis.labelTextColor = UIColor.white
        statsChart.leftAxis.labelTextColor = UIColor.white
        statsChart.rightAxis.labelTextColor = UIColor.clear
        let yFormatter = NumberFormatter()
        yFormatter.positiveSuffix = " Kcal"
        statsChart.leftAxis.valueFormatter = DefaultAxisValueFormatter.init(formatter: yFormatter)
        
        statsChart.chartDescription?.text = ""
        
        
        
        minDate = Double(qResult[0].0)
        
        let yVals1 = qResult.map
        {x, y in
                return ChartDataEntry(x:(  (Double(x) - minDate) / (3600 * 24) ), y:y)
        }
    
        
        let set1: LineChartDataSet = LineChartDataSet(values: yVals1, label: "First Set")
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 0.5))
        set1.setCircleColor(UIColor.red)
        set1.lineWidth = 4.0
        set1.circleRadius = 10.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor(red: 242/255, green: 229/255, blue: 50/255, alpha: 1)
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        
        self.statsChart.xAxis.labelPosition = .bottom
        
        
        let data = LineChartData(dataSets: dataSets)
        data.setValueTextColor(UIColor.white)
        
        self.statsChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        self.statsChart.data = data
        statsChart.leftAxis.axisMinimum = min(0.0, statsChart.data!.yMin - 1.0)
        statsChart.leftAxis.axisMaximum = max(statsChart.data!.yMax, statsChart.data!.yMax + 5)
        statsChart.leftAxis.labelCount = Int(statsChart.leftAxis.axisMaximum/10)
        statsChart.leftAxis.drawZeroLineEnabled = false
    }
    
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        
        switch (queryView?.selection) {
        case .some(1):
            
            return String(value)+"°"
            
        default:
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            let date = Date(timeIntervalSince1970: value*3600*24+minDate)
            return dateFormatter.string(from: date)
        }
        
    }

    
    func setDefaultChart(){
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = Date();
        let today : String = dateFormatter.string(from: todayDate.addingTimeInterval(+86400))
        let monthAgo : String = dateFormatter.string(from: todayDate.addingTimeInterval(-2592000))
        
        DB.loadFromDb(name: "", dateInterval: [monthAgo, today], tempInterval: ["", ""], setInterval: ["", ""], returnType: 2)
        
        self.setCaloriesChart()
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
