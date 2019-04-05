//
//  DataModel.swift
//  ToDoList
//
//  Created by Irina Makarova on 02.04.2019.
//  Copyright © 2019 Irina Makarova. All rights reserved.
//

import Foundation

class Item : Codable {
    var title : String = ""
    var done : Bool = false
    
    init(_ title : String, _ checked : Bool) {
        self.title = title
        self.done = checked
    }
}
