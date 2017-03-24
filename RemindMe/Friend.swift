//
//  Friend.swift
//  RemindMe
//
//  Created by vzyw on 2/6/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

class Friend: Request {
    func friends(callback:@escaping ([User]?,Bool)->())  {
        self.get(url: Config.friendsUrl, pram:nil) { (msg, arr) in
            if(arr == nil){
                callback(nil,false)
            }else{
                var users = [User]()
                for u in arr!{
                    let user = User(u)
                    users.append(user)
                }
                callback(users,true)
                
            }
        }
    }
}
