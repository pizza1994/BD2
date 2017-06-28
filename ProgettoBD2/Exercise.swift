//
//  Exercise.swift
//  porva2Estimote
//
//  Created by Giovanni Laerte Frongia on 23/06/17.
//  Copyright © 2017 BardOZ. All rights reserved.
//

import Foundation
import UIKit

class Exercise{
    
    var exerciseName : String!
    var nSets : UInt8!
    var date : Date!
    var sets = [[Double]]()
    var temperature : UnitTemperature!
    
    
    init(exName : String!, set : Array<Double>!, temperature : UnitTemperature!){
        
        self.exerciseName = exName
        nSets = 0
        addSet(setToAdd: set)
        self.date = Date()
        self.temperature = temperature
    }
    
    func addSet(setToAdd : Array<Double>){
     
        self.sets.append(setToAdd)
        self.nSets! += 1
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
        
        for i in 0...nSets{
            
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
        
        for i in 0...nSets{
            
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
        
        for i in 0...nSets{
            avgAccels.append(self.sets[Int(i)].reduce(0,+)/Double(self.sets[Int(i)].count) )
        }
        
        avgAccel = avgAccels.reduce(0,+)/Double(avgAccels.count)
        
        return avgAccel
    }

    
    
}

