//
//  File.swift
//  RemindMe
//
//  Created by vzyw on 2/6/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

class File: NSObject {
    static func image(url:String,callback:@escaping (UIImage?)->()) {
        if(url.characters.count == 0){
            return callback(UIImage(named: "friend"))
        }
        let URL = IP_D + url
        
        let name = Kit.getName(url: URL)
        let path = Kit.fileExist(fileName: name)
        if(path == nil){
            Kit.downloadFile(url: URL, callback: { (path) in
                callback(UIImage(contentsOfFile: path!))
            })
        }else{
            callback(UIImage(contentsOfFile: path!))
        }
    }
    
    static func audio(url:String,callback:(String)->()){
        
    }
    
}
