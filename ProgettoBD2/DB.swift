//
//  DB.swift
//  ProgettoBD2
//
//  Created by Luca Pitzalis on 29/06/17.
//  Copyright © 2017 Luca Pitzalis. All rights reserved.
//

import UIKit
import Foundation

class DB: NSObject {

    
    

    
    static private func connect() -> MongoDBCollection
    {
        let dbConn : MongoConnection? = try? MongoConnection.init(forServer : "ds143362.mlab.com:43362")
        
        try? dbConn?.authenticate("testbd2", username: "Pizza94", password: "password")
        
    
        
        return dbConn!.collection(withName: "testbd2.exercises")
    }
    
    static func saveToDb(ex: Exercise)
    {
        let collection : MongoDBCollection = connect()
        print("Connected to " + collection.databaseName)
    }

}
