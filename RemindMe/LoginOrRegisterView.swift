//
//  LoginOrRegisterView.swift
//  RemindMe
//
//  Created by vzyw on 2/5/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit
import WechatKit

class LoginOrRegisterView: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var confirmLabel: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    var register:Bool = false
    @IBOutlet weak var wechatBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var nauLabel: UILabel!
    @IBOutlet weak var pTOe: NSLayoutConstraint!
    
    
    @IBOutlet weak var lTOP: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Kit.setRadius(loginBtn, 5)
        Kit.setRadius(logoImg,15)
        Kit.setRadius(wechatBtn, 5)
        
        self.setupWechatManager()
    }
    @IBAction func registerBtn(_ sender: Any) {
        register = !register
        loginBtn.setTitle(register ? "Register" : "Login", for: .normal)
        wechatBtn.isHidden = !wechatBtn.isHidden
        pTOe.constant = register ? 60 : 15
        lTOP.constant = register ? 89 : 44
        
        emailLabel.placeholder = register ? "Email":"Email/Username"
        usernameLabel.isHidden = !usernameLabel.isHidden
        confirmLabel.isHidden = !confirmLabel.isHidden
        nauLabel.isHidden = !nauLabel.isHidden
        registerBtn.setTitle(register ? "Login" : "Register Now", for: .normal)
        orLabel.isHidden = !orLabel.isHidden
        animation(0.2)
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(0.3)
        let rect = CGRect(origin: CGPoint(x: 0, y: -160), size: self.view.frame.size)
        self.view.frame = rect
        UIView.commitAnimations()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(0.2)
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.view.frame.size)
        self.view.frame = rect
        UIView.commitAnimations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func animation(_ time:Double){
        UIView.animate(withDuration: time, animations: {
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func loginBtn(_ sender: Any) {
        let name = emailLabel.text
        let password = passwordLabel.text
        if(name?.characters.count == 0 ){
            return self.noticeTop("email is empty!")
        }
        if(password?.characters.count == 0){
            return self.noticeTop("password is empty!")
        }
        
        self.pleaseWait()
        if(register){
            let username = usernameLabel.text
            let confirm = confirmLabel.text
            if(username?.characters.count == 0) {
                return self.noticeTop("username is empty!")
            }
            if(confirm != password){
                return self.noticeTop("password not match!")
            }
            Register().register(email: name!, name: username!, password: password!, callback: { (msg, flag) in
                self.clearAllNotice()
                if(flag){
                    self.successNotice(msg)
                    self.emailLabel.text = name!
                    self.passwordLabel.text = password!
                    self.registerBtn(self.registerBtn)
                }else{
                    self.noticeTop(msg)
                }
            })
            
            
        }else{
            
            Login().login(name: name!, password: password!, callback: { (msg, user) in
                self.clearAllNotice()
                if(user != nil){
                    self.successNotice(msg)
                    Kit.setUserdefault(key: "user", value: user!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadNotification"), object: nil)
                    
                    self.dismiss(animated: true, completion: nil)
                }else{
                    self.errorNotice(msg)
                }
                
            })
            
        }
        
    }
    @IBAction func wechatAction(_ sender: Any) {
        if WechatManager.sharedInstance.isInstalled() {
            WechatManager.sharedInstance.checkAuth { result in
                switch result {
                case .failure(let errCode):
                    print (errCode)
                    self.errorNotice("error!")
                case .success( _):
                    self.wechatLogin()
                }
            }
        } else {
            self.errorNotice("error!")
        }
        
    }
   
    func wechatLogin(){
        
        guard let openid = WechatManager.openid else {
            self.errorNotice("error!")
            return
        }
        
        guard openid.characters.count > 0 else {
            print("还没有登录,或openid没有正确设置")
            return
        }
        
        self.pleaseWait()
        WechatManager.sharedInstance.getUserInfo { result in
            switch result {
            case .failure(let errCode):
                print(errCode)
            case .success(let value):
                let unionid = value["unionid"] as? String
                let nickname = value["nickname"] as? String
                let headImg = value["headimgurl"] as? String
                                
                Login().wechatLogin(unionid:unionid!,name:nickname!, callback: { (msg, user) in
                    self.clearAllNotice()
                    if(user != nil){
                        self.successNotice("success")
                        Kit.setUserdefault(key: "user", value: user!)
                        Kit.setUserdefault(key: "wechatHead", value: headImg)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadNotification"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        self.errorNotice(msg)
                    }
                })
            }
        }
        

    }
}

extension LoginOrRegisterView {
    fileprivate func setupWechatManager() {
        //设置appid
        WechatManager.appid = Config.wechatId
        WechatManager.appSecret = Config.wechatSecret
        //如果不设置 appSecret 则无法获取access_token 无法完成认证
    }
}



