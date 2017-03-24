//
//  User.swift
//  RemindMe
//
//  Created by vzyw on 2/4/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

class User: NSObject,NSCoding {
    var name = ""
    var head = ""
    var email = ""
    var id = ""
    

    init(_ data:Dictionary<String,Any>){
        email = data["email"] as! String
        head = data["head"] as! String
        name = data["name"] as! String
        id = data["id"] as! String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey:"name")
        aCoder.encode(head, forKey:"head")
        aCoder.encode(email, forKey:"email")
        aCoder.encode(id, forKey:"id")

    }
    public required init?(coder aDecoder: NSCoder) {
        self.name = (aDecoder.decodeObject(forKey: "name") as? String)!
        self.head = (aDecoder.decodeObject(forKey: "head") as? String)!
        self.email = (aDecoder.decodeObject(forKey: "email") as? String)!
        self.id = (aDecoder.decodeObject(forKey: "id") as? String)!
    }
    
}
