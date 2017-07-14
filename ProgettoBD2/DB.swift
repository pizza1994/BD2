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
    static var collection : MongoCollection? = nil

    
    static func connect()
    {
        
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
        
    }
    
    
    static func saveToDb(ex: Exercise)
    {
        
        let username: String = UserDefaults.standard.object(forKey: "username") as! String
        
        let exerciseInfo : Document = ["username": username,
                                       "exercise_name": ex.exerciseName,
                                       "n_sets": Int(ex.nSets) as Primitive,
                                       "sets": ex.sets,
                                       "weights": ex.weights,
                                       "temperature": ex.temperature as Primitive,
                                       "date": Int(Calendar.current.startOfDay(for: ex.date).timeIntervalSince1970) as Primitive,
                                       "calories": ex.getTotalCalories() as Primitive
        ]
        
        do
        {
            let _ = try collection?.insert(exerciseInfo)
        }
        catch
        {
            print ("Error")
        }
    }
    
    
    static func loadFromDb(name: String?, dateInterval : [String?], tempInterval: [String?], setInterval: [String?], returnType : Int!)
    {
        qResult = Array<Any>()
        
        let username: String = UserDefaults.standard.object(forKey: "username") as! String
        
        var query : Document = ["username" : ["$eq": username]
        ]
        
        if (name != "")
        {
            let names = name!.components(separatedBy: ",")
            var namesString : String = ""
            for name in names
            {
                namesString=namesString+name+","
            }
            namesString = namesString.substring(to: namesString.index(before: namesString.endIndex))
            let namesArray : [String] = namesString.components(separatedBy: ",")

            
            query.append(["$in" : namesArray], forKey: "exercise_name")

        }
        
        if (dateInterval[0]! != "") && (dateInterval[1]! != "")
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let from : Int = Int(dateFormatter.date(from: dateInterval[0]!)!.timeIntervalSince1970)
            let to : Int = Int(dateFormatter.date(from: dateInterval[1]!)!.timeIntervalSince1970)
            
            query.append(["$gt" : from, "$lt" : to], forKey: "date")
        }
        
        if (tempInterval[0]! != "") && (tempInterval[1]! != "")
        {
            query.append(["$gt" : tempInterval[0], "$lt" : tempInterval[1]], forKey: "temperature")
        }
        
        if (setInterval[0]! != "") && (setInterval[1]! != "")
        {
            query.append(["$gt" : setInterval[0], "$lt" : setInterval[1]], forKey: "n_sets")
            
        }
        print(query)
        
        let queryMatchStage = AggregationPipeline.Stage.match(query)
        var queryGroupStage : AggregationPipeline.Stage? = nil
        var queryUnwindStage : AggregationPipeline.Stage? = nil
        var querySortStage : AggregationPipeline.Stage? = nil
        var pipeline : AggregationPipeline? = nil
        switch returnType
        {
        case 0:
            queryUnwindStage = AggregationPipeline.Stage.unwind("$sets")
            queryGroupStage =  AggregationPipeline.Stage.group("$date", computed: ["sets": .averageOf("$sets")])
            let sort : Sort =  ["date": .descending]
            querySortStage = AggregationPipeline.Stage.sort(sort)
            pipeline = [queryMatchStage, querySortStage!, queryUnwindStage!, queryUnwindStage!, queryGroupStage!]

            
        case 1:
            queryUnwindStage = AggregationPipeline.Stage.unwind("$sets")
            queryGroupStage =  AggregationPipeline.Stage.group("$temperature", computed: ["sets": .averageOf("$sets")])
            let sort : Sort =  ["temperature": .descending]
            querySortStage = AggregationPipeline.Stage.sort(sort)
            pipeline = [queryMatchStage, querySortStage!, queryUnwindStage!, queryUnwindStage!, queryGroupStage!]


        case 2:
            queryGroupStage = AggregationPipeline.Stage.group("$date", computed: ["calories": .sumOf("$calories")])
            let sort : Sort =  ["date": .descending]
            querySortStage = AggregationPipeline.Stage.sort(sort)
            pipeline = [queryMatchStage, querySortStage!, queryGroupStage!]

            
        default:
            break
        }
        
        //let groupStage = AggregationPipeline.Stage(queryGroup!)
        
        
        var cursor : Cursor<Document>? = nil
        do {cursor = try collection?.aggregate(pipeline!)}catch{print("Query error")}
        for document in cursor!{
            switch returnType{
            case 1:
                qResult.append((Double(document[0]!), document[1]!))
            default:
                qResult.append((Int(document[0]!), document[1]!))

            }
            
        }
        print(qResult)

        
        
    }
}
