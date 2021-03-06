//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Irina Makarova on 01.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        do {
            _ = try Realm()
            // delete all from db
            /*
            let realm = try Realm()
            try! realm.write {
                realm.deleteAll()
            }
             */
            
        } catch {
            print("Error initialising new realm, \(error)")
        }
        /*
        do {
            let realm = try Realm()
            
            let data = Data()
            data.name = "Alexandr"
            data.age = 24
            
            
            try realm.write {
                realm.add(data)
            }
        } catch {
            print("Error initialising new realm, \(error)")
        }
        */
        return true
    }
}
