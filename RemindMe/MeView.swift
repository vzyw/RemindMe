//
//  MeView.swift
//  RemindMe
//
//  Created by vzyw on 2/5/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit
import Alamofire

class MeView: LoginCheckView ,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var tableData = [["New Friends"],["Clear Cache"]]
    var users:[User] = []
    
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var loginOutBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeadImage(url: self.getMyselfInstance()?.head)
        nameLabel.text = self.getMyselfInstance()?.name
        setWechatHead()
    }
    
    override func viewDidLayoutSubviews() {
        Kit.setRadius(loginOutBtn, 5)
        Kit.setRadius(headBtn,headBtn.frame.size.height/2)

    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
   
    
    @IBAction func loginoutBtn(_ sender: Any) {
        Login.loginout()
        Kit.setUserdefault(key: "user", value: nil)
        super.viewWillAppear(true)
    }
    
    func setWechatHead(){
        let head = Kit.getUserdefault(key: "wechatHead") as? String
        if(self.getMyselfInstance()?.head == "" && head != nil){
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            Alamofire.download(head!, to: destination).response { response in
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    let image = UIImage(contentsOfFile: imagePath)
                    self.uploadHead(image: image!)
                }
            }
        }
    }
    
    func setHeadImage(url:String?){
        if(url == nil){
            return
        }
        File.image(url: url!, callback: { (img) in
            self.headBtn.setBackgroundImage(img, for: .normal)
        })
    }
    
    // 用户选取图片之后
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 参数 UIImagePickerControllerOriginalImage 代表选取原图片，这里使用 UIImagePickerControllerEditedImage 代表选取的是经过用户拉伸后的图片。
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            uploadHead(image: pickedImage)
        }
        // 必须写这行，否则拍照后点击重新拍摄或使用时没有返回效果。
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadHead(image:UIImage) {
        let data = UIImageJPEGRepresentation(image, 0.1)
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(data!, withName: "file", fileName: "head.png", mimeType: "image/png")
            
        } , to: Config.headUrl, method: .post, headers: nil,
            encodingCompletion: { encodingResult in
                self.clearAllNotice()
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (res) in
                        let data = res.result.value as? Dictionary<String,Any>
                        if (data?["code"] as! Int == 0){
                            self.successNotice("success!")
                            let url = (data!["data"] as! String)
                            self.setHeadImage(url: url)
                            return
                        }
                    })
                case .failure( _):
                    self.errorNotice("fail!")
                }
        })

    }

    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let id = "meCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id)
        cell?.textLabel?.text = tableData[indexPath.section][indexPath.row]
        cell?.detailTextLabel?.text = " "
        switch indexPath.section {
        //section 0
        case 0:
            switch indexPath.row {
            case 0:
                Request().get(url: Config.newFriendUrl, pram: nil, callback: { (msg, arr) in
                    self.users = []
                    if(arr != nil){
                        for dir in arr!{
                            self.users.append(User(dir))
                        }
                    }
                    cell?.detailTextLabel?.text = String(self.users.count)
                })
            default:break
            }
        //section 1
        case 1:break
        default:break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let view = Kit.viewById(id: "newFriendsView") as! NewFriendTableView
                view.users = self.users
                self.navigationController?.pushViewController(view, animated: true)
            default:break
            }
        case 1:
            switch indexPath.row {
            case 0:
                self.pleaseWait()
                let M = String(format: "%.2f",Kit.fileSizeOfCache())
                self.clearAllNotice()
                
                let alert = UIAlertController(title:"clear cache" , message: M + "MB", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
                let okAction = UIAlertAction(title: "Delete", style: .default, handler: { (_) in
                    self.pleaseWait()
                    Kit.clearCache(cachePath: Kit.documentPath())
                    self.clearAllNotice()
                })
                
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            default:break
            }
        default:break
        }
        
    }
    
    @IBAction func headBtn(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Upload Image", message: nil, preferredStyle: .actionSheet)
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let takePhotos = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            }
            else{
                self.errorNotice("error!")
                print("模拟其中无法打开照相机,请在真机中使用");
            }
        })
        
        let selectPhotos = UIAlertAction(title: "Select from Camera Roll", style: .default, handler: {
            (action:UIAlertAction)
            -> Void in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
            
        })
        actionSheet.addAction(cancelBtn)
        actionSheet.addAction(takePhotos)
        actionSheet.addAction(selectPhotos)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let type: String = (info[UIImagePickerControllerMediaType] as! String)
        
        //当选择的类型是图片
        if type != "public.image" {
            return
        }

        let data = UIImageJPEGRepresentation((info[UIImagePickerControllerOriginalImage]) as! UIImage, 0.5)

        Alamofire.upload(data!, to: Config.headUrl).responseJSON { response in
            //debugPrint(response)
        }
    }
    
}
