//
//  RecapExViewController.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 28/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit

class RecapExViewController: UIViewController {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var setsLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    @IBOutlet weak var burnedCaloriesLabel: UILabel!
    @IBOutlet weak var avgForceLabel: UILabel!
    @IBOutlet weak var worstLabel: UILabel!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        let exercise : Exercise = SensorHandler.shared.exercise!
        
        temperatureLabel.text = String(exercise.temperature)
        setsLabel.text = String(describing: (exercise.nSets)!)
        bestLabel.text = String(exercise.getBestRep())
        worstLabel.text = String(exercise.getWorstRep())
        avgForceLabel.text = String(exercise.getAvgAcc())
        burnedCaloriesLabel.text = String(exercise.getTotalCalories())
    


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveExercise(_ sender: Any) {
        DB.saveToDb(ex: SensorHandler.shared.exercise!)
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
