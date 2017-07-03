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
    static private var configuration: MongoLabApiV1Configuration?
    static private var client = MongoLabClient()
    static private var collectionsService: CollectionsService?
    static private var documentsService: DocumentsService?
    static private var documentService: DocumentService?
    
    static private func connect()
    {
        configuration = MongoLabApiV1Configuration(databaseName: "testbd2", apiKey:"jGHlKVFu8-6dTTG_m6CTbmFdkqP4XaNG")
        
    }
    
    private static func perform(_ request: URLRequest) {
        let _ = client.perform(request) {
            result in
            
            switch result {
            case let .success(response):
                print("Success \(response)")
                
            case let .failure(error):
                print("Error \(error)")
                
            }
        }
    }
    
    static func saveToDb(ex: Exercise)
    {
        connect()
        
        var exerciseInfo: [String : AnyObject]
        
        exerciseInfo = ["exercise_name": ex.exerciseName as AnyObject, "n_sets": ex.nSets as AnyObject, "sets": ex.sets as AnyObject, "weights": ex.weights as AnyObject, "temperature": ex.temperature as AnyObject,"date": Int(ex.date)]
        
        
        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .POST, parameters: [], bodyData: exerciseInfo as AnyObject)
            
            perform(request)
            
        } catch let error {
            print("Error \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
    }
    
    //static func loadFromDb(dateInterval: DateInterval,fullExercise: Bool)
    static func loadFromDb()
    {
        connect()
        
        let lastMonth : Int = Int((Calendar.current.date(byAdding: .day, value: 30, to: Date())?.timeIntervalSince1970)!)
        let today: Int = Int(Date().timeIntervalSince1970)
        
        let param = URLRequest.QueryStringParameter(key: "q", value: "{\"date\": {$lt: " + today + "}, {$gt: " + lastMonth + "}")
        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .GET, parameters: [param], bodyData: nil)
            
            print(request)
            perform(request)
            
        } catch let error {
            print("Error \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
    }
    


}
