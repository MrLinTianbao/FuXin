//
//  AppDelegate.swift
//  JChat
//
//  Created by JIGUANG on 2017/2/16.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage
import Bugly

public protocol SelfAware: class {
    static func awake()
}
class NothingToSeeHere {
    static func harmlessFunction(){
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleaseintTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleaseintTypes, Int32(typeCount))
        for index in 0..<typeCount {
            (types[index] as? SelfAware.Type)?.awake()
        }
        types.deallocate()
    }
}

extension UIApplication {
    private static let runOnce:Void = {
        NothingToSeeHere.harmlessFunction()
    }()
    open override var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window: UIWindow?
    
    
    /*================================= 腾讯短视频AppKey===============================================*/
//    let kTXLiteAVlicenceURL:String = "http://license.vod2.myqcloud.com/license/v1/fe3a56e1e3236e7fa07b6105bb4ce64d/TXUgcSDK.licence"
    let kTXLiteAVlicenceURL:String = "http://ugc-licence-test-1252463788.file.myqcloud.com/RDM_Enterprise.licence" //腾讯
    
//    let kTXLiteAVlicenceKey:String = "32f81c237d436af51f1ca428fd3ffece"
    let kTXLiteAVlicenceKey:String = "9bc74ac7bfd07ea392e8fdff2ba5678a"
   
    
    let JMAPPKEY = "b940e15cdad7707d4d0172c9"
    // 百度地图 SDK AppKey，请自行申请你对应的 AppKey
    let BMAPPKEY = "b940e15cdad7707d4d0172c9"
    
    var _mapManager: BMKMapManager?
    
    fileprivate var hostReachability: Reachability!
    
    deinit {
        hostReachability.stopNotifier()
    }
    
    //MARK: - life cycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if READ_VERSION
            print("\n-------------READ_VERSION------------\n")
            print("\t 如果不需要支持已读未读功能")
            print("在 Build Settings 中，找到 Swift Compiler - Custom Flags，\n并在其中的 Other Swift Flags 删除 -D READ_VERSION")
            print("\n-------------------------------------\n")
        #endif

        if #available(iOS 11.0, *) {
            UITableView.appearance().estimatedRowHeight = 0
            UITableView.appearance().estimatedSectionFooterHeight = 0
            UITableView.appearance().estimatedSectionHeaderHeight = 0
        }
        
       
        //腾讯bugly
        Bugly.start(withAppId: "888338bc01")
        
        //注册微信SDK
        WXApi.registerApp(weChatAppid)
        
        // im server连接
        AsyncSocket.share.startConnect()
        

        JMessage.setupJMessage(launchOptions, appKey: JMAPPKEY, channel: nil, apsForProduction: true, category: nil, messageRoaming: false)
        _setupJMessage()
        
        _mapManager = BMKMapManager()
        BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK(BMK_COORDTYPE_BD09LL)
        _mapManager?.start(BMAPPKEY, generalDelegate: nil)
        
        hostReachability = Reachability(hostName: "www.apple.com")
        hostReachability.startNotifier()
       
        
        self.setTXLiteAVService()
        self.customDefaultStyle()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        _setupRootViewController()
        window?.makeKeyAndVisible()
        return true
    }

    /** 配置全局样色 */
    func customDefaultStyle(){
        //配置IQKeyboardManager
        let manager = IQKeyboardManager.shared()
        //manager.shouldResignOnTouchOutside = YES; //设置点击View其它位置收回键盘
        manager.toolbarDoneBarButtonItemText = "完成"
        
        //配置SVProgressHUD
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setFont(UIFont.systemFont(ofSize: 16))
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
    }
    
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JMessage.registerDeviceToken(deviceToken)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        resetBadge(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        
        resetBadge(application)
    }
    
    
    // MARK: - private func
    private func _setupJMessage() {
        JMessage.add(self, with: nil)
        JMessage.setLogOFF()
//        JMessage.setDebugMode()
        if #available(iOS 8, *) {
            JMessage.register(
                forRemoteNotificationTypes: UIUserNotificationType.badge.rawValue |
                    UIUserNotificationType.sound.rawValue |
                    UIUserNotificationType.alert.rawValue,
                categories: nil)
        } else {
            // iOS 8 以前 categories 必须为nil
            JMessage.register(
                forRemoteNotificationTypes: UIRemoteNotificationType.badge.rawValue |
                    UIRemoteNotificationType.sound.rawValue |
                    UIRemoteNotificationType.alert.rawValue,
                categories: nil)
        }
    }
    
    private func _setupRootViewController() {
        if UserDefaults.standard.object(forKey: kCurrentUserName) != nil {
            window?.rootViewController = JCMainTabBarController()
        } else {
            let nav = JCNavigationController(rootViewController: SignInViewController())
            window?.rootViewController = nav
        }
        
        
    }
    
    private func resetBadge(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
        JMessage.resetBadge()
    }
    
    //MARK: ********************************************************  初始化腾讯短视频 SDK
    func setTXLiteAVService() {
        
//        TXUGCBase.setLicenceURL(kTXLiteAVlicenceURL, key: kTXLiteAVlicenceKey)
//        print("SDK Version = \(TXLiveBase.getSDKVersionStr() ?? "")")
        
    }
    
    //重写AppDelegate的handleOpenURL和openURL方法(微信登录)
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
    
        return WXApi.handleOpen(url, delegate: self)
    }
    
    
}

extension AppDelegate : WXApiDelegate {
    
    
    func onReq(_ req: BaseReq) {
        
        
    }
    
    func onResp(_ resp: BaseResp) {
        
        if let res = resp as? SendAuthResp {
            
            if res.errCode != 0 {
                return
            }
            
            if res.state == "FXApp" {
                
                NotificationCenter.default.post(name: .wechat_login, object: nil, userInfo: ["code":res.code!])
                
                
            }
            
            
        }
        
    }
}

//MARK: - JMessage Delegate
extension AppDelegate: JMessageDelegate,JMSGGroupDelegate {
    
//    func onReceive(_ message: JMSGMessage!, error: Error!) {
//
//
//    }
    
    func onDBMigrateStart() {
        MBProgressHUD_JChat.showMessage(message: "数据库升级中", toView: nil)
    }
    
    func onDBMigrateFinishedWithError(_ error: Error!) {
        MBProgressHUD_JChat.hide(forView: nil, animated: true)
        MBProgressHUD_JChat.show(text: "数据库升级完成", view: nil)
    }
    func onReceive(_ event: JMSGUserLoginStatusChangeEvent!) {
        switch event.eventType.rawValue {
        case JMSGLoginStatusChangeEventType.eventNotificationLoginKicked.rawValue,
//             JMSGLoginStatusChangeEventType.eventNotificationServerAlterPassword.rawValue,
             JMSGLoginStatusChangeEventType.eventNotificationUserLoginStatusUnexpected.rawValue:
            _logout()
            
            
        default:
            break
        }
    }
    func onReceive(_ event: JMSGFriendNotificationEvent!) {
        switch event.eventType.rawValue {
        case JMSGFriendEventType.eventNotificationReceiveFriendInvitation.rawValue,
             JMSGFriendEventType.eventNotificationAcceptedFriendInvitation.rawValue,
             JMSGFriendEventType.eventNotificationDeclinedFriendInvitation.rawValue:
            cacheInvitation(event: event)
        case JMSGFriendEventType.eventNotificationDeletedFriend.rawValue,
             JMSGFriendEventType.eventNotificationReceiveServerFriendUpdate.rawValue:
            NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateFriendList), object: nil)
        default:
            break
        }
    }
    //****加群****mj
    func onReceiveApplyJoinGroupApprovalEvent(_ event: JMSGApplyJoinGroupEvent!) {
        print("=================   \(event.sendApplyUser.displayName()) -> 申请加入群聊")
        
        if event.isInitiativeApply {
//            AlertClass.showToat(withStatus: "有人加群")
            let dic = [
                "eventID":event.eventID,
                "groupID":event.groupID,
                "username":event.sendApplyUser.username,
                "nickname":event.sendApplyUser.nickname ?? "",
                "uid":event.sendApplyUser.uid
                ] as [String : Any]
            if var list = CacheClass.arrayForEnumKey(CacheClass.stringForEnumKey(.username)) as? [[String:Any]] {
                list.insert(dic , at: 0)
                CacheClass.setObject(list, forEnumKey: CacheClass.stringForEnumKey(.username))

            }else{
                var list = [[String:Any]]()
                list.insert(dic , at: 0)
                CacheClass.setObject(list, forEnumKey: CacheClass.stringForEnumKey(.username))
            }
            
            if UserDefaults.standard.object(forKey: kUnreadGroupInvitationCount) != nil {
                let count = UserDefaults.standard.object(forKey: kUnreadGroupInvitationCount) as! Int
                UserDefaults.standard.set(count + 1, forKey: kUnreadGroupInvitationCount)
            } else {
                UserDefaults.standard.set(1, forKey: kUnreadGroupInvitationCount)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateVerification), object: nil)

        }
       
        

    }
    private func cacheInvitation(event: JMSGNotificationEvent) {
        let friendEvent =  event as! JMSGFriendNotificationEvent
        let user = friendEvent.getFromUser()
        let reason = friendEvent.getReason()
        let info = JCVerificationInfo.create(username: user!.username, nickname: user?.nickname, appkey: user!.appKey!, resaon: reason, state: JCVerificationType.wait.rawValue)
        switch event.eventType.rawValue {
        case JMSGFriendEventType.eventNotificationReceiveFriendInvitation.rawValue:
            
            if let bool = CacheClass.boolForEnumKey(.addFriendCertification) { //ture为需要验证
                
                if !bool {
                    JMSGFriendManager.acceptInvitation(withUsername: user?.username, appKey: user?.appKey) { (value, error) in
                        
                        if error == nil {
                            MyLog("成功接受好友请求")
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateVerification), object: nil)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateFriendList), object: nil)
                            info.state = JCVerificationType.accept.rawValue
                            JCVerificationInfoDB.shareInstance.insertData(info)
                        }
                    }
                }else{
                    info.state = JCVerificationType.receive.rawValue
                    JCVerificationInfoDB.shareInstance.insertData(info)
                }
                
            }else{
                info.state = JCVerificationType.receive.rawValue
                JCVerificationInfoDB.shareInstance.insertData(info)
            }
                
            
            
            
            
        case JMSGFriendEventType.eventNotificationAcceptedFriendInvitation.rawValue:
            info.state = JCVerificationType.accept.rawValue
            JCVerificationInfoDB.shareInstance.updateData(info)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateFriendList), object: nil)
        case JMSGFriendEventType.eventNotificationDeclinedFriendInvitation.rawValue:
            info.state = JCVerificationType.reject.rawValue
            JCVerificationInfoDB.shareInstance.updateData(info)
        default:
            break
        }
        if UserDefaults.standard.object(forKey: kUnreadInvitationCount) != nil {
            let count = UserDefaults.standard.object(forKey: kUnreadInvitationCount) as! Int
            UserDefaults.standard.set(count + 1, forKey: kUnreadInvitationCount)
        } else {
            UserDefaults.standard.set(1, forKey: kUnreadInvitationCount)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateVerification), object: nil)
    }
    
    func _logout() {
        JCVerificationInfoDB.shareInstance.queue = nil
        UserDefaults.standard.removeObject(forKey: kCurrentUserName)
        let alertView = UIAlertView(title: "您的账号在其它设备上登录", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "重新登录")
        alertView.show()
    }
}

extension AppDelegate: UIAlertViewDelegate {
    
    private func pushToLoginView() {
        UserDefaults.standard.removeObject(forKey: kCurrentUserPassword)
        if let appDelegate = UIApplication.shared.delegate,
            let window = appDelegate.window {
            
            removeUseNews()
            window?.rootViewController = JCNavigationController(rootViewController: SignInViewController())
            
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            guard let username = UserDefaults.standard.object(forKey: kLastUserName) as? String  else {
                pushToLoginView()
                return
            }
            guard let password = UserDefaults.standard.object(forKey: kCurrentUserPassword) as? String else {
                pushToLoginView()
                return
            }
            MBProgressHUD_JChat.showMessage(message: "登录中", toView: nil)
            JMSGUser.login(withUsername: username, password: password) { (result, error) in
                MBProgressHUD_JChat.hide(forView: nil, animated: true)
                if error == nil {
                    UserDefaults.standard.set(username, forKey: kLastUserName)
                    UserDefaults.standard.set(username, forKey: kCurrentUserName)
                    UserDefaults.standard.set(password, forKey: kCurrentUserPassword)
                } else {
                    self.pushToLoginView()
                    MBProgressHUD_JChat.show(text: "\(String.errorAlert(error! as NSError))", view: self.window?.rootViewController?.view, 2)
                }
            }
        } else {
            pushToLoginView()
        }
    }
    
    // MARK: iOS10以下使用这两个方法接收通知
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(.newData)
        
        //app在后台
        if UIApplication.shared.applicationState != .active {
            
            
            
        }else{
            
        }
    }
}

