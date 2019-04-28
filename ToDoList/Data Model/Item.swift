//
//  Item.swift
//  ToDoList
//
//  Created by Irina Makarova on 11.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
