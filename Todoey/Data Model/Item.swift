//
//  Item.swift
//  Todoey
//
//  Created by Shubham Mishra on 21/02/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation


struct Item: Codable {
    let item: String
    var done: Bool
    init(item: String, done: Bool = false) {
        self.item = item
        self.done = done
    }
}

