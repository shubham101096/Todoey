//
//  Category.swift
//  Todoey
//
//  Created by Shubham Mishra on 28/03/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name = ""
    @objc dynamic var bgColor = ""
    let items = List<Item>()
}
