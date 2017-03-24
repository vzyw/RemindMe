//
//  Request.swift
//  RemindMe
//
//  Created by vzyw on 2/6/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit
import Alamofire

class Request: NSObject {
    func get(url:String,pram:Dictionary<String,String>?,callback:((String,Array< Dictionary<String,Any> >?)->())?){
        Alamofire.request(url,method: .get, parameters: pram, encoding: URLEncoding.default).responseJSON { (res) in
            switch res.result{
            case .success:
                let data = res.result.value as! Dictionary<String,Any>
                if(data["code"] as! Int == 0){
                    callback?(data["msg"] as! String,data["data"] as? Array< Dictionary<String,Any> >)
                    return
                }else{
                    callback?(data["msg"] as! String,nil)
                    return
                }
                
            case .failure( _):
                if(callback != nil){
                    callback!("Network error",nil)
                }
            }
        }
    }
    
    func post(url:String , pram:Dictionary<String,String>?,callback:((String,Array< Dictionary<String,Any> >?)->())?){
        Alamofire.request(url,method: .post, parameters: pram, encoding: URLEncoding.default).responseJSON { (res) in
            switch res.result{
            case .success:
                let data = res.result.value as! Dictionary<String,Any>
                if(data["code"] as! Int == 0){
                    callback?(data["msg"] as! String,data["data"] as? Array< Dictionary<String,Any> >)
                    return
                }else{
                    callback?(data["msg"] as! String,nil)
                    return
                }
                
            case .failure( _):
                if(callback != nil){
                    callback!("Network error",nil)
                }
            }

        }
    }
}

