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
    static public var qResult : Array<Any> = Array<Any>()
    
    
    static private func connect()
    {
        configuration = MongoLabApiV1Configuration(databaseName: "testbd2", apiKey:"jGHlKVFu8-6dTTG_m6CTbmFdkqP4XaNG")
        
    }
    
    private static func perform(_ request: URLRequest, complete:@escaping ((_ isOK:Bool)->()))
    {
        let _ = client.perform(request) {
            result in
            
            switch result {
            case let .success(response):
                print("Success in request \(response)")
                if (DB.returnType != nil)
                {
                    DB.fetchResult(response: response as! Array<NSDictionary>)
                    complete(true)
                }
                
            case let .failure(error):
                print("Error in request \(error)")
            }
        }
        
    }
    
    static func saveToDb(ex: Exercise)
    {
        connect()
        
        let username: AnyObject = UserDefaults.standard.object(forKey: "username") as AnyObject
        var exerciseInfo: [String : AnyObject]
        
        exerciseInfo = ["username": username, "exercise_name": ex.exerciseName as AnyObject, "n_sets": ex.nSets as AnyObject, "sets": ex.sets as AnyObject, "weights": ex.weights as AnyObject, "temperature": ex.temperature as AnyObject, "date": Int(ex.date.timeIntervalSince1970) as AnyObject, "calories": ex.getTotalCalories() as AnyObject]
        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .POST, parameters: [], bodyData: exerciseInfo as AnyObject)
            
            perform(request){_ in 

            }
            
        } catch let error {
            print("Error \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
    }
    
    static func loadFromDb(name: String?, dateInterval : [String?], tempInterval: [String?], setInterval: [String?], returnType : Int!, handleComplete:@escaping ((_ isOK:Bool)->()))
    {
        connect()
        qResult = Array<Any>()
        
        let username: String = UserDefaults.standard.object(forKey: "username") as! String
                        
        var params : Array<String> = Array<String>()
        
        params.append("\"username\":" + "\"" + username + "\"")
        
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
            params.append("\"date\":{$gt:" + String(from) + ",$lt:" + String(to) + "}")
            
        }
        
        if (tempInterval[0]! != "") && (tempInterval[1]! != "")
        {
            params.append("\"temperature\":{$gt:" + String(tempInterval[0]!) + ",$lt:" + tempInterval[1]! + "}")
            
        }
        
        if (setInterval[0]! != "") && (setInterval[1]! != "")
        {
            params.append("\"n_sets\":{$gt:" + setInterval[0]! + ",$lt:" + setInterval[1]! + "}")
            
        }
        
        let selection = params.joined(separator: ",")
        var projection = ""
        
        switch returnType
        {
            case 0:
                projection = "{\"date\":1,\"sets\":1}" //prendere solo i set con abbastanza ripetizioni dell'insieme di set restituito
            case 1:
                projection = "{\"sets\":1,\"temperature\":1}"
            case 2:
                projection = "{\"date\":1,\"calories\":1}"
            default:
                break
        }

        let param1 = URLRequest.QueryStringParameter(key: "q", value: "{" + selection + "}")
        let param2 = URLRequest.QueryStringParameter(key: "f", value:projection)

        do {
            let request = try MongoLabURLRequest.urlRequestWith(configuration!, relativeURL: "collections/exercises", method: .GET, parameters: [param1, param2], bodyData: nil)
            
            self.returnType = returnType
            print(request)
            perform(request){
                ok in
                DispatchQueue.main.async() {
                    handleComplete(true)

                }
            }

            
        } catch let error {
            print("Error in load \((error as? ErrorDescribable ?? MongoLabError.requestError).description())")
        }
        
    }
    
    static private func fetchResult(response: Array<NSDictionary>)
    {
        /*let list = try? JSONSerialization.jsonObject(with: response, options: []) as! NSDictionary*/
        
        if (self.returnType == 0)
        {
            /* [id: {"exercise_name": "nome1", "sets": rfjkdfb}, id:{"exercise_name": "nome1", "sets": rfjkdfb}]*/
            var ex_average : Double = 0
            var n : Double = 0
                
            for element in response
            {
                let date : Int = element.value(forKey: "date") as! Int
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
                qResult.append((date, ex_average))
     
            }
        }
        else if(self.returnType == 1){
            
            var ex_average : Double = 0
            var n : Double = 0
            
            for element in response
            {
                let temperature : Int = element.value(forKey: "temperature") as! Int
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
                qResult.append((temperature, ex_average))
                
            }

            
        }
        else
        {
            
            for element in response
            {
                let dateResponse : Int = element.value(forKey: "date") as! Int
                let caloriesResponse : Double = element.value(forKey: "calories") as! Double
                var flagFound : Bool = false
                
                if (qResult.count == 0)
                {
                    qResult.append((dateResponse, caloriesResponse))
                }
                else
                {
                    for i in 0...qResult.count-1
                    {
                    
                        let (dateItem, caloriesItem) : (Int, Double) = qResult[i] as! (Int, Double)
                    
                        if (dateItem == dateResponse)
                        {
                            flagFound = true
                            qResult[i] = (dateItem, caloriesItem+caloriesResponse)
                            break
                        }
                    }
                    
                    if (!flagFound){ qResult.append((dateResponse, caloriesResponse))}
                }
            }
        }
    }
}
