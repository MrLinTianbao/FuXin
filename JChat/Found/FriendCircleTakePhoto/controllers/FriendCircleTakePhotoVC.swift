//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.


import UIKit
import AVKit
class FriendCircleTakePhotoVC: CTViewController {
//    let kMAX_RECORD_TIME:Float = 15
//    let kMIN_RECORD_TIME:Float = 2
//
//    //拍照图片回调
//    var confirmPhotoBlock:((_ image:UIImage) -> Void)?
//    //拍视频回调
//    var confirmVideoBlock:((_ result: TXUGCRecordResult?) -> Void)?
//
//    //是否是视频模式
//    var _videoFlag:Bool = false
//    //是否在预览
//    var _cameraPreviewing:Bool = false
//    //视频录制参数
//    var _videoConfig:VideoRecordConfig?
//    //预览图比例
//    var _aspectRatio:TXVideoAspectRatio = .VIDEO_ASPECT_RATIO_3_4
//    //是否app前台
//    var _appForeground:Bool = true
//    //是否暂停
//    var _isPaused:Bool = false
//    //是否在录制中
//    var _videoRecording:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUIAppearance()
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
//    init(configure:VideoRecordConfig) {
//        super.init(nibName: nil, bundle: nil)
//        _videoConfig = configure
    
//        NotificationCenter.default.addObserver(self, selector: #selector(onAppDidEnterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(onAppWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(onAppDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(onAppWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
//    }
    
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    func setUIAppearance(){
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor.init(hexString: "#36373B")
        self.view.addSubview(videoRecordView)
        self.view.addSubview(imvCover)
//        self.view.addSubview(videoPreview)
        self.view.addSubview(viewBottom)
        self.view.addSubview(labTime)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        videoPreview._voidPlayer?.stopPlay()
    }
    //MARK: **************************** 注销通知
    deinit {
//        videoPreview._voidPlayer?.removeVideoWidget()
//        videoPreview._voidPlayer?.stopPlay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if !_cameraPreviewing {
//            self.startCameraPreview()
//        }
    }
    //MARK: **************************** 开始预览
//    func startCameraPreview(){
//
//        if !_cameraPreviewing {
//
//            // 1. 自定义设置配置录制参数
//            let param = TXUGCCustomConfig.init()
//            // 录制视频质量(分辨率 720P) 分辨率
//            param.videoResolution =  _videoConfig!.videoResolution
//            //是否前置摄像头，使用 switchCamera 可以切换
//            param.frontCamera = false
//            //帧率
//            param.videoFPS = _videoConfig!.fps
//            //码率
//            param.videoBitratePIN = _videoConfig!.bps
//            //关键帧间隔
//            param.gop = _videoConfig!.gop;
//            //是否开启回声消除
//            param.enableAEC = _videoConfig!.enableAEC;
//            //视频录制的最小时长
//            param.minDuration = kMIN_RECORD_TIME
//            //视频录制的最大时长
//            param.maxDuration = kMAX_RECORD_TIME
//            // 开启B帧，相同码率下能获得更好的画面质量
//            param.enableBFrame = true
//
//            //设置录制回调, 回调方法见TXUGCRecordListener
//            TXUGCRecord.shareInstance()?.recordDelegate = self
//            // 2. 启动预览, 设置参数与在哪个View上进行预览
//            TXUGCRecord.shareInstance()?.startCameraCustom(param, preview: videoRecordView)
//            //设置预览图比例
//            TXUGCRecord.shareInstance()?.setAspectRatio(_aspectRatio)
//            _cameraPreviewing = true
//        }
//    }
    
    //MARK: ******************************************************** 懒加载
    lazy var labTime: MZTimerLabel = {
        
        let label = MZTimerLabel ()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "00:00"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.isHidden = true
        let y = videoRecordView.y - 20 - 23
        label.frame = CGRect.init(x: 0, y: y, width: ScreenW, height: 20)
        label.timeFormat = "mm:ss";
        return label
    }()

    // 创建一个视图用于显示相机预览图片
    lazy var videoRecordView: UIView = {
        var height = self.view.frame.size.height
        height = self.view.width * 4 / 3
        
        let y = self.view.frame.size.height - 150 - height
        let view = UIView.init()
        view.frame = CGRect.init(x: 0, y: (self.view.frame.size.height - height)/2.0, width: self.view.width, height: height)
        view.backgroundColor = UIColor.init(hexString: "#36373B")

        return view
    }()
    //封面图片
    lazy var imvCover: UIImageView = {
        
        let imgView = UIImageView ()
        imgView.backgroundColor = UIColor.clear
        imgView.isHidden = true
        imgView.frame = videoRecordView.frame

        return imgView
    }()
    //底部工具View
    lazy var viewBottom: RecorderTakeToolView = {
        let viewbottom = Bundle.main.loadNibNamed("RecorderTakeToolView", owner: self, options: nil)?.last as! RecorderTakeToolView
        viewbottom.delegate = self
        viewbottom.frame = CGRect.init(x: 0, y: ScreenH - 140, width: ScreenW, height: 140)
        return viewbottom
    }()
    //播放视图
//    lazy var videoPreview: RecorderVideoPreview = {
//
//        let view = RecorderVideoPreview()
//        view.isHidden = true
//        view.frame = videoRecordView.frame
////        view.delegate = self
//
//        return view
//    }()
    
//
//    //MARK: ********************************************************  通知
//    //MARK: **************************** 程序进入前台
//    @objc func onAppWillResignActive() {
//        _appForeground = false
//        //当开始录制，而且没点击暂停
//        if !_isPaused && _videoRecording {
//            //执行暂停动作
//            self.onBtnRecordStartClicked()
//        }
//    }
//    //MARK: **************************** 程序进入后台
//    @objc func onAppDidEnterBackGround() {
//        _appForeground = false
//
//        if _videoFlag {
//            //当开始录制，而且没点击暂停
//            if !_isPaused && _videoRecording {
//                //执行暂停动作
//                self.onBtnRecordStartClicked()
//            }
//        }
//
//    }
//    //MARK: **************************** 程序挂起之后重新回来（监听是否重新进入程序程序.）
//    @objc func onAppDidBecomeActive() {
//        _appForeground = true
//    }
//    //MARK: **************************** 程序进入前台
//    @objc func onAppWillEnterForeground() {
//        _appForeground = true
//    }
//
//
//    //MARK: **************************** 开始录制
//    func startVideoRecord(){
//
//
//        let result = TXUGCRecord.shareInstance()?.start()
//        if result != 0 {
//
//            if result == -3 {
//                MJManager.showAlert(title: "启动录制失败", message: "请检查摄像头权限是否打开") {}
//            }
//            else if result == -4 {
//                MJManager.showAlert(title: "启动录制失败", message: "请检查麦克风权限是否打开") {}
//            }
//            else if result == -5 {
//                MJManager.showAlert(title: "启动录制失败", message: "licence 验证失败") {}
//            }
//
//        }else{
//            //录制开始
//            _videoRecording = true
//            //UI 操作
//            print("***************** 启动成功")
//            viewBottom.btnStartRecord.setImage(UIImage.init(named: "停止录制按钮"), for: .normal)
//            labTime.start() //开始计时
//
//        }
//    }
//    //MARK: **************************** 重设置UI
//    func resetVideoUI(){
//        _videoRecording = false
//        viewBottom.viewDoneBg.isHidden = false
//        labTime.pause() //时间停止
//    }
//    //MARK: **************************** 结束录制
//    func stopVideoRecord() {
//
//        TXUGCRecord.shareInstance()?.stop()
//        self.resetVideoUI()
//
//    }
//    //MARK: **************************** 关闭预览
//    func stopCameraPreview(){
//        //页面dissmiss之后需要关闭摄像头，倘若不关闭摄像头，下次进来会打不开。
//        if _cameraPreviewing {
//            TXUGCRecord.shareInstance()?.stopCameraPreview()
//            _cameraPreviewing = false
//        }
//    }
}
////MARK: ********************************************************  视频录制代理
//extension FriendCircleTakePhotoVC: TXUGCRecordListener  {
//
//    /**
//     * 短视频录制完成
//     * @param result 返回码及错误原因
//     * @see TXUGCRecordResult
//     */
//    func onRecordComplete(_ result: TXUGCRecordResult!) {
//
//        if _appForeground
//        {
//            if result.retCode == .UGC_RECORD_RESULT_OK {
//                // 录制成功， 视频文件在result.videoPath中
//                print("========url=========   \(result.videoPath ?? "")")
//                self.stopCameraPreview()
//                self.videoPreview.setPreVideo(result: result)
//
//            }
//            else if result.retCode == .UGC_RECORD_RESULT_OK_INTERRUPT{
//                AlertClass.showToat(withStatus: "录制被打断")
//            }
//            else if result.retCode == .UGC_RECORD_RESULT_OK_UNREACH_MINDURATION{
//                AlertClass.showToat(withStatus: "至少要录够2秒")
//            }
//            else if result.retCode == .UGC_RECORD_RESULT_FAILED{
//                AlertClass.showToat(withStatus: "视频录制失败")
//            }
//            else if result.retCode == .UGC_RECORD_RESULT_OK_BEYOND_MAXDURATION{
//                self.stopCameraPreview()
//                self.stopVideoRecord()
//                self.videoPreview.setPreVideo(result: result)
//
//            }
//        }
//
//        //删除所有片段
//        TXUGCRecord.shareInstance()?.partsManager.deleteAllParts()
////        self.refreshRecordTime(second: 0)
//
//    }
//    /**
//     * 短视频录制进度
//     * @param milliSecond 以毫秒为单位的播放的时间
//     */
//    func onRecordProgress(_ milliSecond: Int) {
//
//
//    }
//
//
//}

////MARK: ********************************************************  底部工具代理
extension FriendCircleTakePhotoVC:RecorderTakeToolViewDelegate{
    func onTakePhotoBtnClicked() {
        
    }
    
    func onDoneBtnClicked() {
        
    }
    
    func onReturnBtnClicked() {
        
    }
    
    func onRecordTypeBtnClicked() {
        
    }
    
    func onBtnRecordStartClicked() {
        
    }
    


    //MARK: **************************** dismiss
    func onBackBtnClicked() {

//        self.stopCameraPreview()
//        self.stopVideoRecord()
//        TXUGCRecord.shareInstance()?.recordDelegate = nil
//        TXUGCRecord.shareInstance()?.videoProcessDelegate = nil
//        TXUGCRecord.shareInstance()?.partsManager.deleteAllParts()

        self.dismiss(animated: true, completion: nil)

    }
//    //MARK: **************************** 拍照
//    func onTakePhotoBtnClicked() {
//        TXUGCRecord.shareInstance()?.snapshot({ (image) in
//            // image为截图结果
//            // 返回主线程处理一些事件，更新UI等等
//            DispatchQueue.main.async {
//                self.imvCover.image = image
//                self.imvCover.isHidden = false
//                self.stopCameraPreview()
//            }
//
//            print("***************** 截图成功")
//        })
//
//
//    }
//    //MARK: **************************** 完成
//    func onDoneBtnClicked(){
//        TXUGCRecord.shareInstance()?.recordDelegate = nil
//        TXUGCRecord.shareInstance()?.videoProcessDelegate = nil
//        TXUGCRecord.shareInstance()?.partsManager.deleteAllParts()
//
//        //视频模式
//        if _videoFlag {
//            self.dismiss(animated: true) {
//                if self.confirmVideoBlock != nil{
//                    self.confirmVideoBlock!(self.videoPreview.result)
//                }
//            }
//        }else{
//            self.dismiss(animated: true) {
//                if self.confirmPhotoBlock != nil{
//                    self.confirmPhotoBlock!(self.imvCover.image!)
//                }
//            }
//        }
//    }
//    //MARK: **************************** 上一步
//    func onReturnBtnClicked(){
//        _videoRecording = false
//
//        //
//        if _videoFlag {
//            videoPreview._voidPlayer?.stopPlay()
//            self.videoPreview.isHidden = true
//            viewBottom.btnStartRecord.setImage(UIImage.init(named: "开始录制按钮"), for: .normal)
//            labTime.reset()
//            labTime.isHidden = false
//        }else{
//            self.imvCover.isHidden = true
//        }
//
//        _cameraPreviewing = false
//        self.startCameraPreview() //开始预览
//    }
//    //MARK: **************************** 切换拍照模式
//    func onRecordTypeBtnClicked(){
//        //跟换模式
//        _videoFlag = !_videoFlag
//
//        //隐藏时间
//        labTime.isHidden = !_videoFlag
//
//        viewBottom.viewDoneBg.isHidden = true
//
//
//
//        if(_videoFlag){
//            imvCover.isHidden = true
//            viewBottom.btnStartRecord.setImage(UIImage.init(named: "开始录制按钮"), for: .normal)
//        }else{
//            videoPreview._voidPlayer?.stopPlay()
//            videoPreview.isHidden = true
//
//            //在录制过程中
//            if _videoRecording {
//                labTime.reset()
//                //停止录制
//
//            }
//        }
//
//       //开始预览
//        self.startCameraPreview()
//
//    }
//
//    //MARK: **************************** 开始录制
//    func onBtnRecordStartClicked(){
//
//        if !_videoRecording
//        {
//            self.startVideoRecord()
//        }
//        else
//        {
//            //执行完成录制操作
//            if !_videoRecording {
//                return
//                //好像不走
//            }
//
//            self.stopVideoRecord()
//        }
//    }
//
//
}
////MARK: ********************************************************  视频录制代理
//extension FriendCircleTakePhotoVC: RecorderVideoPreviewDelegate  {
//    //点击开始播放
//    func onBtnPreviewStartClicked() {
//        labTime.isHidden = true
//    }
//}
