//
//  Config.swift
//  RemindMe
//
//  Created by vzyw on 2/4/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

let IP_D = "http://172.20.10.2";

let IP = IP_D + "/index.php";
let LOGIN = "/login"
let LOGIN_OUT = "/loginout"
let REGISTER = "/register"
let FRIENDS = "/friends"
let UPLOAD = "/upload"
let VIDEOS = "/videos"
let SERARCH = "/search"
let ADD_FRIEND = "/request"
let NEW_FRIEND = "/newfriends"
let DECIDE = "/decide"
let HEAD = "/head"
let REGISTRATION = "/registration"

class Config: NSObject {
    static let loginUrl = IP + LOGIN
    static let loginoutUrl = IP + LOGIN_OUT
    static let registerUrl = IP + REGISTER
    static let friendsUrl = IP + FRIENDS
    static let uploadUrl = IP + UPLOAD
    static let measagesUrl = IP + VIDEOS
    static let searchUrl = IP + SERARCH
    static let addFriendUrl = IP + FRIENDS + ADD_FRIEND
    static let newFriendUrl = IP + FRIENDS + NEW_FRIEND
    static let decideUrl = IP + FRIENDS + DECIDE
    static let headUrl = IP + HEAD
    static let registrationUrl = IP + REGISTRATION + "/update"
    static let publicUrl = IP + "/public"
    
    static func shareUrl (friend:String,key:String) ->String{
        return (IP  + "/page?key=" + key + "&friend=" + friend)
    }
    static func wechatUserinfo(access_token:String,openid:String) -> String{
        return ("https://api.weixin.qq.com/sns/userinfo?access_token=" + access_token + "&openid=" + openid)
    }
    
    static let deleteMessageUrl = IP + VIDEOS + "/deleteVideo"
    
    //需要测试微信分享请填入自己的wechatid & wechatSecret
    static let wechatId = "**"
    static let wechatSecret = "**"
}
