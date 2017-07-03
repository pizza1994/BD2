//
//  RecapSetViewController.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 23/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit

class RecapSetViewController: UIViewController {

    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var burnedCaloriesLabel: UILabel!
    @IBOutlet weak var avgForceLabel: UILabel!
    @IBOutlet weak var worstLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.title = UserDefaults.standard.object(forKey: "exName") as? String
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:  UIColor(red: CGFloat(242.0/255.0), green: CGFloat(229.0/255.0), blue:CGFloat(50.0/255.0), alpha: 1.0)]
        
        let exercise : Exercise = SensorHandler.shared.exercise!
        
        temperatureLabel.text = String(exercise.temperature) + " °C"
        repsLabel.text = String(describing: (exercise.sets.last?.count)!)
        bestLabel.text = String(format: "%.2f", exercise.getBestRepInSet(nSet: (Int(exercise.nSets) - 1))*100/2) + "%"
        worstLabel.text = String(format: "%.2f", exercise.getWorstRepInSet(nSet: (Int(exercise.nSets) - 1))*100/2) + "%"
        avgForceLabel.text = String(format: "%.2f", exercise.getAvgAccInSet(nSet: (Int(exercise.nSets) - 1))*100/2) + "%"
        burnedCaloriesLabel.text = String(format: "%.2f", exercise.getCaloriesInSet(nSet: (Int(exercise.nSets) - 1))) + " Kcal"
        
        

        // Do any additional setup after loading the view.
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
