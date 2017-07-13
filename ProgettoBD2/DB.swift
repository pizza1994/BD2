//
//  DB.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 29/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit
import Foundation
import MongoKitten

class DB: NSObject
{
    static private var returnType: Int?
    static public var qResult : Array<Any> = Array<Any>()
    
    
    static private func connect() -> MongoCollection
    {
        var collection : MongoCollection? = nil
        
        do
        {
            let database = try Database("mongodb://pizza94:password@ds143362.mlab.com:43362/testbd2")
            
            if database.server.isConnected {
                print("Successfully connected!")
            } else {
                print("Connection failed")
            }
            
            collection = database["exercises"]
            
        }
        catch
        {
            print ("Something went wrong")
        }
        
        return collection!

    }
    
    
    static func saveToDb(ex: Exercise)
    {
        let collection = connect()
        
        let username: String = UserDefaults.standard.object(forKey: "username") as! String
        
        let exerciseInfo : Document = ["username": username,
                                       "exercise_name": ex.exerciseName,
                                       "n_sets": Int(ex.nSets) as Primitive,
                                       "sets": ex.sets,
                                       "weights": ex.weights,
                                       "temperature": ex.temperature,
                                       "date": Int(ex.date.timeIntervalSince1970),
                                       "calories": ex.getTotalCalories()
                                      ]
    
        do
        {
            let _ = try collection.insert(exerciseInfo)
        }
        catch
        {
            print ("Error")
        }
    }
    
    
    static func loadFromDb(name: String?, dateInterval : [String?], tempInterval: [String?], setInterval: [String?], returnType : Int!, handleComplete:@escaping ((_ isOK:Bool)->()))
    {
        let collection = connect()

        let username: String = UserDefaults.standard.object(forKey: "username") as! String

        var query : Document = ["username" : ["$eq": username],
                                "exercise_name" : [],
                                "date" : [],
                                "temperature" : []
                            ]
        
        if (name != "")
        {
            let names = name!.components(separatedBy: ", ")
            
            for name in names
            {
                query.append(["$eq" : name], forKey: "exercise_name")
            }
        }
        
        if (dateInterval[0]! != "") && (dateInterval[1]! != "")
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let from : Int = Int(dateFormatter.date(from: dateInterval[0]!)!.timeIntervalSince1970)
            let to : Int = Int(dateFormatter.date(from: dateInterval[1]!)!.timeIntervalSince1970)

            query.append(["$gt" : from], forKey: "date")
            query.append(["$lt" : to], forKey: "date")
        }
        
        if (tempInterval[0]! != "") && (tempInterval[1]! != "")
        {
            query.append(["$gt" : tempInterval[0]], forKey: "temperature")
            query.append(["$lt" : tempInterval[1]], forKey: "temperature")
        }
        
        if (setInterval[0]! != "") && (setInterval[1]! != "")
        {
            query.append(["$gt" : setInterval[0]], forKey: "n_sets")
            query.append(["$lt" : setInterval[1]], forKey: "n_sets")
            
        }
        
        
        let matchStage = AggregationPipeline.Stage.match(query)
        var queryGroup : Document? = nil
        
        switch returnType
        {
        case 0:
            queryGroup = [
                "date": ["$avg": ["$unwind" : "$sets"]]
            ]
        case 1: break
        case 2:
            queryGroup = [
            "date": ["$avg": ["$unwind" : "$sets"]]
            ]

        default:
            break
        }
        
        let groupStage = AggregationPipeline.Stage.group(groupDocument: queryGroup!)
        let pipeline : AggregationPipeline = [matchStage, groupStage]
        var cursor : Cursor<Document>? = nil
        do {cursor = try collection.aggregate(pipeline)}catch{}
        
        for document in cursor!{
            print(String(describing: document[0]) + " " + String(describing: document[1]))
        }

    }
    
    static private func fetchResult(response: Array<NSDictionary>)
    {
        /*let list = try? JSONSerialization.jsonObject(with: response, options: []) as! NSDictionary*/
        
        if (self.returnType == 0) // Avg. Force / Date
        {
            /* [id: {"exercise_name": "nome1", "sets": rfjkdfb}, id:{"exercise_name": "nome1", "sets": rfjkdfb}]*/
            var weights : Array<Int> = Array<Int>()

            for exercise in response
            {
                let dateExercise : Int = exercise.value(forKey: "date") as! Int
                let sets : Array<Array<Double>> = exercise.value(forKey: "sets") as! Array<Array<Double>>
                var newAvg : Double = 0
                var n : Int = 0
                var flagFound = false
                
                if (qResult.count == 0)
                {
                    for set in sets
                    {
                        for rep in set
                        {
                            newAvg = newAvg + rep
                            n+=1
                        }
                    }
                
                    weights.append(n)
                    newAvg = newAvg / Double(n)
                    qResult.append((dateExercise, newAvg))
                }
                else
                {
                
                    for i in 0...qResult.count-1
                    {
                        
                        let (dateItem, avgForce) : (Int, Double) = qResult[i] as! (Int, Double)
                        
                        if (dateItem == dateExercise) //
                        {
                            
                            for set in sets
                            {
                                for rep in set // all reps for all sets
                                {
                                    newAvg = newAvg + rep
                                    n+=1
                                }
                            }
                            
                            
                            newAvg = newAvg / Double(n)
                            let weightedNew = newAvg * Double(n)
                            let weightedOld = avgForce * Double(weights[i])
                            let weightedAvg = (weightedNew + weightedOld) / Double(n+weights[i]) // weighted old avg vs weighted new avg over number of total reps
                            weights[i]+=n //the weight of the value in qResult[i] is now the sum of former and new reps.
                            flagFound = true
                            qResult[i] = (dateExercise, weightedAvg)
                            break
                        }
                    }
                    
                    if (!flagFound) // if the exercise was in a day not yet in the query response
                    {
                        for set in sets
                        {
                            for rep in set // all reps for all sets
                            {
                                newAvg = newAvg + rep
                                n+=1
                            }
                        }
                        newAvg = newAvg / Double(n)
                        weights.append(n)
                        qResult.append((dateExercise, newAvg))
                    }
                    
                    
                }
                
                    
            }
        }
        else if(self.returnType == 1)
        { // Avg.Force / Temperature                
            
            var weights : Array<Int> = []

            for exercise in response
            {
                let tempExercise : Double = exercise.value(forKey: "temperature") as! Double
                let sets : Array<Array<Double>> = exercise.value(forKey: "sets") as! Array<Array<Double>>
                var newAvg : Double = 0
                var n : Int = 0
                var flagFound = false
                
                if (qResult.count == 0)
                {
                    for set in sets
                    {
                        for rep in set
                        {
                            newAvg = newAvg + rep
                            n+=1
                        }
                    }
                    
                    weights.append(n)
                    newAvg = newAvg / Double(n)
                    qResult.append((tempExercise, newAvg))
                }
                else
                {
                    
                    for i in 0...qResult.count-1
                    {
                        
                        let (tempItem, avgForce) : (Double, Double) = qResult[i] as! (Double, Double)
                        
                        if (tempItem == tempExercise) //
                        {
                            
                            for set in sets
                            {
                                for rep in set // all reps for all sets
                                {
                                    newAvg = newAvg + rep
                                    n+=1
                                }
                            }
                            
                            flagFound = true
                            newAvg = newAvg / Double(n)
                            let weightedNew = newAvg * Double(n)
                            let weightedOld = avgForce * Double(weights[i])
                            let weightedAvg = (weightedNew + weightedOld) / Double(n+weights[i]) // weighted old avg vs weighted new avg over number of total reps
                            weights[i]+=n //the weight of the value in qResult[i] is now the sum of former and new reps.
                            qResult.append((tempExercise, weightedAvg))
                            break
                        }
                    }
                    
                    
                    if (!flagFound) // if the exercise was at a temperature not yet in the query response
                    {
                        for set in sets
                        {
                            for rep in set // all reps for all sets
                            {
                                newAvg = newAvg + rep
                                n+=1
                            }
                        }
                        
                        newAvg = newAvg / Double(n)
                        weights.append(n)
                        qResult.append((tempExercise, newAvg))
                    }

                    
                }
            }
        }
        else // Calories / Date
        {
            
            for exercise in response
            {
                let dateResponse : Int = exercise.value(forKey: "date") as! Int
                let caloriesResponse : Double = exercise.value(forKey: "calories") as! Double
                var flagFound : Bool = false
                
                if (qResult.count == 0)
                {
                    qResult.append((dateResponse, caloriesResponse))
                }
                else
                {
                    for i in 0...qResult.count-1
                    {
                    
                        let (dateItem, caloriesItem) : (Int, Double) = qResult[i] as! (Int, Double)
                    
                        if (dateItem == dateResponse)
                        {
                            flagFound = true
                            qResult[i] = (dateItem, caloriesItem+caloriesResponse)
                            break
                        }
                    }
                    
                    if (!flagFound){ qResult.append((dateResponse, caloriesResponse))}
                }
            }
        }
    }
}
