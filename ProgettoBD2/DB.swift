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
          
                        
        var params : Array<String> = Array<String>()
        
        if (name != "")
        {
            let names = name!.components(separatedBy: ", ")
            for n in names{
                params.append("\"exercise_name\": " + "\"" + n + "\"")
            }
            
        }
        
        if (dateInterval[0]! != "") && (dateInterval[1]! != "")
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let from : Int = Int(dateFormatter.date(from: dateInterval[0]!)!.timeIntervalSince1970)
            let to : Int = Int(dateFormatter.date(from: dateInterval[1]!)!.timeIntervalSince1970)
            params.append("\"date\": {$gt: " + String(from) + "}, \"date\":  {$lt: " + String(to) + "}")
            
        }
        
        if (tempInterval[0]! != "") && (tempInterval[1]! != "")
        {
            params.append("\"temperature\": {$gt: " + String(tempInterval[0]!) + "}, \"date\":  {$lt: " + tempInterval[1]! + "}")
            
        }
        
        if (setInterval[0]! != "") && (setInterval[1]! != "")
        {
            params.append("\"set\": {$gt: " + setInterval[0]! + "}, \"date\":  {$lt: " + setInterval[1]! + "}")
            
        }
        
        if (repInterval[0]! != "") && (setInterval[1]! != "")
        {
            params.append("\"set\": {$gt: " + setInterval[0]! + "}, \"date\":  {$lt: " + setInterval[1]! + "}")
           
        }
        
        let value = params.joined(separator: ",")
        
        let param = URLRequest.QueryStringParameter(key: "q", value: "{" + value + "}")

        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .GET, parameters: [param], bodyData: nil)
            
            print(request)
            perform(request)
            
        } catch let error {
            print("Error \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
    }

}
