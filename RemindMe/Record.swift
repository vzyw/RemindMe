//
//  Record.swift
//  RemindMe
//
//  Created by vzyw on 2/3/17.
//  Copyright © 2017 vzyw. All rights reserved.
//

import UIKit
import AVFoundation


@objc protocol RecorderDelegate {
    @objc optional func update(time:Int);
    @objc optional func recodingDone();
    @objc optional func error(msg:String);
}


@objc protocol PlayerDelegate {
    @objc optional func update(time:Int);
    @objc optional func playingDone();
    @objc optional func error(msg:String);
}





class Recorder: NSObject{
    
    var recorder:AVAudioRecorder? //录音器
    var delegate:RecorderDelegate?
    var duration:Int! = 0;
    var stopTimer:Timer!
    
    static let tempPath =  Kit.documentPath() + "/__temp__.aac";
    private static var instance:Recorder = Recorder()
    //初始化字典并添加设置参数
    private static let recorderSeetingsDic: [String : Any] = [
        AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
        AVNumberOfChannelsKey: 2, //录音的声道数，立体声为双声道
        AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
        AVEncoderBitRateKey : 128000,//320000,
        AVSampleRateKey : 44100.0 //录音器每秒采集的录音样本数
    ]
    
    static let session:AVAudioSession = AVAudioSession.sharedInstance()

    public static func shareInstance() -> Recorder{
        return instance
    }
    
    private override init() {
        super.init()
        try! Recorder.session.setCategory(AVAudioSessionCategoryPlayAndRecord ,with: AVAudioSessionCategoryOptions.defaultToSpeaker )

    }
    
    func start() {
        if(duration <= 0){ return }
        //初始化录音器
        recorder = try? AVAudioRecorder(url: URL(string: Recorder.tempPath)!,
                                        settings: Recorder.recorderSeetingsDic)
        if recorder != nil {
            //开启仪表计数功能
            recorder!.isMeteringEnabled = true
            //准备录音
            recorder!.prepareToRecord()
            //开始录音
            recorder!.record()
            //启动定时器，定时更新录音音量
            stopTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Recorder.update), userInfo: nil, repeats: true)
        }else{
            delegate?.error?(msg: "can not record!");
        }
    }
    
    
    
    
    func stop() {
        self.delegate?.recodingDone?()
        //停止录音
        recorder?.stop()
        //录音器释放
        recorder = nil
        //暂停定时器
        stopTimer?.invalidate()
        stopTimer = nil
    }
    
    func update(){
        duration = duration - 1
        
        self.delegate?.update?(time: duration)
    }
}
    


class Player:NSObject , AVAudioPlayerDelegate{
    var path:String?
    var player:AVAudioPlayer? //播放器
    var delegate:PlayerDelegate?
    static let session:AVAudioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        //设置录音类型
        try! Player.session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        //设置支持后台
        try! Player.session.setActive(true)
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        self.delegate?.playingDone?()
    }
    
    func pause(){
        player?.pause()
    }
    
    
    func recodingDuration()->TimeInterval{
        player = try? AVAudioPlayer(contentsOf:URL(string:path!)!)
        if(player == nil){
            return 0.0
        }
        return player!.duration
    }
    
    func play(){
        if(path == nil){
            self.delegate?.error?(msg: "can not play!")
            return
        }
        player = try? AVAudioPlayer(contentsOf:URL(string:path!)!)
        player?.delegate = self
        if player == nil{
            self.delegate?.error?(msg: "can not play!")
        }else{
            player!.play()
        }
    }
    
    
    
}

