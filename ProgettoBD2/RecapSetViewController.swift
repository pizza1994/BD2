//
//  RecapSetViewController.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 23/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit
import Charts

class RecapSetViewController: UIViewController, IAxisValueFormatter {

    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var burnedCaloriesLabel: UILabel!
    @IBOutlet weak var avgForceLabel: UILabel!
    @IBOutlet weak var worstLabel: UILabel!
    @IBOutlet weak var statsChart: LineChartView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = UserDefaults.standard.object(forKey: "exName") as? String
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:  UIColor(red: CGFloat(242.0/255.0), green: CGFloat(229.0/255.0), blue:CGFloat(50.0/255.0), alpha: 1.0)]
        
        let exercise : Exercise = SensorHandler.shared.exercise!
        
        temperatureLabel.text = String(exercise.temperature) + " °C"
        //repsLabel.text = String(describing: (exercise.sets.last?.count)!)
        //bestLabel.text = String(format: "%.2f", exercise.getBestRepInSet(nSet: (Int(exercise.nSets) - 1))*100/2) + "%"
        //worstLabel.text = String(format: "%.2f", exercise.getWorstRepInSet(nSet: (Int(exercise.nSets) - 1))*100/2) + "%"
        avgForceLabel.text = String(format: "%.2f", exercise.getAvgAccInSet(nSet: (Int(exercise.nSets) - 1))*100/2) + "%"
        burnedCaloriesLabel.text = String(format: "%.2f", exercise.getCaloriesInSet(nSet: (Int(exercise.nSets) - 1))) + " Kcal"
        
        
        setChart()
        

        // Do any additional setup after loading the view.
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        if (value - Double(Int(value)) > 0){
            
            return ""
        }
        
        
        return "Rep "+String(Int(value))

        
    }
    
    
    func setChart() {
        
        let set: Array<Double> = (SensorHandler.shared.exercise?.sets.last)!
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
        for i in 0...set.count-1{
            yVals1.append(ChartDataEntry(x:Double(i)+1, y:set[i]))
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
    
    @IBAction func newSet(_ sender: Any) {
        
        let SSController = self.storyboard?.instantiateViewController(withIdentifier: "SSController") as!StartStopViewController
        self.navigationController?.pushViewController(SSController, animated: true)
        
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
