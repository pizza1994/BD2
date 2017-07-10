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
    static private var returnType: Int?
    static private var qResult : Array<Any> = Array<Any>()
    
    
    static private func connect()
    {
        configuration = MongoLabApiV1Configuration(databaseName: "testbd2", apiKey:"jGHlKVFu8-6dTTG_m6CTbmFdkqP4XaNG")
        
    }
    
    private static func perform(_ request: URLRequest)
    {
        let _ = client.perform(request) {
            result in
            
            switch result {
            case let .success(response):
                print("Success in request \(response)")
                if (DB.returnType != nil)
                {
                    DB.fetchResult(response: response as! Array<NSDictionary>)
                }
                
            case let .failure(error):
                print("Error in request \(error)")
            }
        }
        
    }
    
    static func saveToDb(ex: Exercise)
    {
        connect()
        
        var exerciseInfo: [String : AnyObject]
        
        exerciseInfo = ["exercise_name": ex.exerciseName as AnyObject, "n_sets": ex.nSets as AnyObject, "sets": ex.sets as AnyObject, "weights": ex.weights as AnyObject, "temperature": ex.temperature as AnyObject, "date": Int(ex.date.timeIntervalSince1970) as AnyObject, "calories": ex.getTotalCalories() as AnyObject]
        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .POST, parameters: [], bodyData: exerciseInfo as AnyObject)
            
            perform(request)
            
        } catch let error {
            print("Error \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
    }
    
    static func loadFromDb(name: String?, dateInterval : [String?], tempInterval: [String?], setInterval: [String?], repInterval: [String?], returnType : Int!) -> Array<Any>
    {
        connect()
                        
        var params : Array<String> = Array<String>()
        
        if (name != "")
        {
            let names = name!.components(separatedBy: ", ")
            var or = "$or:["
            for n in names
            {
                or = or + ("{\"exercise_name\":" + "\"" + n + "\"},")
            }
            
            or = or.substring(to: or.index(before: or.endIndex))
            
            or = or + "]"
            params.append(or);
        }
        
        if (dateInterval[0]! != "") && (dateInterval[1]! != "")
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let from : Int = Int(dateFormatter.date(from: dateInterval[0]!)!.timeIntervalSince1970)
            let to : Int = Int(dateFormatter.date(from: dateInterval[1]!)!.timeIntervalSince1970)
            params.append("\"date\":{$gt:" + String(from) + "}, \"date\":  {$lt:" + String(to) + "}")
            
        }
        
        if (tempInterval[0]! != "") && (tempInterval[1]! != "")
        {
            params.append("\"temperature\":{$gt:" + String(tempInterval[0]!) + "},\"temperature\":{$lt:" + tempInterval[1]! + "}")
            
        }
        
        if (setInterval[0]! != "") && (setInterval[1]! != "")
        {
            params.append("\"n_sets\":{$gt:" + setInterval[0]! + "}, \"n_sets\":{$lt:" + setInterval[1]! + "}")
            
        }
        
        let selection = params.joined(separator: ",")
        var projection = ""
        
        switch returnType
        {
            case 0:
                projection = "{\"exercise_name\":1,\"sets\":1}" //prendere solo i set con abbastanza ripetizioni dell'insieme di set restituito
            case 1:
                projection = "{\"exercise_name\":1,\"sets\":1,\"temperature\":1}"
            case 2:
                projection = "{\"exercise_name\":1,\"calories\":1}"
            default:
                break
        }

        let param1 = URLRequest.QueryStringParameter(key: "q", value: "{" + selection + "}")
        let param2 = URLRequest.QueryStringParameter(key: "f", value:projection)

        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .GET, parameters: [param1, param2], bodyData: nil)
            
            self.returnType = returnType
            print(request)
            perform(request)
            
        } catch let error {
            print("Error in load \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
        
        return qResult
    }
    
    static private func fetchResult(response: Array<NSDictionary>)
    {
        /*let list = try? JSONSerialization.jsonObject(with: response, options: []) as! NSDictionary*/
        
        if (self.returnType == 0 || self.returnType == 1)
        {
            /* [id: {"exercise_name": "nome1", "sets": rfjkdfb}, id:{"exercise_name": "nome1", "sets": rfjkdfb}]*/
            var ex_average : Double = 0
            var n : Double = 0
                
            for element in response
            {
                let ex_name : String = element.value(forKey: "exercise_name") as! String
                let sets : Array<Array<Double>> = element.value(forKey: "sets") as! Array<Array<Double>>
                    
                for set in sets
                {
                    for rep in set
                    {
                        ex_average = ex_average + (rep)
                        n = n + 1
                    }
                }
                ex_average = ex_average / n
                qResult.append([ex_name, ex_average])
                print("name: " + ex_name + " , force: " + String(ex_average))
                if (self.returnType == 1)
                {
                    let temperature : Double = element.value(forKey: "temperature") as! Double
                    print(", temperature: \(temperature)")
                    qResult.insert([ex_name, ex_average, temperature], at: qResult.count-1)
                }
            }
        }
        else
        {
            for element in response
            {
                let ex_name : String = element.value(forKey: "exercise_name") as! String
                let calories : Double = element.value(forKey: "calories") as! Double
                qResult.append([ex_name, calories])
                print("name: " + ex_name + ", calories: \(calories)")
            }
        }
        
    }

}
