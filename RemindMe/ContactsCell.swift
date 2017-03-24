//
//  ContactsCell.swift
//  RemindMe
//
//  Created by vzyw on 2/4/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {

    @IBOutlet weak var headImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user:User?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(user:User){
        self.user = user
        self.nameLabel.text = user.name
        File.image(url: user.head, callback: { (img) in
            self.headImg.image = img
        })
    }
    
}
