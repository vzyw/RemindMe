//
//  Login.swift
//  RemindMe
//
//  Created by vzyw on 2/6/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit
import Alamofire


class Login: NSObject {
    func login(name:String ,password:String,callback:@escaping (String,User?)->()){
        let postData = ["name":name,"password":password]
        
        Alamofire.request(Config.loginUrl,method: .post, parameters: postData, encoding: URLEncoding.default).responseJSON { (res) in
            switch res.result{
            case .success:
                let data = res.result.value as! Dictionary<String,Any>
                if(data["code"] as! Int == 0){
                    let user = (data["data"] as! Array)[0] as Dictionary<String,Any>
                    return callback("login success",User(user))
                }else{
                    return callback(data["msg"] as! String,nil)
                }
            case .failure( _):
                return callback("Network error!",nil)
            }
            
        }
    }
    
    func wechatLogin(unionid:String,name:String,callback:@escaping(String,User?)->()){
        let postData = ["name":name,"code":unionid]
        Alamofire.request(Config.loginUrl,method: .post, parameters: postData, encoding: URLEncoding.default).responseJSON { (res) in
            switch res.result{
            case .success:
                let data = res.result.value as! Dictionary<String,Any>
                if(data["code"] as! Int == 0){
                    let user = (data["data"] as! Array)[0] as Dictionary<String,Any>
                    return callback("login success",User(user))
                }else{
                    return callback(data["msg"] as! String,nil)
                }
            case .failure( _):
                return callback("Network error!",nil)
            }
        }
    }
    
    
    static func loginout(){
        Alamofire.request(Config.loginoutUrl)
    }
    
    static func loginCheck(callback:@escaping (Bool)->()){
        Alamofire.request(Config.loginUrl).responseJSON { (res) in
            switch res.result{
            case .success:
                let data = res.result.value as! Dictionary<String,Any>
                if(data["code"] as! Int == -1){
                    callback(false)
                }else{
                    callback(true)
                }
            default:
                callback(false)
            }
        }
    }
}
