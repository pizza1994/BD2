//
//  DB.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 29/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit
import Foundation

class DB: NSObject
{
    static private var collection: MongoDBCollection?
    
    static private func connect()
    {
        do
        {
            let dbConn : MongoConnection? = try? MongoConnection.init(forServer : "ds143362.mlab.com:43362")
            
            try dbConn?.authenticate("testbd2", username: "Pizza94", password: "password")
            
            collection = dbConn!.collection(withName: "testbd2.exercises")
            
            print("Connected to " + (collection?.databaseName)!)
        }
        catch
        {
            print("Connection or autentication failed");
        }
    }
    
    static func saveToDb(ex: Exercise)
    {
        connect()
        
        var exerciseInfo: NSDictionary
        
        exerciseInfo = ["exercise_name": ex.exerciseName, "n_sets": ex.nSets, "date": ex.date, "sets": ex.sets, "weights": ex.weights, "temperature": ex.temperature]
        
        do
        {
            try collection?.insert(exerciseInfo, writeConcern: nil)
        }
        catch
        {
            print("Insert failed")
        }
    }
    
    static func loadFromDb(dateInterval: DateInterval,fullExercise: Bool) -> BSONDocument
    {
        let predicate = MongoKeyedPredicate()
        
        predicate?.keyPath("exercise_name", matches: "bench press")
        var resultDoc: BSONDocument? = try! collection?.findOne(with: predicate)
        var result: [AnyHashable: Any] = BSONDecoder.decodeDictionary(with: resultDoc)
        
        print("Loaded" + resultDoc);

        return resultDoc!
        
    }

}
