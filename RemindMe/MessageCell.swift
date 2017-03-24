//
//  MessageCell.swift
//  RemindMe
//
//  Created by vzyw on 2/4/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    static var user:User?
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playBtn: PlayButton!
    @IBOutlet weak var toOrFromLabel: UILabel!
    var play:PlayButton!
    var data:Dictionary<String,Any>?
    var url = ""
    var id = ""
    var date = Date()
    override func awakeFromNib() {
        super.awakeFromNib()
        play = PlayButton(frame: CGRect(x: Kit.deviceWidth()-65, y: 28, width: 40, height: 40))
        self.contentView.insertSubview(play, at: 1)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func initData(data:Dictionary<String,Any>,index:Int){
        playBtn.isSelected = false
        self.data = data
        
        
        date = Kit.stringToDate(date: data["play_time"] as! String, formart: "yyyy-MM-dd HH:mm:ss")
 
        toOrFromLabel.text =  isMyself() ? "To:" : "From:"
        dayLabel.text = Kit.dateToString(date: date, format: "dd")
        monLabel.text = Kit.dateToString(date: date, format: "MMM")
        timeLabel.text = Kit.dateToString(date: date, format: "HH:mm")
        fromLabel.text = data["name"] as? String
        url = data["video_url"] as! String
        id = data["id"] as! String
        setBgColor(index: index)
        
        if(istoMyself()){
            fromLabel.text = "Myself"
            self.contentView.backgroundColor = UIColor(red:0.26, green:0.57, blue:0.32, alpha:1)
        }
    }
    
    private func setBgColor(index:Int){
        switch index % 3 {
        case 0:
            self.contentView.backgroundColor = UIColor(red:0.98, green:0.8, blue:0.2, alpha:1)
        case 1:
            self.contentView.backgroundColor = UIColor(red:0.33, green:0.78, blue:0.98, alpha:1)
        case 2:
            self.contentView.backgroundColor = UIColor(red:0.93, green:0.31, blue:0.44, alpha:1)
        default:
            break
        }
    }
    
    
    private func isMyself()->Bool{
        if(MessageCell.user?.id == data?["user_id"] as? String){
            return true
        }
        return false
    }
    private func istoMyself()->Bool{
        if(data?["friend_id"] as? String == data?["user_id"] as? String){
            return true
        }
        return false
    }
    
    private func canPlay() -> Bool{
        let time = date.timeIntervalSinceNow
        if ( time < 0 ) {return true}
        return false
    }
    @IBAction func play(_ sender: UIButton) {
        if(!canPlay() && !isMyself()){
            let alert = UIAlertController(title:"It's not time to play until" , message: self.data?["play_time"] as? String, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Confirm", style: .cancel, handler:nil)
            alert.addAction(cancelAction)
            let view = Kit.getCurrentVC()
            return view.present(alert, animated: true, completion: nil)
        }
        if (sender.isSelected){
            play.stop()
            return sender.isSelected = false
        }
        let url  = IP_D + self.url
        let path = Kit.fileExist(fileName: Kit.getName(url: url))
    
        sender.isSelected = true
        if  path != nil{
            play.play(path: path!)
        }else{
            self.pleaseWait()
            Kit.downloadFile(url: url, callback: { path in
                if(path != nil){
                    self.clearAllNotice()
                    self.play.play(path: path!)
                }
            })
        }
    }
    

    
}
