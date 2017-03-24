//
//  MessagesView.swift
//  RemindMe
//
//  Created by vzyw on 2/5/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit


class MessagesView: LoginCheckView ,UITableViewDelegate,UITableViewDataSource{
    static let messageCellId = "messageCell"
    @IBOutlet weak var messagesTable: UITableView!
    var messages = [Dictionary<String,Any>]()
    var refresh:UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesTable.register( UINib.init(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: MessagesView.messageCellId)
        
        self.refresh.addTarget(self, action: #selector(MessagesView.refreshHandle), for: UIControlEvents.valueChanged)
        self.messagesTable.addSubview(refresh)
        MessageCell.user = self.getMyselfInstance()
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //tableview delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: MessagesView.messageCellId) as! MessageCell
        cell.initData(data: messages[indexPath.row],index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MessageCell
        if(editingStyle == UITableViewCellEditingStyle.delete){
            messages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            self.pleaseWait()
            Request().get(url: Config.deleteMessageUrl, pram:["vid":cell.id], callback: { (msg, arr) in
                self.clearAllNotice()
                self.noticeTop(msg);
            })
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MessageCell
        cell.play(cell.playBtn)
    }
    //end

    @IBAction func newMessage(_ sender: Any) {
        let view = Kit.viewById(id: "recordingNavView")
        self.present(view, animated: true, completion: nil)
    }
    
    
    private func getData(){
        self.pleaseWait()
        Message().messages(callback: { (msg , arr) in
            self.clearAllNotice()
            
            if(arr == nil){
                self.infoNotice("no data!")
                self.messages = []
            }else{
                self.messages = arr!
            }
            self.messagesTable.reloadData()
        })
    }
    
    
    
    public func refreshHandle(sender:UIRefreshControl){
        getData()
        sender.endRefreshing()
    }
}
