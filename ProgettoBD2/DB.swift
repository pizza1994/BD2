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
        
        exerciseInfo = ["exercise_name": ex.exerciseName as AnyObject, "n_sets": ex.nSets as AnyObject, "sets": ex.sets as AnyObject, "weights": ex.weights as AnyObject, "temperature": ex.temperature as AnyObject, "date": Int(ex.date.timeIntervalSince1970) as AnyObject]
        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .POST, parameters: [], bodyData: exerciseInfo as AnyObject)
            
            perform(request)
            
        } catch let error {
            print("Error \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
    }
    
    static func loadFromDb(name: String?, dateInterval : [String?], tempInterval: [String?], setInterval: [String?], repInterval: [String?], returnType : Int!)
    {
        connect()
        
        var i : Int = 0;
        var params : Array<String> = []
        
        if (name != nil)
        {
            params[i] = "\"exercise_name\": " + name!
            i=i+1
        }
        
        if (dateInterval[0] != nil) && (dateInterval[1] != nil)
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSSxxx"
            let from : Int = Int(dateFormatter.date(from: dateInterval[0]!)!.timeIntervalSince1970)
            let to : Int = Int(dateFormatter.date(from: dateInterval[1]!)!.timeIntervalSince1970)
            params[i] = "\"date\": {$gt: " + String(from) + "}, \"date\":  {$lt: " + String(to) + "}"
            i=i+1
        }
        
        if (tempInterval[0] != nil) && (tempInterval[1] != nil)
        {
            params[i] = "\"temperature\": {$gt: " + String(tempInterval[0]!) + "}, \"date\":  {$lt: " + tempInterval[1]! + "}"
            i=i+1
        }
        
        if (setInterval[0] != nil) && (setInterval[1] != nil)
        {
            params[i] = "\"set\": {$gt: " + setInterval[0]! + "}, \"date\":  {$lt: " + setInterval[1]! + "}"
            i=i+1
        }
        
        if (repInterval[0] != nil) && (setInterval[1] != nil)
        {
            params[i] = "\"set\": {$gt: " + setInterval[0]! + "}, \"date\":  {$lt: " + setInterval[1]! + "}"
            i=i+1
        }
        
        let value = params.joined(separator: ",")
        
        let param = URLRequest.QueryStringParameter(key: "q", value: value)

        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .GET, parameters: [param], bodyData: nil)
            
            print(request)
            perform(request)
            
        } catch let error {
            print("Error \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
    }

}
