//
//  Exercise.swift
//  ProgettoBD2
//
//  Created by Giovanni Laerte Frongia on 23/06/17.
//  Copyright © 2017 BardOZ. All rights reserved.
//

import Foundation
import UIKit

class Exercise{
    
    var exerciseName : String!
    var nSets : UInt8! = 0
    var date : Date!
    var sets = [[Double]]()
    var weights = [Double]()
    var temperature : Double!
    
    init (exerciseName : String, temperature : Double, date : NSDate, weight : Double, set : Array<Double>){
        self.exerciseName = exerciseName
        self.temperature = temperature
        self.date = date as Date!
        addSet(setToAdd: set, weightToAdd: weight)
    }
    
    func addSet(setToAdd : Array<Double>, weightToAdd : Double){
     
        self.sets.append(setToAdd)
        self.weights.append(weightToAdd)
        self.nSets! += 1
    }
    
    func getTotalCalories() -> Double{
    
        if let userHeight = UserDefaults.standard.object(forKey: "height") as? String{//height in cm
            
            let height = Int(userHeight)
            let gravity = 9.81
            let distance : Double = (Double(height!)/2 - Double(height!)/8) * 0.01 //Da Vinci's proportions: armspan == height, shoulder-width == height/4. This is the armlength = distance the weight travelled. In meters.
            var force : Double = 0 //Force in kg * m/sec^2  
            var caloriesBurned : Double = 0

            for i in 0...nSets-1{
                
                force = weights[Int(i)] * gravity
                caloriesBurned = caloriesBurned + ((force * distance) * 0.000239006) //Joules to kcals
                
            }
            
            return caloriesBurned*4 //Muscles are only 25% efficient
            
        }
        else {return 0}
        
    }
    
    func getBestRep() -> Double{
        
        var bestReps = [Double]()
        for i : Array<Double> in self.sets{
            bestReps.append(i.max()!)
        }
        
        return bestReps.max()!
    }
    
    func getWorstRep() -> Double{
        
        var worstReps = [Double]()
        for i : Array<Double> in self.sets{
            worstReps.append(i.min()!)
        }
        
        return worstReps.min()!
    }
    
    func getBestSet() -> UInt8{
        
        var bestSet : UInt8 = 0
        var bestAvg : Double = 0
        
        for i in 0...nSets-1{
            
            if (self.sets[Int(i)].reduce(0,+)/Double(self.sets[Int(i)].count)  > bestAvg){ //If this set's average acceleration is better than the current best
                bestAvg = self.sets[Int(i)].reduce(0,+)/Double(self.sets[Int(i)].count) //Replace the current best
                bestSet = i //Update the bestSet index
            }
            
        }
        
        return bestSet
    }
    
    func getWorstSet() -> UInt8{
        
        var worstSet : UInt8 = 0
        var worstAvg : Double = Double.greatestFiniteMagnitude
        
        for i in 0...nSets-1{
            
            if (self.sets[Int(i)].reduce(0,+)/Double(self.sets[Int(i)].count)  < worstAvg){ //If this set's average acceleration is worse than the current worst
                worstAvg = self.sets[Int(i)].reduce(0,+)/Double(self.sets[Int(i)].count) //Replace the current worst
                worstSet = i //Update the worstSet index
            }
            
        }
        
        return worstSet
    }
    
    func getAvgAcc() -> Double{
    
        var avgAccels = [Double]()
        var avgAccel : Double = 0
        
        for i in 0...nSets-1{
            avgAccels.append(self.sets[Int(i)].reduce(0,+)/Double(self.sets[Int(i)].count) )
        }
        
        avgAccel = avgAccels.reduce(0,+)/Double(avgAccels.count)
        
        return avgAccel
    }

}

