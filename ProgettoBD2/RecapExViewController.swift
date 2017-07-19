//
//  RecapExViewController.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 28/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit
import Charts

class RecapExViewController: UIViewController, IAxisValueFormatter {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var setsLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var burnedCaloriesLabel: UILabel!
    @IBOutlet weak var avgForceLabel: UILabel!
    @IBOutlet weak var worstLabel: UILabel!
    @IBOutlet weak var statsChart : LineChartView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = UserDefaults.standard.object(forKey: "exName") as? String
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:  UIColor(red: CGFloat(242.0/255.0), green: CGFloat(229.0/255.0), blue:CGFloat(50.0/255.0), alpha: 1.0)]
        
        
        let exercise : Exercise = SensorHandler.shared.exercise!
        
        temperatureLabel.text = String(exercise.temperature) + " °C"
        //setsLabel.text = String(describing: (exercise.nSets)!)
        //bestLabel.text = String(format: "%.2f", exercise.getBestRep()*100/2) + "%"
        //worstLabel.text = String(format: "%.2f", exercise.getWorstRep()*100/2) + "%"
        avgForceLabel.text = String(format: "%.2f", exercise.getAvgAcc()*100/2) + "%"
        burnedCaloriesLabel.text = String(format: "%.2f", exercise.getTotalCalories()) + " Kcal"
        setChart()
    


        // Do any additional setup after loading the view.
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        if (value != Double(Int(value))){
            return ""
        }
        
        return "Set "+String(Int(value))
        
    }
    
    
    func setChart() {
        
        let nSets : Int = Int((SensorHandler.shared.exercise?.nSets)!)
        
        var avgForces : Array<Double> = []
        
        for i in 0...nSets-1
        {
            avgForces.append((SensorHandler.shared.exercise?.getAvgAccInSet(nSet: i))!)
        }
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
        
        var yVals1 : Array<ChartDataEntry> = []
        for i in 0...nSets-1{
            yVals1.append(ChartDataEntry(x:Double(i)+1, y:avgForces[i]))
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
        
        self.statsChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        
        self.statsChart.data = data
        
        statsChart.leftAxis.resetCustomAxisMin()
        statsChart.leftAxis.resetCustomAxisMax()
        statsChart.leftAxis.axisMaximum = 2.5
        statsChart.leftAxis.axisMinimum = statsChart.data!.yMin-0.5
        statsChart.leftAxis.labelCount = 2
        statsChart.leftAxis.drawZeroLineEnabled = false
        statsChart.legend.enabled = false

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveExercise(_ sender: Any) {
        DB.saveToDb(ex: SensorHandler.shared.exercise!)
        SensorHandler.shared.initialise()
    }
    
    @IBAction func discardExercise(_ sender: Any) {
        SensorHandler.shared.initialise()
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
