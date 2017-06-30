//
//  StartStopViewController.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 23/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit

class StartStopViewController: UIViewController {

    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var exName: UILabel!
    
    var exNameString : String?
    
    var timerCount : UInt8 = 5
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exNameString = UserDefaults.standard.object(forKey: "exName") as? String
        exName.text = exNameString!

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func startStopToggle(button: UIButton){
        
        if(button.tag == 0){
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            button.isUserInteractionEnabled = false
            button.tag = 1
        }
        else{

            /*let RecapSetController = self.storyboard?.instantiateViewController(withIdentifier: "RSController") as! RecapSetViewController
            self.navigationController?.pushViewController(RecapSetController, animated: true)*/
            SensorHandler.shared.stopListening()
            let SetInfoController = self.storyboard?.instantiateViewController(withIdentifier: "SIController") as! SetInfoViewController
            self.navigationController?.pushViewController(SetInfoController, animated: true)
            
        }
        
    }
    
    func update(){
        
        timerCount-=1
        if(timerCount == 0){
            startStopButton.setTitle("STOP", for: .normal)
            timer?.invalidate()
            startStopButton.isUserInteractionEnabled = true
            SensorHandler.shared.startListening()

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
