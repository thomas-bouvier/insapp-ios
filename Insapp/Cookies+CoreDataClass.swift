//
//  Cookies+CoreDataClass.swift
//  Insapp
//
//  Created by Théo Prigent on 23/06/2020.
//  Copyright © 2020 Théo PRIGENT. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class Cookies: NSManagedObject {
    
    static let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let entityDescription =  NSEntityDescription.entity(forEntityName: "Cookies", in:managedContext)
    
    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(authToken: String, refreshToken: String){
        super.init(entity: Cookies.entityDescription!, insertInto: Cookies.managedContext)
        self.authToken = authToken
        self.refreshToken = refreshToken
        
    }
    
    static func fetch() -> Optional<Cookies>{
        do {
            let results = try Cookies.managedContext.fetch(Cookies.fetchRequest()) as! [Cookies]
            return results.first
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return .none
    }
    
    static func saveContext(){
        do {
            try Cookies.managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    static func delete(){
        let results = try! Cookies.managedContext.fetch(Cookies.fetchRequest()) as! [Cookies]
        for cookies in results {
            Cookies.managedContext.delete(cookies)
        }
        Cookies.saveContext()
    }
    
    static func parseJson(_ json:Dictionary<String, AnyObject>) -> Optional<Cookies>{
        guard let authToken = json[kCredentialsAuthToken] as? String  else { return .none }
        guard let refreshToken  = json[kCredentialsRefreshToken] as? String   else { return .none }
        
        Cookies.delete()
        
        let cookies = Cookies(authToken: authToken, refreshToken: refreshToken)
        
        Cookies.saveContext()
        
        return cookies
    }
    
    static func save(authToken: String, refreshToken: String) {
        
        Cookies.delete()
        
        let cookies = Cookies(authToken: authToken, refreshToken: refreshToken)
        
        Cookies.saveContext()

    }
    
}
