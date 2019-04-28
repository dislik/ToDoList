//
//  Category.swift
//  ToDoList
//
//  Created by Irina Makarova on 11.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    
    let items = List<Item>()
    /*
    init() {}

    init(name: String) {
        self.name = name
    }
     */
}
