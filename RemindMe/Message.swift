//
//  Message.swift
//  RemindMe
//
//  Created by vzyw on 2/4/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

class Message: Request {
    func messages(callback:@escaping (String,Array<Dictionary<String,Any>>?)->()){
        self.get(url: Config.measagesUrl, pram: nil) { (msg, arr) in
            if(arr == nil){
                return callback(msg,nil)
            }else{
                return callback(msg,arr)
            }
        }
    }
}
