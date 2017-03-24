//
//  NewFriendTableView.swift
//  RemindMe
//
//  Created by vzyw on 2/9/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

class NewFriendTableView: UITableViewController {

    var users:[User] = []
    let identifier = "newFriendCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register( UINib.init(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: identifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ContactsCell
        
        cell.setData(user: users[indexPath.row])

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = (tableView.cellForRow(at: indexPath) as! ContactsCell).user
        let alert = UIAlertController(title:"From " + user!.name , message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ignore", style: .cancel, handler: { _ in
            Request().get(url: Config.decideUrl, pram: ["id":(user?.id)!,"allow":"0"], callback: { (_, _) in
                self.successNotice("ok!")
            })
        })
        let okAction = UIAlertAction(title: "Accept", style: .default, handler: { (_) in
            Request().get(url: Config.decideUrl, pram: ["id":(user?.id)!,"allow":"1"], callback: { (_, _) in
                self.successNotice("ok!")
            })
        })
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
   

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
