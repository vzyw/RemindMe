//
//  Kit.swift
//  RemindMe
//
//  Created by vzyw on 2/4/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit
import Alamofire
class Kit: NSObject {
    
    static func documentPath()->String{
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
//      big problem. what the diffirent between them???????
//        let urlForDocument = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask)
//        return (urlForDocument[0].absoluteString)
    }
    
    static func clearCache(cachePath:String) {
        
        // 取出文件夹下所有文件数组
        let fileArr = FileManager.default.subpaths(atPath: cachePath)
        
        // 遍历删除
        for file in fileArr! {
            
            let path = cachePath + "/" + file
            if (Kit.fileExist( fileName: file ) != nil) {
                    try? FileManager.default.removeItem(atPath: path)
            }
        }
    }
    static func fileSizeOfCache()-> Double {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        let cachePath = Kit.documentPath()
        //缓存目录路径
        // 取出文件夹下所有文件数组
        let fileArr = FileManager.default.subpaths(atPath: cachePath)
        //快速枚举出所有文件名 计算文件大小
        var size = 0
        for file in fileArr! {
            // 把文件名拼接到路径中
            let path = cachePath + "/" + file
            // 取出文件属性
            let floder = try! FileManager.default.attributesOfItem(atPath: path)
            // 用元组取出文件大小属性
            for (abc, bcd) in floder {
                // 累加文件大小
                if abc == FileAttributeKey.size {
                    size += (bcd as AnyObject).integerValue
                }
            }
        }
        
        let mm = Double(size) / 1024.0 / 1024.0
        
        return mm
    }
    
    static func fileExist(fileName:String) -> String?{
        let filePath:String = NSHomeDirectory() + "/Documents/"  + fileName
        if(FileManager.default.fileExists(atPath: filePath)){
            return  filePath
        }
        return nil
    }
    
    static func downloadFile(url:String,callback:@escaping (String?)->()){
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (URL(fileURLWithPath: documentPath() + "/" + getName(url: url)), [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(url, to: destination).response { response in
            if response.error == nil, let path = response.destinationURL?.path {
                return callback(path)
            }
            return callback(nil)
        }
    }
    
    static func getName(url:String)->String{
        let name =  url.characters.split {$0 == "/"}.map(String.init)
        return name.last!
    }
    
    static func now()->Date{
        //return Date.locale
        let date = Date.init(timeIntervalSinceNow: 0)
        return date;
    }
    static func stringToDate(date:String,formart:String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formart
        //dateFormatter.timeZone = NSTimeZone.system
        return dateFormatter.date(from: date)!
    }
    
    static func dateToString(date:Date,format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    static func viewById( id:String) -> UIViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: nil);
        let view = storyBoard.instantiateViewController(withIdentifier: id);
        return view;
    }
    
    static func setRadius(_ view:UIView , _ radius:CGFloat){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
    
    static func setUserdefault(key:String,value:Any?){
        let userDefaults = UserDefaults.standard
        
        if(value != nil){
            let data = NSKeyedArchiver.archivedData(withRootObject: value!)
            userDefaults.set(data,forKey:key)
            return
        }
        userDefaults.set(value,forKey:key)
        userDefaults.synchronize()
    }
    static func getUserdefault(key:String)-> Any?{
        let userDefaults = UserDefaults.standard
        let data = userDefaults.object(forKey: key)
        if(data != nil) {
            return NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
        }
        return nil
    }
    
    static func deviceWidth() -> CGFloat{
        return UIScreen.main.bounds.size.width;
    }
    static func deviceHeight() -> CGFloat{
        return UIScreen.main.bounds.size.height;
    }
    
    
    static func getCurrentVC()->UIViewController{
        var result:UIViewController!
        
        
        var window = UIApplication.shared.keyWindow
        if (window?.windowLevel != UIWindowLevelNormal){
            let windows = UIApplication.shared.windows
            for tmpWin in windows{
                if (tmpWin.windowLevel == UIWindowLevelNormal){
                    window = tmpWin
                    break
                }
            }
        }
        
        let frontView = window?.subviews[0]
        let nextResponder = frontView?.next
        
        if (nextResponder is UIViewController){
            result = nextResponder as! UIViewController!

        }else{
            result = window?.rootViewController
        }
        
        return result;
    }
    
}
