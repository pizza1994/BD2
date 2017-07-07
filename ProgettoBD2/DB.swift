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
    
    private static func perform(_ request: URLRequest) -> Data
    {
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
            var or = "{$or: {"
            for n in names
            {
                or = or + ("\"exercise_name\": " + "\"" + n + "\", ")
            }
            
            or = or.substring(to: or.index(before: or.endIndex))
            
            or = or + "}"
            params.append(or);
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
            params.append("\"temperature\": {$gt: " + String(tempInterval[0]!) + "}, \"temperature\":  {$lt: " + tempInterval[1]! + "}")
            
        }
        
        if (setInterval[0]! != "") && (setInterval[1]! != "")
        {
            params.append("\"n_sets\": {$gt: " + setInterval[0]! + "}, \"n_sets\":  {$lt: " + setInterval[1]! + "}")
            
        }
        
        var value = params.joined(separator: ",")
        
        value = "{" + value + "}"
        
        switch returnType
        {
            case 0:
                value = value + "{\"exercise_name\": 1, \"sets\": 1}" //prendere solo i set con abbastanza ripetizioni dell'insieme di set restituito
            case 1:
                value = value + "{\"exercise_name\": 1, \"sets\": 1, \"temperature\": 1}"
            default:
                value = value + "{\"exercise_name\": 1, \"calories\": 1}"
        }
        
        let param = URLRequest.QueryStringParameter(key: "q", value: "{" + value + "}")

        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .GET, parameters: [param], bodyData: nil)
            
            print(request)
            var response : Data = perform(request)
            
            let json = try? JSONSerialization.jsonObject(with: response, options: []) as! NSDictionary
            

            if (returnType == 0)
            {
                
                /* [id: {"exercise_name": "nome1", "sets": rfjkdfb}, id: {"exercise_name": "nome1", "sets": rfjkdfb}]*/
                var keyValues : NSDictionary
                var average : Int = 0
                var n : Int = 0
                var setValues : Array<Double>
                
                for element in json!
                {
       
                        if (element.key == "sets"){
                            setValues.append(element.value as! Double)
                        }
                        
                        tot = tot + rep
                        n = n + 1
                    
                }
                average = average / n
                keyValues.
                
            }
            
            
        } catch let error {
            print("Error \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
    }

}
