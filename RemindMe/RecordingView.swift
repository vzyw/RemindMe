//
//  RecordingView.swift
//  RemindMe
//
//  Created by vzyw on 2/4/17.
//  Copyright © 2017 vzyw. All rights reserved.
//
import UIKit

enum Statuses {
    case notRecording
    case recording
    case recordingDone
    case playing
    case pauseing
}

class RecordingView: LoginCheckView,RecorderDelegate,PlayerDelegate{
    
    let duration = 60
    var status:Statuses = Statuses.notRecording
    var recorder = Recorder.shareInstance()
    var player = Player()
    
    
    @IBOutlet weak var ctrlPanel: UIView!
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var mainBtn: UIButton!

    @IBOutlet weak var closeBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bar = navigationController?.navigationBar
        bar?.setBackgroundImage(#imageLiteral(resourceName: "bg"), for: .default)
        bar?.shadowImage = UIImage()
        bar?.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        bar?.tintColor = UIColor.white
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        
        player.delegate = self
        player.path = Recorder.tempPath
        setNotRecording()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.endIgnoringInteractionEvents()
        setNotRecording()
        
        if((self.presentingViewController) == nil){
            self.navigationItem.rightBarButtonItem = nil;
        }else{
            self.navigationItem.rightBarButtonItem = closeBtn
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(status == .recording){
            setRecordingDone()
            recorder.stop()
        }
        if(status == .playing){
            setPauseing()
            player.pause()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func back(_ sender: Any) {
        Kit.setUserdefault(key: "friend", value: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //重新录音
    @IBAction func renew(_ sender: Any) {
        setNotRecording()
    }
    
    @IBAction func mainBtn(_ sender: Any) {
        switch status {
        case .notRecording:
            setNotRecording()
            setRecording()
        case .recording:
            setRecordingDone()
        case .recordingDone:
            setPlaying()
        case .pauseing:
            setPlaying()
            player.play()
        case .playing:
            setPauseing()
        }
    }
    
    
    private func displayCtrlpanel(){
        UIView.animate(withDuration: 0.3, animations: {
            self.ctrlPanel.alpha = 1
        })
    }
    private func hiddenCtrlpanel(){
        UIView.animate(withDuration: 0.1, animations: {
            self.ctrlPanel.alpha = 0
        })
    }

    
    @IBAction func sendBtn(_ sender: Any) {
        if(status == .notRecording){
            self.noticeTop("Not recording")
            return
        }
        if(player.recodingDuration() < 1){
            self.noticeTop("Message too short")
            return
        }
        let view = Kit.viewById(id: "sendView") as! SendView
        
        view.url = Recorder.tempPath
        self.navigationController?.pushViewController(view, animated: true)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
    }
    
    private func setNotRecording(){
        mainBtn.setImage(#imageLiteral(resourceName: "recod"), for: .normal)
        status = .notRecording
        recorder.duration = duration
        recorder.delegate = self
        time.text = String(duration)
        hiddenCtrlpanel()
        player.pause()
    }
    private func setRecording(){
        mainBtn.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
        status = .recording
        recorder.start()
    }
    private func setRecordingDone(){
        mainBtn.setImage(#imageLiteral(resourceName: "start"), for: .normal)
        status = .recordingDone
        displayCtrlpanel()
        recorder.stop()
    }
    private func setPauseing(){
        mainBtn.setImage(#imageLiteral(resourceName: "start"), for: .normal)
        status = .pauseing
        player.pause()
    }
    private func setPlaying(){
        mainBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        status = .playing
        player.play()

    }
    
    
    
    func update(time:Int){
        if(time <= 0) {
            setRecordingDone()
        }
        self.time.text = String(time)
    }
    func recodingDone(){
        
    }
    func playingDone(){
        setPauseing()
    }
    func error(msg:String){
        
    }
    

}
