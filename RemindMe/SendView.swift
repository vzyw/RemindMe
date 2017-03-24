//
//  SendView.swift
//  RemindMe
//
//  Created by vzyw on 2/4/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit
import Alamofire
import WechatKit
class SendView: LoginCheckView,ContactsViewDelegate {
    
    var url:String?

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var sendWechat: UIButton!
   
    
    @IBOutlet weak var friendBtn: UIButton!
    
    @IBOutlet weak var friendNameLabel: UILabel!
    var friend:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Prepare send"
        datePicker.minimumDate = Kit.now()
        datePicker.setValue(UIColor.white, forKey: "textColor")
        timePicker.setValue(UIColor.white, forKey: "textColor")
        
        self.initFriend()
        self.setupWechatManager()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        Kit.setRadius(friendBtn, friendBtn.frame.size.height/2)
        
        Kit.setRadius(sendBtn, 5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseFriend(_ sender: Any) {
        let view = Kit.viewById(id: "ContactsView") as! ContactsView
        view.view.backgroundColor = UIColor(red:0.26, green:0.57, blue:0.32, alpha:1)
        view.delegate = self
        self.present(view, animated: true, completion: nil)
    }
    
    
    @IBAction func send(_ sender: UIButton) {
        
        if(friend == nil){
            self.noticeTop("please select a friend")
            return
        }
        var _public  = "0"
        
        if(sender == sendWechat){
            _public = "1"
            if(!WechatManager.sharedInstance.isInstalled()){
                self.noticeTop("wechat not installed!")
                return
            }
        }
        
        let date = datePicker.date;
        let time = timePicker.date;
        
        let dateStr = Kit.dateToString(date: date, format: "yyyy-MM-dd")
        let timeStr = Kit.dateToString(date: time, format: "HH:mm:00")
        
        let datetime = dateStr + " " + timeStr
        
        let datePicked = Kit.stringToDate(date: datetime, formart: "yyyy-MM-dd HH:mm:ss")
        let t = datePicked.timeIntervalSinceNow
        if(t<0){
            noticeTop("You should choose a future time!")
            return
        }
        
        let parameters = [
            "friend_id": self.friend!.id,
            "play_time": datetime,
            "public":_public
        ]
        
        
        let fileUrl = URL(fileURLWithPath: self.url!)
        self.pleaseWait()
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileUrl, withName: "file", fileName: "video.aac", mimeType: "audio/aac")
            for (key, value) in parameters {
                multipartFormData.append((value.data(using: .utf8))!, withName: key)
            }}, to: Config.uploadUrl, method: .post, headers: nil,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON(completionHandler: { (res) in
                            self.clearAllNotice()
                            let data = res.result.value as? Dictionary<String,Any>
                            if(data?["code"] as! Int == 0){
                                if(_public == "1"){
                                    let name = self.getMyselfInstance()!.name
                                    self.share(image: nil, title: "New message", desc: name + " send you an audio message", url: Config.shareUrl(friend: name , key: data?["data"] as! String))
                                }else{
                                    self.successNotice("success!")
                                }

                                
                                self.navigationController?.popViewController(animated: true)
                            }else{
                                UIApplication.shared.endIgnoringInteractionEvents()

                                self.noticeTop(data?["msg"] as! String)
                            }
                        })
                    case .failure( _):
                        self.clearAllNotice()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.errorNotice("error!")
                    }
        })
    }

    @IBAction func sendToWeChat() {
        
    }
    
    func share(image:UIImage?,title:String,desc:String,url:String) {
        WechatManager.sharedInstance.share(WXSceneSession, image: image, title: title, description: desc,url:url)
    }
    
    public func passUser(user: User){
        self.friend = user
        initFriend()
    }
    
    private func initFriend(){
        if(friend == nil){
            friend = Kit.getUserdefault(key: "friend") as! User?
            if(friend == nil){
                friend = Kit.getUserdefault(key: "user") as! User?
                friend?.name = "Myself"
            }
            if (friend == nil) {return}
        }
        File.image(url: friend!.head) { (img) in
            self.friendBtn.setImage(img, for: .normal)
        }
        self.friendNameLabel.text = friend!.name
    }
   

}


extension SendView {
    fileprivate func setupWechatManager() {
        //设置appid
        WechatManager.appid = Config.wechatId
        WechatManager.appSecret = Config.wechatSecret
        //如果不设置 appSecret 则无法获取access_token 无法完成认证
        
        //设置分享Delegation
        WechatManager.sharedInstance.shareDelegate = self
    }
}
extension SendView: WechatManagerShareDelegate {
    //app分享之后 点击分享内容自动回到app时调用 该方法
    public func showMessage(_ message: String) {
        print(message)
    }
}
