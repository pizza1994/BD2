//
//  SetInfoViewController.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 28/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit

class SetInfoViewController: UIViewController {

    @IBOutlet weak var repsField: UITextField?
    @IBOutlet weak var weightField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        repsField?.keyboardType = UIKeyboardType.numberPad
        weightField?.keyboardType = UIKeyboardType.numberPad

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createExercise(_ sender: Any) {
        
        if(weightField?.text == nil){
            weightField?.text = "0"
        }
        if(repsField?.text == nil){
            weightField?.text = "10"
            
        }
        
        if (SensorHandler.shared.exercise == nil){
            let _ : Exercise =  SensorHandler.shared.createExercise(exerciseName: (UserDefaults.standard.object(forKey: "exName") as? String)!, weight: Double(weightField!.text!)!, nReps: Int(repsField!.text!)!)
        }
        else{
            SensorHandler.shared.addNewSet(weight: Double((weightField?.text!)!)!, nReps: Int((repsField?.text!)!)!)
        }
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
