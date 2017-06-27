//
//  File.swift
//  ProgettoBD2
//
//  Created by Elisa on 27/06/2017.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import Foundation
import MongoKitten
import Exercise


class DB{
    
    var exerciseName : String!
    var nSets : UInt8!
    var date : NSDate!
    var sets = [[Double]]()
    var temperature : UnitTemperature!

    class func saveToDB(ex: Exercise)
    {
        let database = try Database("mongodb://Elisa:APmPFqiJROPsQL39@estimove-shard-00-00-dpfxk.mongodb.net:27017,estimove-shard-00-01-dpfxk.mongodb.net:27017,estimove-shard-00-02-dpfxk.mongodb.net:27017/estimove?ssl=true&replicaSet=Estimove-shard-0&authSource=admin")
        
        if database.server.isConnected
        {
            print ("Succesfully connected!")
            
            let document: Document =
            [
                "exercise_name": ex.exerciseName,
                "n_sets": ex.n_sets,
                "date": ex.date,
                "sets": ex.sets,
                "temperature": ex.temperature,
                "calories": 0
            ]
            let collection = database["Estimove"]
            var _id = try collection.insert(document)
            
            if _id != nil
            {
                print ("Exercise added!")
            }
            else
            {
                print ("Error inserting exercise")
            }
        }
        else
        {
            print ("Connection failed")
        }
    }
}

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
