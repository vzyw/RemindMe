//
//  LoginCheckView.swift
//  RemindMe
//
//  Created by vzyw on 2/6/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit



class LoginCheckView: UIViewController {
    static var user:User? = (Kit.getUserdefault(key: "user") as? User)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginCheckView.didReceiveReloadNotification), name: NSNotification.Name(rawValue: "ReloadNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Login.loginCheck { (flag) in            
            if(!flag){
                let view = Kit.viewById(id: "loginView")
                self.present(view, animated: true, completion: {
                    self.view = nil
                })
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveReloadNotification(){
        NotificationCenter.default.removeObserver(self)
        self.view = nil
        LoginCheckView.user = (Kit.getUserdefault(key: "user") as? User)
    }
    
    func getMyselfInstance() -> User?{
        return LoginCheckView.user
    }

}
