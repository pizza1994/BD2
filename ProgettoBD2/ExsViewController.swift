//
//  ViewController.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 23/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit

class ExsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
     let exercises: [String] = ["Bench Press", "Inclined Bench Press", "Shoulder Press", "Squat", "Dumbell Curl", "French Press"]
    
    let cellReuseIdentifier = "cell"
    @IBOutlet var tableView: UITableView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.darkGray
        navigationController?.navigationBar.isHidden = false
        

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "End Training", style: .done, target: self, action: #selector(backAction))


    }
    
    func backAction(){
        //print("Back Button Clicked")
    self.navigationController?.popToRootViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.exercises[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Avenir-Heavy", size: 17)
        cell.textLabel?.textColor = UIColor.white
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let SSController = self.storyboard?.instantiateViewController(withIdentifier: "SSController") as! StartStopViewController
        UserDefaults.standard.set(exercises[indexPath.row], forKey: "exName")
        self.navigationController?.pushViewController(SSController, animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

