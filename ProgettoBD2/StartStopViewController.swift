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
    //@IBOutlet weak var exName: UILabel!
    
    var exNameString : String?
    
    var timerCount : UInt8 = 4
    var timer : Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        exNameString = UserDefaults.standard.object(forKey: "exName") as? String
        navigationItem.title = exNameString
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:  UIColor(red: CGFloat(242.0/255.0), green: CGFloat(229.0/255.0), blue:CGFloat(50.0/255.0), alpha: 1.0)]
        view.backgroundColor = UIColor.darkGray

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func startStopToggle(button: UIButton){
        
        if(button.tag == 0){
            addCircleView()
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
        
        self.view.bringSubview(toFront: startStopButton);
        
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
    
    func addCircleView() {
        let circleWidth = CGFloat(250)
        let circleHeight = circleWidth
        
        // Create a new CircleView
        let circleView = CircleTimer(frame: CGRectMake(startStopButton.frame.minX, startStopButton.frame.minY, circleWidth, circleHeight))
        
        view.addSubview(circleView)
    
        
        
        // Animate the drawing of the circle over the course of 1 second
        circleView.animateCircle(duration: TimeInterval(timerCount))
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
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
