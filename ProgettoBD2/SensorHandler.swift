//
//  SensorHandler.swift
//  ProgettoBD2
//
//  Created by Giovanni Laerte Frongia on 29/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import Foundation
import UIKit

class SensorHandler : NSObject, ESTTriggerManagerDelegate {
    
    static let shared = SensorHandler()
    var accData : [Double]
    var exercise : Exercise?
    let deviceManager = ESTDeviceManager()
    var temperature : Double
    var accNotification : ESTTelemetryNotificationMotion?
    var tempNotification : ESTTelemetryNotificationTemperature?
    var weight : Double
    
    private override init (){
        self.accData = []
        self.temperature = -255
        self.weight = 0
    }
    
    func startListening(){
        ESTConfig.setupAppID("prova1-ft3", andAppToken: "efb8f4d5803312bdb2cf7c1bdd29ef55")
        
        
        if (temperature == -255){
        
            tempNotification = ESTTelemetryNotificationTemperature { (tempInfo) in
                if (tempInfo.shortIdentifier == "eca7f68368e84571"){
                    self.temperature = Double(tempInfo.temperatureInCelsius)
                }
            }


            deviceManager.register(forTelemetryNotification: tempNotification!)
            
        }

        
        
        accNotification = ESTTelemetryNotificationMotion { (moveInfo) in
            if (moveInfo.shortIdentifier == "eca7f68368e84571"){
                self.accData.append(Double(moveInfo.accelerationX))
            }
        }
        
        
        
        deviceManager.register(forTelemetryNotification: accNotification!)

        
    }
    
    func stopListening(){
        deviceManager.unregister(forTelemetryNotification: accNotification!)
        deviceManager.unregister(forTelemetryNotification: tempNotification!)
    }
    
    func createExercise(exerciseName: String, weight : Double, nReps : Int) -> Exercise{
        
        exercise = Exercise(exerciseName: exerciseName, temperature: temperature, date: Date(), weight: weight, set: repData(nReps: nReps))
        
        accData.removeAll()
        
        return exercise!
    }
    
    func addNewSet(weight : Double, nReps : Int){
        exercise?.addSet(setToAdd: repData(nReps: nReps), weightToAdd: weight)
        accData.removeAll()
    }
    
    func repData(nReps : Int) -> Array<Double>{
    
        struct diffAcc {
            var val: Double
            var pos: Int
        }
        
        var diffAccArr : [diffAcc] = []
        
        var repData : [Double] = []
        
        for i in 0...accData.count-2{
            
            diffAccArr.append(diffAcc(val: accData[i+1]-accData[i], pos: i))
        
        }
        
        diffAccArr = diffAccArr.sorted(by: { $0.val > $1.val })
        
        diffAccArr.removeLast(diffAccArr.count - nReps)
        diffAccArr = diffAccArr.sorted(by: {$0.pos < $1.pos})
        
        for i in 0...diffAccArr.count-1{
        
            if (abs(accData[diffAccArr[i].pos]) < abs(accData[diffAccArr[i].pos+1])){
                repData.append(abs(accData[diffAccArr[i].pos+1]))
            }
            else{
                repData.append(abs(accData[diffAccArr[i].pos]))
            }
        
        }
        
        return repData
    
    }
    
    func initialise(){
        
        accData.removeAll()
        temperature = -255
        weight = 0
        exercise = nil
        
    }
    
    

}
