//
//  PlayButton.swift
//  RemindMe
//
//  Created by vzyw on 2/8/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit

class PlayButton: UIButton,PlayerDelegate {

    static let player = Player()
    static var last:PlayButton? = nil
    
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.setImage(#imageLiteral(resourceName: "start"), for: .normal)
        self.setImage(#imageLiteral(resourceName: "stop"), for: .selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func play(path:String){
        PlayButton.player.delegate = self
        PlayButton.player.path = path
        PlayButton.last?.isSelected = false
        self.isSelected = true
        PlayButton.player.play()
        PlayButton.last = self
    }
    func stop(){
        PlayButton.player.pause()
        self.playingDone()
    }
    
    func playingDone(){
        self.isSelected = false
    }
    func error(msg:String){
        self.isSelected = false
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
