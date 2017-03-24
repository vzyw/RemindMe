//
//  ContactsView.swift
//  RemindMe
//
//  Created by vzyw on 2/4/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

protocol ContactsViewDelegate {
    func passUser(user:User)
}



class ContactsView: LoginCheckView,UITableViewDelegate,UITableViewDataSource ,ContactsViewDelegate,UISearchResultsUpdating,UISearchBarDelegate{
    static let contactsCellId = "contactsCell"

    var userData = [User]()
    var delegate:ContactsViewDelegate?
    var refresh:UIRefreshControl = UIRefreshControl()
    var searchController:UISearchController! = UISearchController(searchResultsController: nil)
    @IBOutlet weak var contactsTable: UITableView!
    var searchData:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTable.register( UINib.init(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: ContactsView.contactsCellId)
        self.getData()
        self.delegate = self
        self.contactsTable.addSubview(refresh)
        self.refresh.addTarget(self, action: #selector(ContactsView.refreshHandle), for: UIControlEvents.valueChanged)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.searchBar.placeholder = "Username/Email"
        self.searchController.searchBar.delegate = self
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(ContactsView.dismissMyself))
        tap.cancelsTouchesInView = false
        self.contactsTable.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (self.searchController.isActive) {
            return (searchData.count)
        }
        return userData.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsView.contactsCellId) as! ContactsCell
        if(self.searchController.isActive) {
            cell.setData(user: (searchData[indexPath.row]))
        }else{
            cell.setData(user: userData[indexPath.row])
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ContactsCell
        if(self.searchController.isActive) {
            let alert = UIAlertController(title:"Send friend request" , message: "to " + cell.user!.name, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "Send", style: .destructive, handler: { (_) in
                self.sendRequest(id: (cell.user?.id)!)
                self.searchBarCancelButtonClicked(self.searchController.searchBar)
            })
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        dismissMyself()
        
        delegate?.passUser(user: cell.user!)
    }
    
    //如果是处于model状态 则关闭自己
    public func dismissMyself(){
        if((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: {
                self.delegate = self
            })
        }
    }

    @IBAction func addFriendBtn(_ sender: Any) {
        self.contactsTable.tableHeaderView = self.searchController.searchBar
        searchController.isActive = true
        self.contactsTable.reloadData()
    }
    
    
    private func sendRequest(id:String){
        self.pleaseWait()
        Request().get(url: Config.addFriendUrl, pram: ["friend_id":id]) { (msg, _) in
            self.clearAllNotice()
            self.noticeTop(msg)
        }
    }
    
    //search bar delegate
    func updateSearchResults(for searchController: UISearchController){
        searchData = []
        let searchString = self.searchController.searchBar.text?.lowercased()
        if(searchString == "") {return}
        self.pleaseWait()
        Request().get(url: Config.searchUrl, pram: ["email":searchString!]) { (msg, arr) in
            self.clearAllNotice()
            if(arr == nil || arr?.count == 0){
                self.infoNotice(msg)
                self.contactsTable.reloadData()
            }else{
                self.searchData.append( User(arr![0]) )
                self.contactsTable.reloadData()
            }
        }
    }
    
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.contactsTable.tableHeaderView = nil
        self.searchController.isActive = false
        self.contactsTable.reloadData()
    }
    

    private func getData(){
        self.pleaseWait()
        Friend().friends { (users, flag) in
            self.clearAllNotice()
            if(flag){
                self.userData = users!
                self.contactsTable.reloadData()
            }else{
                self.errorNotice("error!")
            }
        }
    }
    
    func passUser(user:User){
        Kit.setUserdefault(key: "friend", value: user)
        let view = Kit.viewById(id: "recordingNavView")
        self.present(view, animated: true)
    }
    
    public func refreshHandle(sender:UIRefreshControl){
        getData()
        sender.endRefreshing()
    }
}
