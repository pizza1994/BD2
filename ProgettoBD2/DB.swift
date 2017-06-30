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

    static private func connect() -> MongoDBCollection?
    {
        do
        {
            let dbConn : MongoConnection? = try? MongoConnection.init(forServer : "ds143362.mlab.com:43362")
            
            try dbConn?.authenticate("testbd2", username: "Pizza94", password: "password")
            
            let collection : MongoDBCollection = dbConn!.collection(withName: "testbd2.exercises")
            
            print("Connected to " + collection.databaseName)
            return collection
        }
        catch
        {
            print("Connection or autentication failed");
        }
        return nil
    }
    
    static func saveToDb(ex: Exercise)
    {
        let collection : MongoDBCollection? = connect()
        
        var exerciseInfo: NSDictionary = "{" + "exercise_name: " + ex.exerciseName + "," + "n_sets:" + String(ex.nSets) + "," + "date:" + String(ex.date) + "," + "sets:" + ex.sets + ","
            + "weights:" + ex.weights + "," + "temperature:" + ex.temperature + "}"
        
        if collection != nil
        {
            collection?.insert(exerciseInfo)
        }
    }

}
