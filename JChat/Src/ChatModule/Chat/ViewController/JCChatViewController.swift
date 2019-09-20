//
//  JCChatViewController.swift
//  JChat
//
//  Created by JIGUANG on 2017/2/28.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import YHPhotoKit
import MobileCoreServices
import CocoaAsyncSocket

class JCChatViewController: CTViewController {
    
    fileprivate var name = ""
    fileprivate var image : UIImage! //图片数据
    fileprivate var referenceText = "" //引用文本
    fileprivate var showNotice = false //是否有公告
    fileprivate var noticeView : GroupNoticeView!
    
    var chatForCustomService = false //与客服聊天
    
    open var conversation: JMSGConversation
    fileprivate var isGroup = false
    
    //MARK - life cycle
    public required init(conversation: JMSGConversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
        automaticallyAdjustsScrollViewInsets = false;
        if let draft = JCDraft.getDraft(conversation) {
            self.draft = draft
        }
        
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _init()
        
//        AsyncSocket.share.clientSocket.delegate = self
    }
    
    override func loadView() {
        super.loadView()
        let frame = CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height - StatusBarAddNavBarHeight)
        chatView = JCChatView(frame: frame, chatViewLayout: chatViewLayout)
        chatView.delegate = self
        chatView.messageDelegate = self
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.delegate = self
        toolbar.text = draft
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.chatView.frame = CGRect(x: 0, y: showNotice ? 30 : 0, width: self.view.width, height: self.view.height-(showNotice ? 30 : 0))
        toolbar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        if let group = conversation.target as? JMSGGroup {
            group.memberArray {[weak self] (userArr, error) in
                
                if let list = userArr as? [JMSGUser] {
                    self?.title = "\(group.displayName())(\(list.count))"
                }else{
                    self?.title = group.displayName()
                }
            }
            
        }
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        navigationController?.navigationBar.isTranslucent = true
        JCDraft.update(text: toolbar.text, conversation: conversation)
    }
    
    deinit {
        
        
        NotificationCenter.default.removeObserver(self)
        JMessage.remove(self, with: conversation)
    }
    
    private var draft: String?
    fileprivate lazy var toolbar: SAIInputBar = SAIInputBar(type: .default)
    fileprivate lazy var inputViews: [String: UIView] = [:]
    fileprivate weak var inputItem: SAIInputItem?
    var chatViewLayout: JCChatViewLayout = .init()
    var chatView: JCChatView!
    fileprivate lazy var reminds: [JCRemind] = []
    fileprivate lazy var documentInteractionController = UIDocumentInteractionController()

    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = self
        return picker
    }()
    
    fileprivate lazy var videoPicker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.sourceType = .camera
        picker.cameraCaptureMode = .video
        picker.videoMaximumDuration = 10
        picker.delegate = self
        return picker
    }()
    
    fileprivate lazy var _emoticonGroups: [JCCEmoticonGroup] = {
        var groups: [JCCEmoticonGroup] = []
        if let group = JCCEmoticonGroup(identifier: "com.apple.emoji") {
            groups.append(group)
        }
        if let group = JCCEmoticonGroup(identifier: "cn.jchat.guangguang") {
            groups.append(group)
        }
        return groups
    }()
    fileprivate lazy var _emoticonSendBtn: UIButton = {
        var button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 10 + 8, bottom: 0, right: 8)
        button.setTitle("发送", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage.loadImage("chat_emoticon_btn_send_blue"), for: .normal)
        button.setBackgroundImage(UIImage.loadImage("chat_emoticon_btn_send_gray"), for: .disabled)
        button.addTarget(self, action: #selector(_sendHandler), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var emoticonView: JCEmoticonInputView = {
        let emoticonView = JCEmoticonInputView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 275))
        emoticonView.delegate = self
        emoticonView.dataSource = self
        return emoticonView
    }()
    
    fileprivate lazy var toolboxView: SAIToolboxInputView = {
        var toolboxView = SAIToolboxInputView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 197))
        toolboxView.delegate = self
        toolboxView.dataSource = self
        return toolboxView
    }()
    fileprivate lazy var _toolboxItems: [SAIToolboxItem] = {
        
        if isGroup {
            return [
        
                SAIToolboxItem("page:lines", "账单", UIImage.init(named: "Lines")),
                SAIToolboxItem("page:administrator", "联系管理员", UIImage.init(named: "administrator")),
                SAIToolboxItem("page:redPackage", "红包", UIImage.init(named: "redPackage")),
                SAIToolboxItem("page:topUp", "充值", UIImage.init(named: "topUp")),
                SAIToolboxItem("page:reflect", "提现", UIImage.init(named: "reflect")),SAIToolboxItem("page:addressBook", "通讯录", UIImage.init(named: "book_unselect"))
            ]
        }else{
            
//            let customer_type = CacheClass.stringForEnumKey(.customer_type) ?? "2"
            let gid = CacheClass.stringForEnumKey(.groupid) ?? ""
            
            if gid == "5" || chatForCustomService {
                return [
                    SAIToolboxItem("page:pic", "图片", UIImage.init(named: "photo")),
                    SAIToolboxItem("page:camera", "拍摄", UIImage.init(named: "takePhoto")),SAIToolboxItem("page:redPackage", "红包", UIImage.init(named: "redPackage"))]
                
                
//               , SAIToolboxItem("page:transfer", "转账", UIImage.init(named: "transfer"))
            }else{
                return [
                    SAIToolboxItem("page:redPackage", "红包", UIImage.init(named: "redPackage"))]
            }
            
            
            
            
            
        }
        
        
    }()
    
    fileprivate var myAvator: UIImage?
    lazy var messages: [JCMessage] = []
    fileprivate let currentUser = JMSGUser.myInfo()
    fileprivate var messagePage = 0
    fileprivate var currentMessage: JCMessageType!
    fileprivate var maxTime = 0
    fileprivate var minTime = 0
    fileprivate var minIndex = 0
    fileprivate var jMessageCount = 0
    fileprivate var isFristLaunch = true
    fileprivate var recordingHub: JCRecordingView!
    fileprivate lazy var recordHelper: JCRecordVoiceHelper = {
        let recordHelper = JCRecordVoiceHelper()
        recordHelper.delegate = self
        return recordHelper
    }()
    fileprivate lazy var leftButton: UIButton = {
        let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 65 / 3))
        leftButton.setImage(UIImage.init(named: "返回Back"), for: .normal)
        leftButton.setImage(UIImage.init(named: "返回Back"), for: .highlighted)
        leftButton.addTarget(self, action: #selector(_back), for: .touchUpInside)
        leftButton.setTitle("", for: .normal)
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        leftButton.contentHorizontalAlignment = .left
        return leftButton
    }()
    
    private func _init() {
        
    
        
        myAvator = UIImage.getMyAvator()
        isGroup = conversation.ex.isGroup
        _updateTitle()
        view.backgroundColor = .white
        JMessage.add(self, with: conversation)
        _setupNavigation()
        _loadMessage(messagePage)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.chatView.scrollToLast(animated: false)
        }
        
        if isGroup {
            groupAnnouncement()
        }
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(_tapView))
        tap.delegate = self
        chatView.addGestureRecognizer(tap)
        view.addSubview(chatView)
        
        
            
        let gid = CacheClass.stringForEnumKey(.groupid) ?? ""

        
        if !isGroup {
            if let array = CacheClass.arrayForEnumKey(.customServiceList) as? [String] {
                
                let username = (conversation.target as! JMSGUser).username
                
                if array.contains(username) {
                    chatForCustomService = true
                }
            }
        }
            
        
            
            if  gid != "5" && gid != "6" {
                
                if !chatForCustomService {
                    let myView = UILabel()
                    myView.backgroundColor = UIColor.white
                    myView.text = "禁止聊天"
                    myView.textColor = UIColor.KTheme.deepGray
                    myView.textAlignment = .center
                    myView.font = UIFont.systemFont(ofSize: 16)
                    myView.isUserInteractionEnabled = true
                    self.toolbar._inputAccessoryView.addSubview(myView)
                    self.toolbar._inputAccessoryView.textField.isEditable = false
                    
                    myView.snp.makeConstraints { (make) in
                        make.top.left.equalToSuperview()
                        make.right.equalToSuperview().offset(-50)
                        make.height.equalTo(50)
                    }
                }
                
                
            }
        
        if isGroup {
            let myView = UILabel()
            myView.backgroundColor = UIColor.white
            myView.text = "禁止聊天"
            myView.textColor = UIColor.KTheme.deepGray
            myView.textAlignment = .center
            myView.font = UIFont.systemFont(ofSize: 16)
            myView.isUserInteractionEnabled = true
            self.toolbar._inputAccessoryView.addSubview(myView)
            self.toolbar._inputAccessoryView.textField.isEditable = false

            myView.snp.makeConstraints { (make) in
                make.top.left.equalToSuperview()
                make.right.equalToSuperview().offset(-50)
                make.height.equalTo(50)
            }
        }
        
            
            
            
        
        
        
        
        _updateBadge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_removeAllMessage), name: NSNotification.Name(rawValue: kDeleteAllMessage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_reloadMessage), name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_updateFileMessage(_:)), name: NSNotification.Name(rawValue: kUpdateFileMessage), object: nil)
    }
    
    @objc func _updateFileMessage(_ notification: Notification) {
        let userInfo = notification.userInfo
        let msg = userInfo?[kUpdateFileMessage] as! JMSGMessage
        let msgId = msg.msgId
        let message = conversation.message(withMessageId: msgId)!
        let content = message.content as! JMSGFileContent
        let url = URL(fileURLWithPath: content.originMediaLocalPath ?? "")
        let data = try! Data(contentsOf: url)
        updateMediaMessage(message, data: data)
    }
    
    private func _updateTitle() {
        if let group = conversation.target as? JMSGGroup {
            
            group.memberArray {[weak self] (userArr, error) in
            
                if let list = userArr as? [JMSGUser] {
                    self?.title = "\(group.displayName())(\(list.count))"
                }else{
                    self?.title = group.displayName()
                }
            }
            
        } else {
            title = conversation.title
        }
    }


    @objc func _reloadMessage() {
        _removeAllMessage()
        messagePage = 0
        _loadMessage(messagePage)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//            self.chatView.scrollToLast(animated: false)
//        }
    }
    
    @objc func _removeAllMessage() {
        jMessageCount = 0
        messages.removeAll()
        chatView.removeAll()
    }
    
    @objc func _tapView() {
        view.endEditing(true)
        toolbar.resignFirstResponder()
    }
    
    private func _setupNavigation() {
        let navButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        if isGroup {
            navButton.setImage(UIImage.init(named: "moreSet"), for: .normal)
            navButton.addTarget(self, action: #selector(_getGroupInfo), for: .touchUpInside)
        } else {
            navButton.setImage(UIImage.init(named: "moreSet"), for: .normal)
            navButton.addTarget(self, action: #selector(_getSingleInfo), for: .touchUpInside)
        }
        let item1 = UIBarButtonItem(customView: navButton)
        navigationItem.rightBarButtonItems =  [item1]

//        let item2 = UIBarButtonItem(customView: leftButton)
//        navigationItem.leftBarButtonItems =  [item2]
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func _back() {
        navigationController?.popViewController(animated: true)
    }
    func updateMessageState(messages: inout [JMSGMessage],msgId:String){
        for item in messages {
            if item.msgId == msgId {
                if (item.updateExtraValue("1", forKey: "msgStatus")) {
                    print("***************** 更新成功")
                }
            }
        }
    }
    
    //MARK: 获取消息列表
    fileprivate func _loadMessage(_ page: Int) {
        printLog("\(page)")

        var messages = conversation.messageArrayFromNewest(withOffset: NSNumber(value: jMessageCount), limit: NSNumber(value: 100))
        if messages.count == 0 {
            return
        }
        var msgs: [JCMessage] = []
        for index in 0..<messages.count {
            let message = messages[index]

            
            
            
       
                if message.contentType == .text {
                    let content = message.content as! JMSGTextContent
                    let jsonData:Data = content.text.data(using: .utf8)!
                    let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                    if let dict = dic as? [String:Any] {
                        if let type = dict["type"] as? String {
                            if type == "hb" {
                                
                                
                                    if let msgId = dict["msgId"] as? String {
                                        if !isGroup{
                                            self.updateMessageState(messages: &messages, msgId: msgId)
                                        }else{
                                            conversation.deleteMessage(withMessageId: message.msgId)
                                            continue
                                            
                                        }
                                    }
                                        
                                    
                                
                                
                                
                            }else if type == "zz" {
                                if let msgId = dict["msgId"] as? String {
                                    self.updateMessageState(messages: &messages, msgId: msgId)

                                }
                                
                            }
                        }
                    }
                }
            
            
            
            
            //判断是否是群消息提醒
            if message.contentType == .eventNotification {
                
                conversation.deleteMessage(withMessageId: message.msgId)
                
                continue
            }
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            let msg = _parseMessage(message)
        
            
            
            msgs.insert(msg, at: 0)
            if isNeedInsertTimeLine(message.timestamp.intValue) || index == messages.count - 1 {
                let timeContent = JCMessageTimeLineContent(date: Date(timeIntervalSince1970: TimeInterval(message.timestamp.intValue / 1000)))
                let m = JCMessage(content: timeContent)
                m.options.showsTips = false
                msgs.insert(m, at: 0)
            }
        }
        
        
        if page != 0 {
            minIndex = minIndex + msgs.count
            chatView.insert(contentsOf: msgs, at: 0)
        } else {
            minIndex = msgs.count - 1
            chatView.append(contentsOf: msgs)
        }
        self.messages.insert(contentsOf: msgs, at: 0)
        
    }
    
    private func isNeedInsertTimeLine(_ time: Int) -> Bool {
        if maxTime == 0 || minTime == 0 {
            maxTime = time
            minTime = time
            return true
        }
        if (time - maxTime) >= 5 * 60000 {
            maxTime = time
            return true
        }
        if (minTime - time) >= 5 * 60000 {
            minTime = time
            return true
        }
        return false
    }
    
    // MARK: - parse message
    fileprivate func _parseMessage(_ message: JMSGMessage, _ isNewMessage: Bool = true) -> JCMessage {
        if isNewMessage {
            jMessageCount += 1
        }
        
        
        
        
        return message.parseMessage(self, { [weak self] (message, data) in
            self?.updateMediaMessage(message, data: data)
            }, conversation: self.conversation, isGroup: isGroup)
    }

    // MARK: - send message
    func send(_ message: JCMessage, _ jmessage: JMSGMessage) {
        if isNeedInsertTimeLine(jmessage.timestamp.intValue) {
            let timeContent = JCMessageTimeLineContent(date: Date(timeIntervalSince1970: TimeInterval(jmessage.timestamp.intValue / 1000)))
            let m = JCMessage(content: timeContent)
            m.options.showsTips = false
            messages.append(m)
            chatView.append(m)
        }
        message.msgId = jmessage.msgId
        message.name = currentUser.displayName()
        message.senderAvator = myAvator
        message.sender = currentUser
        message.options.alignment = .right
        message.options.state = .sending
        if let group = conversation.target as? JMSGGroup {
            message.targetType = .group
            message.unreadCount = group.memberArray().count - 1
        } else {
            message.targetType = .single
            message.unreadCount = 1
        }
        
        var flag = true
        
        //推送参数
        var option = JMSGOptionalContent.ex.default
        if message.contentType == .text {
            if let content = jmessage.content as? JMSGTextContent {
                let jsonData:Data = content.text.data(using: .utf8)!
                let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                if let dict = dic as? [String:Any] {
                    if let type = dict["type"] as? String {
                        if type == "hb" || type == "zz" || type == "2" || type == "1" {
                            
                            var title = ""
                            
                            if type == "hb" {
                                
                                title = "你收到一条红包消息"
                                
                                if let _ = dict["msgId"] as? String {
                                    title = "红包领取通知"
                                }
                            }
                            
                            
                            
                            if type == "zz" {
                                
                                if let _ = dict["msgId"] as? String {
                                    title = "转账领取通知"
                                }
                                
                                title = "你收到一条转账消息"
                            }
                            
                            if type == "1" {
                                
                                
                                title = "红包领取结果通知"
                            }
                            
                            if type == "2" {
            
                                
                                title = "平台奖励通知"
                            }
                            
                            //推送标题
                            option = JMSGOptionalContent.init()
                            option.needReadReceipt = true;//否需要对方发送已读回执
                            let custion = JMSGCustomNotification.init()
                            custion.enabled = true;//是否启用自定义通知栏
                            custion.title = title;//自定义消息通知栏的标题
                            //custion.alert = "alert";//自定义消息通知栏的内容
                            //custion.atPrefix = "atPrefix";//被@目标的通知内容前缀
                            option.customNotification = custion
    
                            
                            if type == "2" || type == "1" {
                                option.noSaveNotification = true //不显示通知
                            }
                            
                    
                            
                            if type == "hb" {
                                
                                title = "你收到一条红包消息"
                                
                                if let _ = dict["msgId"] as? String {
//                                    title = "红包领取通知"
                                    option.noSaveNotification = true //不显示通知
                                }
                            }
                            
                            
                            flag = false
                        }
                    }
                }
            }
            
        }
        
        if flag {
            chatView.append(message)
            messages.append(message)
        }
        
//        chatView.scrollToLast(animated: false)
        conversation.send(jmessage, optionalContent: option)
        
        
    }

    //MARK: 发送文本消息
    func send(forText text: NSAttributedString,status:String?="0") {
        
//        if text.string.contains(self.name + "\n" + "【图片】") {
//
//            let deleteText = "@" + self.name + "\n" + "【图片】\n"
//
//            referenceText = text.string.replacingOccurrences(of: deleteText, with: "")
//
//            let dic = ["Picture_Reference":["Citer": self.name,"Respondents":referenceText],"message": "###@@@图片回复###@@@","type": "Picture_Reference"] as [String : Any]
//            let data : NSData = try! JSONSerialization.data(withJSONObject: dic, options: []) as NSData
//            let jsonString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//            self.send(forImage: self.image,jsonStr: jsonString)
//
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
//            }
//
//            return
//        }
        
        let message = JCMessage(content: JCMessageTextContent(attributedText: text))
        let content = JMSGTextContent(text: text.string)
        let msg = JMSGMessage.ex.createMessage(conversation, content, reminds)
        
        let jsonData:Data = text.string.data(using: .utf8)!
        let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if let dict = dic as? [String:Any] {
            if let type = dict["type"] as? String {
                if type == "hb" || type == "zz" {
           
                    
                    content.addStringExtra(status!, forKey: "msgStatus")
                    content.addStringExtra(msg.msgId, forKey: "msgId")
                }
            }
        }
        

        reminds.removeAll()
        send(message, msg)
    }
    
    func send(forLargeEmoticon emoticon: JCCEmoticonLarge) {
        guard let image = emoticon.contents as? UIImage else {
            return
        }
        let messageContent = JCMessageImageContent()
        messageContent.image = image
        messageContent.delegate = self
        let message = JCMessage(content: messageContent)
        
        let content = JMSGImageContent(imageData: image.pngData()!)
        let msg = JMSGMessage.ex.createMessage(conversation, content!, nil)
        msg.ex.isLargeEmoticon = true
        message.options.showsTips = true
        send(message, msg)
    }
    
    func send(forImage image: UIImage,jsonStr : String?=nil) {
        let data = image.jpegData(compressionQuality: 1.0)!
        let content = JMSGImageContent(imageData: data)

        let message = JMSGMessage.ex.createMessage(conversation, content!, nil)
        let imageContent = JCMessageImageContent()
        imageContent.delegate = self
        imageContent.image = image
        
        if jsonStr != nil {
            content?.addStringExtra(jsonStr!, forKey: "imageExtend")
        }
        
        content?.uploadHandler = {  (percent:Float, msgId:(String?)) -> Void in
            imageContent.upload?(percent)
        }
        let msg = JCMessage(content: imageContent)
        send(msg, message)
    }
    
    func send(voiceData: Data, duration: Double) {
        
        
        let voiceContent = JCMessageVoiceContent()
        voiceContent.data = voiceData
        voiceContent.duration = duration
        voiceContent.delegate = self
        let content = JMSGVoiceContent(voiceData: voiceData, voiceDuration: NSNumber(value: duration))
        let message = JMSGMessage.ex.createMessage(conversation, content, nil)
        
        let msg = JCMessage(content: voiceContent)
        send(msg, message)
    }
    func send(videoData: Data, thumbData: Data, duration: Double,format: String)  {
        
        
        
        let time = NSNumber(value: duration)
        let content = JMSGVideoContent(videoData: videoData, thumbData: thumbData, duration: time)
        content.format = format
        let message = JMSGMessage.ex.createMessage(conversation, content, nil)
        
        let videoContent = JCMessageVideoContent()
        videoContent.videoContent = content
        videoContent.data = videoData
        videoContent.image = UIImage(data: thumbData)
        videoContent.delegate = self
        
        let msg = JCMessage(content: videoContent)
        send(msg, message);
    }
    func send(fileData: Data, fileName: String) {
        let videoContent = JCMessageVideoContent()
        videoContent.data = fileData
        videoContent.delegate = self

        let content = JMSGFileContent(fileData: fileData, fileName: fileName)
        let message = JMSGMessage.ex.createMessage(conversation, content, nil)
        let msg = JCMessage(content: videoContent)
        send(msg, message)
    }
    
    func send(address: String, lon: NSNumber, lat: NSNumber) {
        let locationContent = JCMessageLocationContent()
        locationContent.address = address
        locationContent.lat = lat.doubleValue
        locationContent.lon = lon.doubleValue
        locationContent.delegate = self
        
        let content = JMSGLocationContent(latitude: lat, longitude: lon, scale: NSNumber(value: 1), address: address)
        let message = JMSGMessage.ex.createMessage(conversation, content, nil)
        let msg = JCMessage(content: locationContent)
        send(msg, message)
    }
    
    @objc func keyboardFrameChanged(_ notification: Notification) {
        let dic = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardValue = dic.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let bottomDistance = UIScreen.main.bounds.size.height - keyboardValue.cgRectValue.origin.y
        let duration = Double(dic.object(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as! NSNumber)
        
        UIView.animate(withDuration: duration, animations: {
        }) { (finish) in
            if (bottomDistance == 0 || bottomDistance == self.toolbar.height) && !self.isFristLaunch {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.chatView.scrollToLast(animated: false)
            }
            
//            self.chatView.frame = CGRect(x: 0, y: self.showNotice ? 25 : 0 , width: self.view.width, height: self.view.height)
            
            self.isFristLaunch = false
        }
    }
    
    @objc func _sendHandler() {
        let text = toolbar.attributedText
        if text != nil && (text?.length)! > 0 {
            send(forText: text!)
            toolbar.attributedText = nil
        }
    }
    
    @objc func _getSingleInfo() {
        let vc = JCSingleSettingViewController()
        vc.user = conversation.target as? JMSGUser
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func _getGroupInfo() {
        let vc = JCGroupSettingViewController()
        let group = conversation.target as! JMSGGroup
        vc.group = group
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - JMSGMessage Delegate
extension JCChatViewController: JMessageDelegate {
    
    fileprivate func updateMediaMessage(_ message: JMSGMessage, data: Data?) {
        DispatchQueue.main.async {
            if let index = self.messages.index(message) {
                let msg = self.messages[index]
                switch(message.contentType) {
                case .file:
                    printLog("update file message")
                    if message.ex.isShortVideo {
                        let videoContent = msg.content as! JCMessageVideoContent
                        videoContent.data = data
                        videoContent.delegate = self
                        msg.content = videoContent
                    } else {
                        let fileContent = msg.content as! JCMessageFileContent
                        fileContent.data = data
                        fileContent.delegate = self
                        msg.content = fileContent
                    }
                case .video:
                    printLog("updare video message")
                    let videoContent = msg.content as! JCMessageVideoContent
                    videoContent.image = UIImage(data: data!)
                    videoContent.delegate = self
                    msg.content = videoContent
                case .image:
                    let imageContent = msg.content as! JCMessageImageContent
                    let image = UIImage(data: data!)
                    imageContent.image = image
                    msg.content = imageContent
                default: break
                }
                
                
                msg.updateSizeIfNeeded = true
                self.chatView.update(msg, at: index)
                msg.updateSizeIfNeeded = false
                
                
//                self.chatView.update(msg, at: index)
            }
        }
    }
    
    func _updateBadge() {
        JMSGConversation.allConversations { (result, error) in
            guard let conversations = result as? [JMSGConversation] else {
                return
            }
            let count = conversations.unreadCount
            if count == 0 {
                self.leftButton.setTitle("", for: .normal)
            } else {
                self.leftButton.setTitle("(\(count))", for: .normal)
            }
        }
    }
    
    //MARK: 接收消息
    func onReceive(_ message: JMSGMessage!, error: Error!) {
        if error != nil {
            return
        }
        
        let message = _parseMessage(message)
        if messages.contains(where: { (m) -> Bool in
            return m.msgId == message.msgId
        }) {
            let indexs = chatView.indexPathsForVisibleItems
            for index in indexs {
                var m = messages[index.row]
                if !m.msgId.isEmpty {
                    m = _parseMessage(conversation.message(withMessageId: m.msgId)!, false)
                    chatView.update(m, at: index.row)
                }
            }
            return
        }
        
        
            if message.contentType == .text {
                let content = message.jmessage?.content as! JMSGTextContent
                let jsonData:Data = content.text.data(using: .utf8)!
                let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                MyLog(dic)
                if let dict = dic as? [String:Any] {
                    if let type = dict["type"] as? String {
                        if type == "hb" {
                            if let msgId = dict["msgId"] as? String {
//                                if isGroup {
//                                    return
//                                }else{
                                    if let msg = self.conversation.message(withMessageId: msgId) {
                                        if (msg.updateExtraValue("1", forKey: "msgStatus")) {
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                                            }
                                            
                                        }
                                    }
//                                }
                                
                            }
                            
                        }else if type == "zz" {
                            if let msgId = dict["msgId"] as? String {
                                if let msg = self.conversation.message(withMessageId: msgId) {
                                    if (msg.updateExtraValue("1", forKey: "msgStatus")) {
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                                        }

                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        
        
        
        
        //判断是否是群消息提醒
        if message.contentType == .eventNotification {
            
            MyLog("收到系统消息一条")
            
            return
        }else{
            MyLog("非系统消息")
        }
        
        
        
        
        messages.append(message)
        chatView.append(message)
        updateUnread([message])
        conversation.clearUnreadCount()
        if !chatView.isRoll {
            chatView.scrollToLast(animated: true)
        }
        _updateBadge()
    }
    
    //MARK: 消息发送结果
    func onSendMessageResponse(_ message: JMSGMessage!, error: Error!) {
        if let error = error as NSError? {
            if error.code == 803009 {
                MBProgressHUD_JChat.show(text: "发送失败，消息中包含敏感词", view: view, 2.0)
            }
            if error.code == 803005 {
                MBProgressHUD_JChat.show(text: "您已不是群成员", view: view, 2.0)
            }
        }
        if let index = messages.index(message) {
            let msg = messages[index]
            msg.options.state = message.ex.state
            chatView.update(msg, at: index)
            jMessageCount += 1
        }
    }
    
    func onReceive(_ retractEvent: JMSGMessageRetractEvent!) {
        if let index = messages.index(retractEvent.retractMessage) {
            let msg = _parseMessage(retractEvent.retractMessage, false)
            messages[index] = msg
            chatView.update(msg, at: index)
        }
    }
    
    //MARK: 接收离线消息
    func onSyncOfflineMessageConversation(_ conversation: JMSGConversation!, offlineMessages: [JMSGMessage]!) {
        let msgs = offlineMessages.sorted(by: { (m1, m2) -> Bool in
            return m1.timestamp.intValue < m2.timestamp.intValue
        })
        for item in msgs {
            let message = _parseMessage(item)
            
            if message.contentType == .text {
                let content = message.jmessage?.content as! JMSGTextContent
                let jsonData:Data = content.text.data(using: .utf8)!
                let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                MyLog(dic)
                if let dict = dic as? [String:Any] {
                    if let type = dict["type"] as? String {
                        if type == "hb" {
                            if let msgId = dict["msgId"] as? String {
//                                if isGroup {
//                                    return
//                                }else{
                                    if let msg = self.conversation.message(withMessageId: msgId) {
                                        if (msg.updateExtraValue("1", forKey: "msgStatus")) {
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                                            }
                                            
                                        }
                                    }
//                                }
                                
                            }
                            
                        }
                    }
                }
            }
            
            //判断是否是群消息提醒
            if message.contentType == .eventNotification {
                return
            }
            
            
            messages.append(message)
            chatView.append(message)
            updateUnread([message])
            conversation.clearUnreadCount()
            if !chatView.isRoll {
                chatView.scrollToLast(animated: true)
            }
        }
        _updateBadge()
    }
    
    func onReceive(_ receiptEvent: JMSGMessageReceiptStatusChangeEvent!) {
        for message in receiptEvent.messages! {
            if let index = messages.index(message) {
                let msg = messages[index]
                msg.unreadCount = message.getUnreadCount()
                chatView.update(msg, at: index)
            }
        }
    }
}

// MARK: - JCEmoticonInputViewDataSource & JCEmoticonInputViewDelegate
extension JCChatViewController: JCEmoticonInputViewDataSource, JCEmoticonInputViewDelegate {
    
    open func numberOfEmotionGroups(in emoticon: JCEmoticonInputView) -> Int {
        return _emoticonGroups.count
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, emotionGroupForItemAt index: Int) -> JCEmoticonGroup {
        return _emoticonGroups[index]
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, numberOfRowsForGroupAt index: Int) -> Int {
        return _emoticonGroups[index].rows
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, numberOfColumnsForGroupAt index: Int) -> Int {
        return _emoticonGroups[index].columns
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, moreViewForGroupAt index: Int) -> UIView? {
        if _emoticonGroups[index].type.isSmall {
            return _emoticonSendBtn
        } else {
            return nil
        }
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, insetForGroupAt index: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 12, left: 10, bottom: 12 + 24, right: 10)
    }

    open func emoticon(_ emoticon: JCEmoticonInputView, didSelectFor item: JCEmoticon) {
        if item.isBackspace {
            toolbar.deleteBackward()
            return
        }
        if let emoticon = item as? JCCEmoticonLarge {
            send(forLargeEmoticon: emoticon)
            return
        }
        if let code = item.contents as? String {
            return toolbar.insertText(code)
        }
        if let image = item.contents as? UIImage {
            let d = toolbar.font?.descender ?? 0
            let h = toolbar.font?.lineHeight ?? 0
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: d, width: h, height: h)
            toolbar.insertAttributedText(NSAttributedString(attachment: attachment))
            return
        }
    }
}

// MARK: - SAIToolboxInputViewDataSource & SAIToolboxInputViewDelegate
extension JCChatViewController: SAIToolboxInputViewDataSource, SAIToolboxInputViewDelegate {
    
    open func numberOfToolboxItems(in toolbox: SAIToolboxInputView) -> Int {
        return _toolboxItems.count
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, toolboxItemForItemAt index: Int) -> SAIToolboxItem {
        return _toolboxItems[index]
    }
    
    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfRowsForSectionAt index: Int) -> Int {
        return 2
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfColumnsForSectionAt index: Int) -> Int {
        return 4
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, insetForSectionAt index: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 12, left: 10, bottom: 12, right: 10)
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, shouldSelectFor item: SAIToolboxItem) -> Bool {
        return true
    }
    private func _pushToSelectPhotos() {
        let vc = YHPhotoPickerViewController()
        vc.maxPhotosCount = 9;
        vc.pickerDelegate = self
        present(vc, animated: true)
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, didSelectFor item: SAIToolboxItem) {
        toolbar.resignFirstResponder()
        switch item.identifier {
        case "page:pic": //图片
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    DispatchQueue.main.sync {
                        if status != .authorized {
                            JCAlertView.bulid().setTitle("无权限访问照片").setMessage("请在设备的设置-极光 IM中允许访问照片。").setDelegate(self).addCancelButton("好的").addButton("去设置").setTag(10001).show()
                        } else {
                            self._pushToSelectPhotos()
                        }
                    }
                })
            } else {
                _pushToSelectPhotos()
            }

        case "page:camera": //拍照
            present(imagePicker, animated: true, completion: nil)
//        case "page:lines":
//            present(videoPicker, animated: true, completion: nil)
//        case "page:administrator":
//            let vc = JCAddMapViewController()
//            vc.addressBlock = { (dict: Dictionary?) in
//                if dict != nil {
//                    let lon = Float(dict?["lon"] as! String)
//                    let lat = Float(dict?["lat"] as! String)
//                    let address = dict?["address"] as! String
//                    self.send(address: address, lon: NSNumber(value: lon!), lat: NSNumber(value: lat!))
//                }
//            }
//            navigationController?.pushViewController(vc, animated: true)
        case "page:transfer": //转账
//            let vc = FriendsBusinessCardViewController()
//            vc.conversation = conversation
//            let nav = JCNavigationController(rootViewController: vc)
//            present(nav, animated: true, completion: {
//                self.toolbar.isHidden = true
//            })
            
            let hbVC = TranAccountsVC()
        
            
            hbVC.redBlock = {(amount,text) in
                let dic = ["hb_infor":["blessing":text,"hb_extra": text ,"hb_id": "111111","hb_money": amount,"hb_num": "1","is_group": false,"received_id": "\((self.conversation.target as! JMSGUser).username)","send_user_id": "\(self.currentUser.username)","send_nickname":self.currentUser.nickname ?? "","received_nickname":(self.conversation.target as! JMSGUser).nickname ?? "","hb_create_time":getCurrentTime()],"message": "###@@@转账###@@@","type": "zz","status":0] as [String : Any]
                let data : NSData = try! JSONSerialization.data(withJSONObject: dic, options: []) as NSData
                let jsonString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
                
                self.send(forText: NSAttributedString.init(string: jsonString))
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                }
            }
            
            
            self.navigationController?.pushViewController(hbVC)
            
        case "page:redPackage": //红包
            
            
            
            if isGroup {
                
                let hbVC = SendRedPackageVC()
                hbVC.gid = (conversation.target as! JMSGGroup).gid
//                
//                let dict = ["hb_infor":["blessing":"text","hb_extra": "text","hb_id": "1234","hb_money": "100","hb_num": "10","is_group": true,"received_id": (self.conversation.target as! JMSGGroup).gid,"send_user_id": "\(self.currentUser.username)","send_nickname":self.currentUser.nickname ?? "","received_nickname":"","hb_create_time":getCurrentTime(),"sy_hb_num":"1"],"message": "###@@@红包###@@@","type": "hb","status":0] as [String : Any]
//                let dataString : NSData = try! JSONSerialization.data(withJSONObject: dict, options: []) as NSData
//                let jsonString = NSString(data: dataString as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                AsyncSocket.share.sendMessage(message: jsonString + "\n")
//                return
                
                
                let nav = CTNavigationController.init(rootViewController: hbVC)
                
                hbVC.redBlock = {[weak self] (amount,text,redUid,hb_number) in
                    
                    
                    let dic = ["hb_infor":["blessing":text,"hb_extra": text ,"hb_id": redUid,"hb_money": amount,"hb_num": hb_number,"is_group": true,"received_id": (self?.conversation.target as! JMSGGroup).gid,"send_user_id": "\(self?.currentUser.username ?? "")","send_nickname":self?.currentUser.nickname ?? "","received_nickname":"","hb_create_time":getCurrentTime(),"sy_hb_num":hb_number],"message": "###@@@红包###@@@","type": "hb","status":0] as [String : Any]
                    let data : NSData = try! JSONSerialization.data(withJSONObject: dic, options: []) as NSData
                    let jsonString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
                    
//                    AsyncSocket.share.sendMessage(message: jsonString)
//                    self?.send(forText: NSAttributedString.init(string: jsonString))

//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
//
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                            self?.chatView.scrollToLast(animated: false)
                        }
//
//                    }
                }
                
                
                self.present(nav, animated: true)
                
            }else{
                
                
                
                let hbVC = SendSimplePackageVC()
                hbVC.toUserName = (conversation.target as! JMSGUser).username

                let nav = CTNavigationController.init(rootViewController: hbVC)

                hbVC.redBlock = {[weak self] (amount,text,redUid) in
                    
                    
                            
                    
                            
                    let dic = ["hb_infor":["blessing":text,"hb_extra": text ,"hb_id": redUid,"hb_money": amount,"hb_num": "1","is_group": false,"received_id":"\((self?.conversation.target as! JMSGUser).username)","send_user_id": "\(self?.currentUser.username ?? "")","send_nickname":self?.currentUser.nickname ?? "","received_nickname":(self?.conversation.target as! JMSGUser).nickname ?? "","hb_create_time":getCurrentTime()],"message": "###@@@红包###@@@","type": "hb","status":0] as [String : Any]
                            let data : NSData = try! JSONSerialization.data(withJSONObject: dic, options: []) as NSData
                            let jsonString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
                            
                    self?.send(forText: NSAttributedString.init(string: jsonString))
                            
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                            self?.chatView.scrollToLast(animated: false)
                        }
                    }
                    
                }

                self.present(nav, animated: true)
                
            }
            
        case "page:administrator": //联系管理员
            self.navigationController?.pushViewController(MyServiceViewController(), animated: true)
        case "page:lines": //账单
            self.navigationController?.pushViewController(WalletRecordVC(), animated: true)
        case "page:topUp": //充值
            self.navigationController?.pushViewController(WalletRechargeVC(), animated: true)
        case "page:reflect": //提现
            self.navigationController?.pushViewController(WithdrawApplyVC(), animated: true)
            
        case "page:addressBook"://通讯录
            self.navigationController?.pushViewController(JCContactsViewController(), animated: true)


            
        default:
            break
        }
    }
    
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

// MARK: - UIImagePickerControllerDelegate & YHPhotoPickerViewControllerDelegate
extension JCChatViewController: YHPhotoPickerViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func selectedPhotoBeyondLimit(_ count: Int32, currentView view: UIView!) {
        MBProgressHUD_JChat.show(text: "最多选择\(count)张图片", view: nil)
    }
    
    func yhPhotoPickerViewController(_ PhotoPickerViewController: YHSelectPhotoViewController!, selectedPhotos photos: [Any]!) {
        for item in photos {
            guard let photo = item as? UIImage else {
                return
            }
            DispatchQueue.main.async {
                self.send(forImage: photo)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage?
        if let image = image?.fixOrientation() {
            send(forImage: image)
        }
        let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as! URL?
        if videoUrl != nil {
            //let data = try! Data(contentsOf: videoUrl!)
            //send(fileData: data)
            
            let format = "mov" //系统拍的是 mov 格式
            let videoData = try! Data(contentsOf: videoUrl!)
            let thumb = self.videoFirstFrame(videoUrl!, size: CGSize(width: JC_VIDEO_MSG_IMAGE_WIDTH, height: JC_VIDEO_MSG_IMAGE_HEIGHT));
            let thumbData = thumb.pngData()
            let avUrl = AVURLAsset(url: videoUrl!)
            let time = avUrl.duration
            let seconds = ceil(Double(time.value)/Double(time.timescale))
            self.send(videoData: videoData, thumbData: thumbData!, duration: seconds, format: format)
            
            /* 可选择转为 MP4 再发
            conversionVideoFormat(videoUrl!) { (paraUrl) in
                if paraUrl != nil {
                    //send  video message
                }
            }*/
        }
    }
    // 视频转 MP4 格式
    func conversionVideoFormat(_ inputUrl: URL,callback: @escaping (_ para: URL?) -> Void){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let strDate = formatter.string(from: date) as String
        
        let path = "\(NSHomeDirectory())/Documents/output-\(strDate).mp4"
        let outputUrl: URL = URL(fileURLWithPath: path)
        
        let avAsset = AVURLAsset(url: inputUrl)
        let exportSeesion = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
        exportSeesion?.outputURL = outputUrl
        exportSeesion?.outputFileType = AVFileType.mp4
        exportSeesion?.exportAsynchronously(completionHandler: {
            switch exportSeesion?.status {
            case AVAssetExportSession.Status.unknown?:
                break;
            case AVAssetExportSession.Status.cancelled?:
                callback(nil)
                break;
            case AVAssetExportSession.Status.waiting?:
                break;
            case AVAssetExportSession.Status.exporting?:
                break;
            case AVAssetExportSession.Status.completed?:
                callback(outputUrl)
                break;
            case AVAssetExportSession.Status.failed?:
                callback(nil)
                break;
            default:
                callback(nil)
                break
            }
        })
    }
    // 获取视频第一帧
    func videoFirstFrame(_ videoUrl: URL, size: CGSize) -> UIImage {
        let opts = [AVURLAssetPreferPreciseDurationAndTimingKey:false]
        let urlAsset = AVURLAsset(url: videoUrl, options: opts)
        let generator = AVAssetImageGenerator(asset: urlAsset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: size.width, height: size.height)
        //let error: Error
        do {
            let img = try generator.copyCGImage(at: CMTimeMake(value: 0, timescale: 10), actualTime: nil) as CGImage
            let image = UIImage(cgImage: img)
            return image
        } catch let error as NSError {
            print("\(error)")
            return UIImage.createImage(color: .gray, size: CGSize(width: JC_VIDEO_MSG_IMAGE_WIDTH, height: JC_VIDEO_MSG_IMAGE_HEIGHT))!
        }
    }
}

// MARK: - JCMessageDelegate
extension JCChatViewController: JCMessageDelegate {
    

    func message(message: JCMessageType, videoData data: Data?) {
        if let data = data {
            JCVideoManager.playVideo(data: data, currentViewController: self)
        }
    }

    func message(message: JCMessageType, location address: String?, lat: Double, lon: Double) {
        let vc = JCAddMapViewController()
        vc.isOnlyShowMap = true
        vc.lat = lat
        vc.lon = lon
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func message(message: JCMessageType, image: UIImage?) {
        
        if let str = message.jmessage?.content?.toJsonString() {
            let jsonData:Data = (str.data(using: .utf8))!
            let dic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String:Any]
            
            if let str2 = dic??["text"] as? String {
                let jsonData2:Data = (str2.data(using: .utf8))!
                let dic2 = try? JSONSerialization.jsonObject(with: jsonData2, options: .mutableContainers) as? [String:Any]
                if let type = dic2??["type"] as? String {
                    if type == "hb" {
                        print("点击红包")
                        return
                    }
                    
                }
            }
        }
        
        let browserImageVC = JCImageBrowserViewController()
        browserImageVC.messages = messages
        browserImageVC.conversation = conversation
        browserImageVC.currentMessage = message
        present(browserImageVC, animated: true) {
            self.toolbar.isHidden = true
        }

        
        
    }
    
    func message(message: JCMessageType, fileData data: Data?, fileName: String?, fileType: String?) {
        if data == nil {
            let vc = JCFileDownloadViewController()
            vc.title = fileName
            let msg = conversation.message(withMessageId: message.msgId)
            vc.fileSize = msg?.ex.fileSize
            vc.message = msg
            navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let fileType = fileType else {
                return
            }
            let msg = conversation.message(withMessageId: message.msgId)!
            let content = msg.content as! JMSGFileContent
            switch fileType.fileFormat() {
            case .document:
                let vc = JCDocumentViewController()
                vc.title = fileName
                vc.fileData = data
                vc.filePath = content.originMediaLocalPath
                vc.fileType = fileType
                navigationController?.pushViewController(vc, animated: true)
            case .video, .voice:
                let url = URL(fileURLWithPath: content.originMediaLocalPath ?? "")
                try! JCVideoManager.playVideo(data: Data(contentsOf: url), fileType, currentViewController: self)
            case .photo:
                let browserImageVC = JCImageBrowserViewController()
                let image = UIImage(contentsOfFile: content.originMediaLocalPath ?? "")
                browserImageVC.imageArr = [image!]
                browserImageVC.imgCurrentIndex = 0
                present(browserImageVC, animated: true) {
                    self.toolbar.isHidden = true
                }
            default:
                let url = URL(fileURLWithPath: content.originMediaLocalPath ?? "")
                documentInteractionController.url = url
                documentInteractionController.presentOptionsMenu(from: .zero, in: self.view, animated: true)
            }
        }
    }

    //MARK: *****点击头像*********MJ
    func message(message: JCMessageType, user: JMSGUser?, businessCardName: String, businessCardAppKey: String) {
        
        if message.options.hb_notificationType == 1 {
            return
        }
        
        if let user = user {
            let vc = ChatPersonalCenterVC()//JCUserInfoViewController()
            if self.conversation.ex.isGroup {
                if let group = conversation.target as? JMSGGroup {
                    vc.group = group
                }
            }
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: 点击红包
    func message(message: JCMessageType, text: String) {
        
        
        if let content = message.content as? JCRedContent {
            
            
            
            
            let msg = self.conversation.message(withMessageId: message.msgId)
            
            
//            if isRedTimeout(time: content.sendTime) && content.status == 0  {
//
//                if !self.isGroup{
//                    let vc = PersonRedDetailsVC()
//                    vc.redId = content.redUid ?? ""
//                    self.navigationController?.pushViewController(vc)
//                }else{
//                    let redDetailsVC = RedPackageDetailVC()
//                    redDetailsVC.redId = content.redUid ?? ""
//                    redDetailsVC.group_id = (self.conversation.target as! JMSGGroup).gid
//                    self.navigationController?.pushViewController(redDetailsVC)
//                }
//
//
//                    MBProgressHUD_JChat.show(text: "红包已超时", view: self.view)
//                    msg?.updateExtraValue("2", forKey: "msgStatus")
//
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
//                    }
//
//
//                return
//            }
            
            if !isGroup {
                if content.sendUid! == currentUser.username || content.status != 0 {
                    
                    let vc = PersonRedDetailsVC()
                    vc.redId = content.redUid ?? ""
                    self.navigationController?.pushViewController(vc)
                    

                    return
                }
            }else{
                
                if content.status != 0 {
                    let redDetailsVC = RedPackageDetailVC()
                    redDetailsVC.redId = content.redUid ?? ""
                    redDetailsVC.group_id = (conversation.target as! JMSGGroup).gid
                    self.navigationController?.pushViewController(redDetailsVC)
                    return
                }
                
            }
            
            
            
//            let urlStr = isGroup ? url_sendRayRed : url_sendRed
//
//
//
//
//            var dic = ["id":(content.redUid ?? "").replacingOccurrences(of: " ", with: ""),"method":"PUT"]
//
//            if isGroup {
//                dic["group_id"] = (conversation.target as! JMSGGroup).gid
//            }
            
            let selectPhotoVC = OpenRedPackageVC()
            selectPhotoVC.userName = content.sendUid
            selectPhotoVC.redTips = content.noteText ?? "恭喜发财，大吉大利"
            selectPhotoVC.amount = content.amount!
            selectPhotoVC.redId = content.redUid ?? ""
            if isGroup {
                selectPhotoVC.gid = (conversation.target as! JMSGGroup).gid
            }
            selectPhotoVC.modalPresentationStyle = .overCurrentContext
            selectPhotoVC.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            
            selectPhotoVC.redDetailsBlock = {(redId,gid) in
                
                let redDetailsVC = RedPackageDetailVC()
                redDetailsVC.redId = redId
                redDetailsVC.group_id = gid
                self.navigationController?.pushViewController(redDetailsVC)
            }
            
            selectPhotoVC.redBlock = {(json) in
            
//                MBProgressHUD_JChat.showMessage(message: "正在加载...", toView: self.view)
//
//                NetworkRequest.requestMethod(.post, URLString: urlStr, parameters: dic, success: { (value, json) in
//
//                    MBProgressHUD_JChat.hide(forView: self.view, animated: true)
                
                    var isReceiveEnd = false //是否领完
                    var robot_nickname = ""
                
                //机器人昵称
                    if let nickName = json["ret_data"]["robot_nickname"].string {
                        robot_nickname = nickName
                    }

                    if json["status"].stringValue == "SUCCESS" {

                        
                        if json["code"].stringValue != "200" {
                            if self.isGroup {
                                guard let isEnd = json["ret_data"]["isEnd"].bool else {
                                    
                                    MBProgressHUD_JChat.show(text: json["message"].stringValue, view: self.view)
                                    msg?.updateExtraValue(json["code"].stringValue, forKey: "msgStatus")
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                                    }
                                    
                                    MBProgressHUD_JChat.show(text: json["message"].stringValue, view: self.view)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                        if !self.isGroup{
                                            let vc = PersonRedDetailsVC()
                                            vc.redId = content.redUid ?? ""
                                            self.navigationController?.pushViewController(vc)
                                        }else{
                                            let redDetailsVC = RedPackageDetailVC()
                                            redDetailsVC.redId = content.redUid ?? ""
                                            redDetailsVC.group_id = (self.conversation.target as! JMSGGroup).gid
                                            self.navigationController?.pushViewController(redDetailsVC)
                                        }
                                    }
                                    
                                    return
                                }
                                
                                isReceiveEnd = isEnd
                            }
                        }
                        
                        
                        
                        
                        
                        
                        
                        if !self.isGroup{
                            
                            
                        let vc = PersonRedDetailsVC()
                        vc.redId = content.redUid ?? ""
                        self.navigationController?.pushViewController(vc)
                            
                            
                        }else{
                            
                            
                        let redDetailsVC = RedPackageDetailVC()
                        redDetailsVC.redId = content.redUid ?? ""
                        redDetailsVC.group_id = (self.conversation.target as! JMSGGroup).gid
                            self.navigationController?.pushViewController(redDetailsVC)
                            
                            
                        }
                        
                            
                            msg?.updateExtraValue("1", forKey: "msgStatus")
                        
                        if self.isGroup {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                            }
                        }
                            
                            if let con = msg?.content as? JMSGTextContent {
                                if let json = con.extras as? [String:Any] {
                                    if let msgId = json["msgId"] as? String {
                                        
                                        
                                        
                                        let dic = ["hb_infor":["blessing":content.blessing ?? "","hb_extra": content.blessing ?? "","hb_id": content.redUid ?? "0","hb_money": content.amount ?? "","hb_num": content.hb_num,"sy_hb_num":"\(Int(content.hb_num ?? "2")!-1)","is_group": self.isGroup,"received_id":"\(self.currentUser.username)","send_user_id": "\(content.sendUid ?? "0")","send_nickname":content.nickName ?? "","received_nickname":self.currentUser.nickname ?? "","hb_create_time":getCurrentTime()],"message": "###@@@红包###@@@","type": "hb","status":1,"msgId":msgId] as [String : Any]
                                        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                                        if let json = jsonData {
                                            let text = String(data: json, encoding: .utf8)!
                                            //
                                            if !self.isGroup {
                                                self.send(forText: NSAttributedString.init(string: text),status:"1")
                                            }
                                            
                                            
                                            if robot_nickname != "" { //机器人
                                                let dic2 = ["hb_infor":["blessing":content.blessing ?? "","hb_extra": content.blessing ?? "","hb_id": content.redUid ?? "0","hb_money": content.amount ?? "","hb_num": content.hb_num,"sy_hb_num":"\(Int(content.hb_num ?? "2")!-1)","is_group": self.isGroup,"received_id":"机器人","send_user_id": "\(content.sendUid ?? "0")","send_nickname":content.nickName ?? "","received_nickname":robot_nickname,"hb_create_time":getCurrentTime()],"message": "###@@@红包###@@@","type": "hb","status":1,"msgId":msgId] as [String : Any]
                                                let jsonData2: Data? = try? JSONSerialization.data(withJSONObject: dic2, options: .prettyPrinted)
                                                if let json = jsonData2 {
                                                    let text = String(data: json, encoding: .utf8)!
                                                    //
                                                    
                                                
//                                                        self.send(forText: NSAttributedString.init(string: text),status:"1")
                                                    
                                                }
                                            }
                                            
                                            
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                                                
//                                                if self.isGroup && isReceiveEnd { //红包领取完毕
//
//                                                    self.sendRedResult(gid: (self.conversation.target as! JMSGGroup).gid, redId: content.redUid ?? "")
//                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        
                        
                        
            
                        
                    }else{
                        
//                        if json["code"].stringValue == "2" {
//
//                            MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
//
//                        }else{
//                            msg?.updateExtraValue("2", forKey: "msgStatus")
//                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
//                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
//                            }
                        
                            
                            MBProgressHUD_JChat.show(text: json["error"].stringValue, view: self.view)
//                        }
                        
                        
                    }

//                }) {
//
//                    MBProgressHUD_JChat.hide(forView: self.view, animated: true)
//                }
            }
            self.present(selectPhotoVC, animated: false, completion: nil)
        
        }
    
        
        if let content = message.content as? JCTransferContent {
            
            let msg = self.conversation.message(withMessageId: message.msgId)
            
            if !isGroup {
                if content.sendUid! == currentUser.username {
                   
                    MBProgressHUD_JChat.show(text: "不能领取自己的转账", view: self.view)
                    
                    return
                }
                
                if content.status == 1 {
                    MBProgressHUD_JChat.show(text: "对方已领取你的转账", view: self.view)
                    
                    return
                }
                
                
                
                msg?.updateExtraValue("1", forKey: "msgStatus")
                
                if let con = msg?.content as? JMSGTextContent {
                    if let json = con.extras as? [String:Any] {
                        if let msgId =  json["msgId"] as? String {
                            
                            
                            let dic = ["hb_infor":["blessing":content.blessing ?? "","hb_extra": content.blessing ?? "","hb_id": "111111","hb_money": content.amount ?? "","hb_num": "1","is_group": false,"received_id": "\((self.conversation.target as! JMSGUser).username)","send_user_id": "\(self.currentUser.username)","send_nickname":content.nickName ?? "","received_nickname":self.currentUser.nickname ?? ""],"message": "###@@@转账###@@@","type": "zz","msgId":msgId,"status":1] as [String : Any]
                            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                            if let json = jsonData {
                                let text = String(data: json, encoding: .utf8)!
                                //
                                self.send(forText: NSAttributedString.init(string: text),status:"1")
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        
    }
    
    //MARK: 发送红包领取结果
    fileprivate func sendRedResult(gid:String,redId:String) {
        
        NetworkRequest.requestMethod(.get, URLString: url_sendRayRed, parameters: ["group_id":gid,"id":redId], success: { (value, json) in

            if json["status"].stringValue == "SUCCESS" {
                
                
                var userList = "" //用户列表
                
                var sum:Float = 0 //红包金额
                
                var cashBack:Float = 0 //返现
                
                var is_hit = false //是否有用户中雷

                if let arr = json["ret_data"]["items"].arrayObject as? [[String:Any]] {
                    
                    var array = [RayRedModel]()

                    for item in arr {
                        let model = RayRedModel.setModel(with: item)
                        array.append(model)
                        
                        if model.is_hit == "1" {
                            let user = "\n" + model.username! + "：" +  (model.amount ?? "0") + " 返" + (model.indemnity ?? "0")
                            userList += user
                            sum += Float(model.amount ?? "0")!
                            cashBack += Float(model.indemnity ?? "0")!
                            
                            is_hit = true
                        }
                    
                    }
                    
//                    for model in array {
//
//                        if model.user_type == "1" {
//                            let user = "\n用户-" + model.username! + "：" + model.amount!
//                            userList += user
//                        }
//
//                    }
                    
                    let redSum = String(format: "%.2f", sum)
                    let redCashBack = String(format: "%.2f", cashBack)
                    
                    let sendUserName = "@" + json["ret_data"]["username"].stringValue //发红包用户
                    
                    let title = "\n(\(json["ret_data"]["blessing"].stringValue)) \(json["ret_data"]["type"].stringValue == "0" ? "7包" : "9包") \(json["ret_data"]["odds"].stringValue)倍"
                    
                    let subtitle = "\n总返：\(redCashBack)元"
                    
                    let sendText = sendUserName + title + subtitle + userList
                    
                    let dic = ["hb_notification":["infor":sendText,"username":json["ret_data"]["username"].stringValue,"money":json["ret_data"]["amount"].stringValue],"message":"###@@@红包领取结果###@@@","type":"1"] as [String : Any]
                    
                    let data : NSData = try! JSONSerialization.data(withJSONObject: dic, options: []) as NSData
                    let jsonString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
                    
                    if is_hit {
                        self.send(forText: NSAttributedString.init(string: jsonString))
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)
                        }
                    }
                

//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
//
//                        for model in array {
//                            if model.reward != "" && Float(model.reward ?? "0")! != 0 {
//                                let dic = ["hb_notification":["infor":"","username":model.username,"money":model.reward],"message":"###@@@红包领取结果###@@@","type":"2"] as [String : Any]
//
//                                let data : NSData = try! JSONSerialization.data(withJSONObject: dic, options: []) as NSData
//                                let jsonString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                                self.send(forText: NSAttributedString.init(string: jsonString))
//
//                            }
//
//
//                        }
                    
                    

//                    }
                    
                    
                
                    
                    
                    
                    
                }
            }

        }, failure: {



        })
        
        
    }
    
    
    func clickTips(message: JCMessageType) {
        currentMessage = message
        let alertView = UIAlertView(title: "重新发送", message: "是否重新发送该消息？", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "发送")
        alertView.show()
    }
    //MARK: *****点击头像*********MJ
    func tapAvatarView(message: JCMessageType) {
        
        toolbar.resignFirstResponder()
        
        if message.options.hb_notificationType == 1 {
            return
        }
        
        
        if message.options.alignment == .right {
            
            let chatVC  = ChatPersonalCenterVC()
            
            chatVC.isMySelf = true
            chatVC.user = message.sender
            navigationController?.pushViewController(chatVC, animated: true)
//            navigationController?.pushViewController(JCMyInfoViewController(), animated: true)
        } else {
            let vc = ChatPersonalCenterVC()//JCUserInfoViewController()
            if self.conversation.ex.isGroup {
                if let group = conversation.target as? JMSGGroup {
                    vc.group = group
                }
            }
            vc.user = message.sender
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func longTapAvatarView(message: JCMessageType) {
        
        if message.options.hb_notificationType == 1 {
            return
        }
        
        
        if !isGroup || message.options.alignment == .right {
            return
        }
        toolbar.becomeFirstResponder()
        if let user = message.sender {
            toolbar.text.append("@")
            handleAt(toolbar, NSMakeRange(toolbar.text.length - 1, 0), user, false, user.displayName().length)
        }
    }

    func tapUnreadTips(message: JCMessageType) {
        let vc = UnreadListViewController()
        let msg = conversation.message(withMessageId: message.msgId)
        vc.message = msg
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension JCChatViewController: JCChatViewDelegate {
    func refershChatView( chatView: JCChatView) {
        messagePage += 1
        _loadMessage(messagePage)
        chatView.stopRefresh()
    }
    
    func deleteMessage(message: JCMessageType) {
        conversation.deleteMessage(withMessageId: message.msgId)
        if let index = messages.index(message) {
            jMessageCount -= 1
            messages.remove(at: index)
            if let message = messages.last {
                if message.content is JCMessageTimeLineContent {
                    messages.removeLast()
                    chatView.remove(at: messages.count)
                }
            }
        }
    }
    
    func forwardMessage(message: JCMessageType) {
        if let message = conversation.message(withMessageId: message.msgId) {
            let vc = JCForwardViewController()
            vc.message = message
            let nav = JCNavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: {
                self.toolbar.isHidden = true
            })
        }
    }
    
    func withdrawMessage(message: JCMessageType) {
        guard let message = conversation.message(withMessageId: message.msgId) else {
            return
        }
        JMSGMessage.retractMessage(message, completionHandler: { (result, error) in
            if error == nil {
                if let index = self.messages.index(message) {
                    let msg = self._parseMessage(self.conversation.message(withMessageId: message.msgId)!, false)
                    self.messages[index] = msg
                    self.chatView.update(msg, at: index)
                }
            } else {
                MBProgressHUD_JChat.show(text: "发送时间过长，不能撤回", view: self.view)
            }
        })
    }
    
    //MARK: 消息引用
    func referenceMessage(message: JCMessageType) {
        
        
        
        if let content = message.content as? JCMessageImageContent {
            
            self.toolbar.text = "@" + message.name + "\n" + "【图片】\n"
            
            
            self.image = content.image!
            self.name = message.name
            
            
        }
        
        if let content = message.content as? JCTextImageContent {
            
            self.toolbar.text = "@" + message.name + "\n" + "【图片】\n"
            
            self.image = content.image!
            self.name = message.name
        }
        
    }

    func indexPathsForVisibleItems(chatView: JCChatView, items: [IndexPath]) {
        for item in items {
            if item.row <= minIndex {
                var msgs: [JCMessage] = []
                for index in item.row...minIndex  {
                    msgs.append(messages[index])
                }
                updateUnread(msgs)
                minIndex = item.row
            }
        }
    }

    fileprivate func updateUnread(_ messages: [JCMessage]) {
        for message in messages {
            if message.options.alignment != .left {
                continue
            }
            if let msg = conversation.message(withMessageId: message.msgId) {
                if msg.isHaveRead {
                    continue
                }
                msg.setMessageHaveRead({ _,_  in
                })
            }
        }
    }
    
    
    //MARK: 跑马灯公告
    fileprivate func groupAnnouncement() {
        
        NetworkRequest.requestMethod(.get, URLString: url_aboutUs, parameters: ["id":"9"], success: { (value, json) in
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let title = json["ret_data"]["bodys"].string {
                    
                    self.showNotice = true
                    
                    self.noticeView = GroupNoticeView.init(frame: .init(x: 0, y: 0, width: ScreenW, height: 30))
                    self.view.addSubview(self.noticeView)
                    self.noticeView.title = title
                    
                    self.chatView.frame = CGRect(x: 0, y: 30, width: self.view.width, height: self.view.height-30)
                }
            }
            
        }) {
            
            
        }
        
    }
}

extension JCChatViewController: UIAlertViewDelegate {

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 10001 {
            if buttonIndex == 1 {
                JCAppManager.openAppSetter()
            }
            return
        }
        switch buttonIndex {
        case 1:
            if let index = messages.index(currentMessage) {
                messages.remove(at: index)
                chatView.remove(at: index)
                let msg = conversation.message(withMessageId: currentMessage.msgId)
                currentMessage.options.state = .sending

                if let msg = msg {
                    if let content = currentMessage.content as? JCMessageImageContent,
                        let imageContent = msg.content as? JMSGImageContent
                    {
                        imageContent.uploadHandler = {  (percent:Float, msgId:(String?)) -> Void in
                            content.upload?(percent)
                        }
                    }
                }
                messages.append(currentMessage as! JCMessage)
                chatView.append(currentMessage)
                conversation.send(msg!, optionalContent: JMSGOptionalContent.ex.default)
//                chatView.scrollToLast(animated: true)
            }
        default:
            break
        }
    }
}

// MARK: - SAIInputBarDelegate & SAIInputBarDisplayable
extension JCChatViewController: SAIInputBarDelegate, SAIInputBarDisplayable {
    
    open override var inputAccessoryView: UIView? {
        return toolbar
    }
    open var scrollView: SAIInputBarScrollViewType {
        return chatView
    }
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open func inputView(with item: SAIInputItem) -> UIView? {
        if let view = inputViews[item.identifier] {
            return view
        }
        switch item.identifier {
        case "kb:emoticon":
            let view = JCEmoticonInputView()
            view.delegate = self
            view.dataSource = self
            inputViews[item.identifier] = view
            return view
        case "kb:toolbox":
            let view = SAIToolboxInputView()
            view.delegate = self
            view.dataSource = self
            inputViews[item.identifier] = view
            return view
        default:
            return nil
        }
    }
    
    open func inputViewContentSize(_ inputView: UIView) -> CGSize {
        return CGSize(width: view.frame.width, height: 216)
    }
    
    func inputBar(_ inputBar: SAIInputBar, shouldDeselectFor item: SAIInputItem) -> Bool {
        return true
    }
    open func inputBar(_ inputBar: SAIInputBar, shouldSelectFor item: SAIInputItem) -> Bool {
        if item.identifier == "kb:audio" {
            return true
        }
        guard let _ = inputView(with: item) else {
            return false
        }
        return true
    }
    open func inputBar(_ inputBar: SAIInputBar, didSelectFor item: SAIInputItem) {
        inputItem = item
        
        if item.identifier == "kb:audio" {
            inputBar.deselectBarAllItem()
            return
        }
        if let kb = inputView(with: item) {
            inputBar.setInputMode(.selecting(kb), animated: true)
        }
    }
    open func inputBar(didChangeMode inputBar: SAIInputBar) {
        if inputItem?.identifier == "kb:audio" {
            return
        }
        if let item = inputItem, !inputBar.inputMode.isSelecting {
            inputBar.deselectBarItem(item, animated: true)
        }
    }
    
    open func inputBar(didChangeText inputBar: SAIInputBar) {
        _emoticonSendBtn.isEnabled = inputBar.attributedText.length != 0
    }
    
    public func inputBar(shouldReturn inputBar: SAIInputBar) -> Bool {
        if inputBar.attributedText.length == 0 {
            return false
        }
        send(forText: inputBar.attributedText)
        inputBar.attributedText = nil
        return false
    }
    
    func inputBar(_ inputBar: SAIInputBar, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentIndex = range.location
        if !isGroup {
            return true
        }
        if string == "@" {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                let vc = JCRemindListViewController()
                vc.finish = { (user, isAtAll, length) in
                    self.handleAt(inputBar, range, user, isAtAll, length)
                }
                vc.group = self.conversation.target as? JMSGGroup
                let nav = JCNavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {})
            }
        } else {
            return updateRemids(inputBar, string, range, currentIndex)
        }
        return true
    }

    func handleAt(_ inputBar: SAIInputBar, _ range: NSRange, _ user: JMSGUser?, _ isAtAll: Bool, _ length: Int) {
        let text = inputBar.text!
        let currentIndex = range.location
        var displayName = "所有成员"

        if let user = user {
            displayName = user.displayName()
        }
        let remind = JCRemind(user, currentIndex, currentIndex + 2 + displayName.length, displayName.length + 2, isAtAll)
        if text.length == currentIndex + 1 {
            inputBar.text = text + displayName + " "
        } else {
            let index1 = text.index(text.endIndex, offsetBy: currentIndex - text.length + 1)
            let prefix = text.substring(with: (text.startIndex..<index1))
            let index2 = text.index(text.startIndex, offsetBy: currentIndex + 1)
            let suffix = text.substring(with: (index2..<text.endIndex))
            inputBar.text = prefix + displayName + " " + suffix
            let _ = self.updateRemids(inputBar, "@" + displayName + " ", range, currentIndex)
        }
        self.reminds.append(remind)
        self.reminds.sort(by: { (r1, r2) -> Bool in
            return r1.startIndex < r2.startIndex
        })
    }
    
    func updateRemids(_ inputBar: SAIInputBar, _ string: String, _ range: NSRange, _ currentIndex: Int) -> Bool {
        for index in 0..<reminds.count {
            let remind = reminds[index]
            let length = remind.length
            let startIndex = remind.startIndex
            let endIndex = remind.endIndex
            // Delete
            if currentIndex == endIndex - 1 && string.length == 0 {
                for _ in 0..<length {
                    inputBar.deleteBackward()
                }
                // Move Other Index
                for subIndex in (index + 1)..<reminds.count {
                    let subTemp = reminds[subIndex]
                    subTemp.startIndex -= length
                    subTemp.endIndex -= length
                }
                reminds.remove(at: index)
                return false;
            } else if currentIndex > startIndex && currentIndex < endIndex {
                // Delete Content
                if string.length == 0 {
                    for subIndex in (index + 1)..<reminds.count {
                        let subTemp = reminds[subIndex]
                        subTemp.startIndex -= 1
                        subTemp.endIndex -= 1
                    }
                    reminds.remove(at: index)
                    return true
                }
                // Add Content
                else {
                    for subIndex in (index + 1)..<reminds.count {
                        let subTemp = reminds[subIndex]
                        subTemp.startIndex += string.length
                        subTemp.endIndex += string.length
                    }
                    reminds.remove(at: index)
                    return true
                }
            }
        }
        for index in 0..<reminds.count {
            let tempDic = reminds[index]
            let startIndex = tempDic.startIndex
            if currentIndex <= startIndex {
                if string.count == 0 {
                    for subIndex in index..<reminds.count {
                        let subTemp = reminds[subIndex]
                        subTemp.startIndex -= 1
                        subTemp.endIndex -= 1
                    }
                    return true
                } else {
                    for subIndex in index..<reminds.count {
                        let subTemp = reminds[subIndex]
                        subTemp.startIndex += string.length
                        subTemp.endIndex += string.length
                    }
                    return true
                }
            }
        }
        return true
    }
    
    func inputBar(touchDown recordButton: UIButton, inputBar: SAIInputBar) {
        if recordingHub != nil {
            recordingHub.removeFromSuperview()
        }
        recordingHub = JCRecordingView(frame: CGRect.zero)
        recordHelper.updateMeterDelegate = recordingHub
        recordingHub.startRecordingHUDAtView(view)
        recordingHub.frame = CGRect(x: view.centerX - 70, y: view.centerY - 70, width: 136, height: 136)
        recordHelper.startRecordingWithPath(String.getRecorderPath()) {
        }
    }
    
    func inputBar(dragInside recordButton: UIButton, inputBar: SAIInputBar) {
        recordingHub.pauseRecord()
    }
    
    func inputBar(dragOutside recordButton: UIButton, inputBar: SAIInputBar) {
        recordingHub.resaueRecord()
    }
    
    func inputBar(touchUpInside recordButton: UIButton, inputBar: SAIInputBar) {
        if recordHelper.recorder ==  nil {
            return
        }
        recordHelper.finishRecordingCompletion()
        if (recordHelper.recordDuration! as NSString).floatValue < 1 {
            recordingHub.showErrorTips()
            let time: TimeInterval = 1.5
            let hub = recordingHub
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                hub?.removeFromSuperview()
            }
            return
        } else {
            recordingHub.removeFromSuperview()
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: recordHelper.recordPath!))
        send(voiceData: data, duration: Double(recordHelper.recordDuration!)!)
    }
    
    func inputBar(touchUpOutside recordButton: UIButton, inputBar: SAIInputBar) {
        recordHelper.cancelledDeleteWithCompletion()
        recordingHub.removeFromSuperview()
    }
}

// MARK: - JCRecordVoiceHelperDelegate
extension JCChatViewController: JCRecordVoiceHelperDelegate {
    public func beyondLimit(_ time: TimeInterval) {
        recordHelper.finishRecordingCompletion()
        recordingHub.removeFromSuperview()
        let data = try! Data(contentsOf: URL(fileURLWithPath: recordHelper.recordPath!))
        send(voiceData: data, duration: Double(recordHelper.recordDuration!)!)
    }
}

extension JCChatViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else {
            return true
        }
        if view.isKind(of: JCMessageTextContentView.self) {
            return false
        }
        return true
    }
}

extension JCChatViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return view
    }
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return view.frame
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension JCChatViewController : GCDAsyncSocketDelegate {

    /**
     * 发送成功时回调
     */
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {


        let dict = ["hb_infor":["blessing":"text","hb_extra": "text","hb_id": "1234","hb_money": "100","hb_num": "10","is_group": true,"received_id": (self.conversation.target as! JMSGGroup).gid,"send_user_id": "\(self.currentUser.username)","send_nickname":self.currentUser.nickname ?? "","received_nickname":"","hb_create_time":getCurrentTime(),"sy_hb_num":"1"],"message": "###@@@红包###@@@","type": "hb","status":0] as [String : Any]
        let dataString : NSData = try! JSONSerialization.data(withJSONObject: dict, options: []) as NSData
        let jsonString = NSString(data: dataString as Data, encoding: String.Encoding.utf8.rawValue)! as String

        let content = JMSGTextContent(text: jsonString)
        content.addStringExtra("success", forKey: "sendSate")

        let msg = conversation.createMessage(with: content)


        content.addStringExtra("0", forKey: "msgStatus")
        content.addStringExtra(msg!.msgId, forKey: "msgId")



        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.chatView.scrollToLast(animated: false)
            }

        }

        self.socket(AsyncSocket.share.clientSocket, didRead: jsonString.data(using: String.Encoding.utf8)!, withTag: -1)

        AsyncSocket.share.clientSocket.readData(withTimeout: -1, tag: 0)


    }

    /**
     * 收到消息时回调
     */
    internal func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) -> Void {
        // 1、获取客户端发来的数据，把 NSData 转 NSString
        let readClientDataString: NSString? = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)

        let dict = ["hb_infor":["blessing":"text","hb_extra": "text","hb_id": "1234","hb_money": "100","hb_num": "10","is_group": true,"received_id": (self.conversation.target as! JMSGGroup).gid,"send_user_id": "龙马","send_nickname":self.currentUser.nickname ?? "","received_nickname":"","hb_create_time":getCurrentTime(),"sy_hb_num":"1"],"message": "###@@@红包###@@@","type": "hb","status":0] as [String : Any]

        let dataString : NSData = try! JSONSerialization.data(withJSONObject: dict, options: []) as NSData
        let jsonString = NSString(data: dataString as Data, encoding: String.Encoding.utf8.rawValue)! as String

        let content = JMSGTextContent(text: jsonString)
        content.addStringExtra("success", forKey: "sendSate")

        let msg = conversation.createMessage(with: content)



        content.addStringExtra("0", forKey: "msgStatus")
        content.addStringExtra(msg!.msgId, forKey: "msgId")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kReloadAllMessage), object: nil)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.chatView.scrollToLast(animated: false)
            }

        }

    }


}
