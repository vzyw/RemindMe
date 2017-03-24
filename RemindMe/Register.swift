//
//  Register.swift
//  RemindMe
//
//  Created by vzyw on 2/6/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

class Register: Request {
    public func register(email:String , name:String , password:String,callback:@escaping (String,Bool)->()){
        let postData  = ["email":email,"name":name,"password":password]
        self.post(url: Config.registerUrl, pram: postData) { (msg, arr) in
            if(arr == nil){
                callback(msg,false)
            }else{
                callback(msg,true)
            }
        }
    }
}
    
