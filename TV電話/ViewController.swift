//
//  ViewController.swift
//  TV電話
//
//  Created by HARADA REO on 2015/07/27.
//  Copyright (c) 2015年 reo harada. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var peer: SKWPeer!
    var anyPeers: Array<Any>!
    var mediaStreamLocal: SKWMediaStream!
    var mediaStreamRemote: SKWMediaStream!
    var nickName: String!
    var mediaConnection: SKWMediaConnection!
    var refreshControll: UIRefreshControl!
    
    @IBOutlet weak var localVideoView: SKWVideo!
    @IBOutlet weak var peerTableView: UITableView!
    @IBOutlet weak var remoteVideoView: SKWVideo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initiSet()
        
    }
    
    func initiSet() {
        self.anyPeers = []
        
        // Peerに接続
        var options = SKWPeerOption()
        options.key = "94b47636-041c-4120-8c2b-cf6c325b104a"
        options.domain = "reoharada"
        self.peer = SKWPeer(id: self.nickName, options: options)
        
        // 接続してるpeerリストを取得
        self.peer.listAllPeers { (peer) -> Void in
            if(peer != nil){
                let hoge = peer as! Array<String>
                for val:String in hoge {
                    let peerId = val
                    if(peerId != self.nickName){
                        self.anyPeers.append(peerId)
                    }
                }
                
                let delay = 0.5 * Double(NSEC_PER_SEC)
                let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                    println(self.anyPeers)
                    self.peerTableView.reloadData()
                })
            }
        }
        
        self.peerTableView.delegate = self
        self.peerTableView.dataSource = self
        
        self.refreshControll = UIRefreshControl()
        self.refreshControll.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.peerTableView.addSubview(self.refreshControll)
        
        // 自分のカメラをセット
        SKWNavigator.initialize(self.peer)
        
        var constraints = SKWMediaConstraints()
        constraints.maxHeight = 960
        constraints.maxWidth = 540
        //	constraints.cameraPosition = SKW_CAMERA_POSITION_BACK;
        constraints.cameraPosition = SKWCameraPositionEnum._CAMERA_POSITION_FRONT
        
        self.mediaStreamLocal = SKWNavigator.getUserMedia(constraints)
        println(self.localVideoView.frame)
        self.localVideoView.layoutIfNeeded()
        let vwLocal = SKWVideo(frame: self.localVideoView.frame)
        self.view.addSubview(vwLocal)
        vwLocal.addSrc(self.mediaStreamLocal, track: 0)
        self.localVideoView = vwLocal
        
        // 相手のカメラをセット
        self.remoteVideoView.layoutIfNeeded()
        let vwRemote = SKWVideo(frame: self.remoteVideoView.frame)
        self.view.addSubview(vwRemote)
        self.remoteVideoView = vwRemote
        
        // 受信コールバックの指定
        self.setCallBack()
    }
    
    override func viewDidAppear(animated: Bool) {
                println(self.localVideoView.frame)
    }

    override func viewDidLayoutSubviews() {
        println(self.localVideoView.frame)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.anyPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.anyPeers[indexPath.row] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = self.peerTableView.cellForRowAtIndexPath(indexPath)!
        println((cell.textLabel?.text)!)
        let connectPeerId = (cell.textLabel?.text)!
        let connection = self.peer.callWithId(connectPeerId, stream: self.mediaStreamLocal)
        self.setMediaCallBack(connection)
    }
    
    func setMediaCallBack(connection: SKWMediaConnection!) {
        connection.on(SKWMediaConnectionEventEnum._MEDIACONNECTION_EVENT_STREAM, callback: { (obj) -> Void in
            if (obj is SKWMediaStream){
                let stream = obj as? SKWMediaStream
                self.setRemoteView(stream)
            }
        })
        
        connection.on(SKWMediaConnectionEventEnum._MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
            self.closeMedia()
        })
    }
    
    func setRemoteView(stream: SKWMediaStream!) {
        self.mediaStreamRemote = stream;
        

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.remoteVideoView .addSrc(stream, track: 0)
        })
    }
    
    func setCallBack() {
        self.peer .on(SKWPeerEventEnum._PEER_EVENT_OPEN, callback: { (obj) -> Void in
            if(obj is NSString){
                self.nickName = obj as! String
                println(self.nickName)
            }
        })
        
        self.peer .on(SKWPeerEventEnum._PEER_EVENT_CALL, callback: { (obj) -> Void in
            if(obj is SKWMediaConnection) {
                self.mediaConnection = obj as? SKWMediaConnection
                self.setMediaCallBack(self.mediaConnection)
                self.mediaConnection.answer(self.mediaStreamLocal)
            }
        })
    }
    
    func refresh(){
        self.anyPeers = []
        // 接続してるpeerリストを取得
        self.peer.listAllPeers { (peer) -> Void in
            if(peer != nil){
                let hoge = peer as! Array<String>
                for val:String in hoge {
                    let peerId = val
                    if(peerId != self.nickName){
                        self.anyPeers.append(peerId)
                    }
                }
                
                let delay = 0.5 * Double(NSEC_PER_SEC)
                let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                    println(self.anyPeers)
                    self.peerTableView.reloadData()
                })
            }
        }

        self.peerTableView.reloadData()
        self.refreshControll.endRefreshing()
    }
    
    
    @IBAction func endSession(sender: AnyObject) {
        self.remoteVideoView.removeSrc(self.mediaStreamRemote, track: 0)
        self.mediaStreamRemote.close()
        self.mediaConnection.close()
    }
    
    func closeMedia() {
        self.remoteVideoView.removeSrc(self.mediaStreamRemote, track: 0)
        self.mediaStreamRemote.close()
        self.clearMediaCallbacks()
    }

    func clearMediaCallbacks() {
        self.mediaConnection.on(SKWMediaConnectionEventEnum._MEDIACONNECTION_EVENT_STREAM, callback:nil)
        self.mediaConnection.on(SKWMediaConnectionEventEnum._MEDIACONNECTION_EVENT_CLOSE, callback:nil)
        self.mediaConnection.on(SKWMediaConnectionEventEnum._MEDIACONNECTION_EVENT_ERROR, callback:nil)
    }
    
}

