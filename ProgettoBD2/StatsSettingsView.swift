//
//  StatsSettingsView.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 04/07/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit

class StatsSettingsView: UIView {
    
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var nameTextField : UITextField!
    @IBOutlet weak var dataTextField : UITextField!
    @IBOutlet weak var toDataTextField : UITextField!
    @IBOutlet weak var temperatureTextField : UITextField!
    @IBOutlet weak var toTemperatureTextField : UITextField!
    @IBOutlet weak var setsTextField : UITextField!
    @IBOutlet weak var toSetsTextField : UITextField!
    @IBOutlet weak var repsTextField : UITextField!
    @IBOutlet weak var toRepsTextField : UITextField!
    @IBOutlet weak var segmentControl : UISegmentedControl!
    var selection :Int?
    
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)

    }
    
/*
    @IBAction func show(_ sender: Any) {
        self.isHidden = true
        
    }
  */  
    func initializeTextFieldInputView() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        dataTextField.inputView = datePicker
        toDataTextField.inputView = datePicker
    
        
    }
    

    
    func dateChanged(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if (dataTextField.isEditing){
            dataTextField.text = formatter.string(from: datePicker.date)
        }
        else{
            toDataTextField.text = formatter.string(from: datePicker.date)
        }
    }
    
    @IBAction func indexChanged(sender : UISegmentedControl) {
        // This all works fine and it prints out the value of 3 on any click
        
        switch sender.selectedSegmentIndex {
        case 0:
            selection = 0 //avgForce
        case 1:
            selection = 1 //force over temp
        case 2:
            selection = 2 //calories
        default:
            selection = 0
            break;
        }  //Switch
    } // indexChanged for the Segmented Control
    

    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}
