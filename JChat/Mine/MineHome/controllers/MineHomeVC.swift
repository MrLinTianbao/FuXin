//
//  ViewController.swift
//  XLCustomer
//
//  Created by longma on 2018/10/16.
//  Copyright © 2018年 XLH. All rights reserved.
//

import UIKit

class MineHomeVC: CTViewController {
    let titleArray = [["钱包","快速充值"],["扫一扫","我的朋友圈"],["分销","群规"],["设置"]]
    var targetArray = [["MineWalletVC","WalletRechargeVC"],["QRCode","MyCircleViewController"],["DistributionShareVC","GroupRuleVC"],["MineSetListVC"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUIAppearance()
        
        if mjdebug {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
//                self.pushDebug()
            })
        }

       
    }
    func pushDebug(){
        
        //添加群成员加入记录
        let mainBundle = Bundle.main
        let videoPath = mainBundle.path(forResource: "EDJTRBEH9-mobile", ofType: "mp4")
        let videoData = try! Data.init(contentsOf: URL.init(fileURLWithPath: videoPath!))
        
        AlertClass.waiting("上传中")
        NetworkRequest.requestMethod(.upload, URLString: url_upload, parameters: nil , progress: { (progress) in
            
        }, constructingBodyWith: { (formData) in
            let curTime = getCurrentTime().getTimestamp()
            formData.appendPart(withFileData: videoData, name: "file", fileName: "\(curTime).mp4", mimeType: "mp4")
        }, success: { (value, json) in
            if json["status"].stringValue == "SUCCESS" {
                if let ret_data = json["ret_data"].dictionary {
                    let url = ret_data["url"]?.stringValue
                    
                    AlertClass.showToat(withStatus: "上传成功")
                }
            }else{
                AlertClass.stop()
                AlertClass.showErrorToat(withJson: json)
            }
            print("***************** 成功-----\(json)")
            
        }) {
            AlertClass.stop()
        }
        
//        let vc = MessageViewController()
//        self.navigationController?.pushViewController(vc)
//        self.pushViewController(targetStr: "MessageViewController")
    }
    func setLocalData(){
     
        tbvHeadView.labUserName.text = CacheClass.stringForEnumKey(.nickname)
        tbvHeadView.labUserID.text = "ID：" + (CacheClass.stringForEnumKey(.username) ?? "")
        let phone = "手机：" + (CacheClass.stringForEnumKey(.mobile_code) ?? "") + " " + (CacheClass.stringForEnumKey(.mobile) ?? "")
        tbvHeadView.labUserPhone.text = phone
        
        tbvHeadView.imvIcon.setUrlImage(with: (CacheClass.stringForEnumKey(.avatar) ?? ""), placeholder: chatDefaultHead)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setLocalData()
        self.requestData()

    }
    func requestData(){
        
        getUserNews { (json) in
            self.setLocalData()
        }
        
//        NetworkRequest.requestMethod(.get, URLString: url_getUserNews, parameters:nil , success: { (value, json) in
//            if json["status"].stringValue == "SUCCESS" {
//                if let ret_data = json["ret_data"].dictionary {
//
//                    CacheClass.setObject(ret_data["username"]?.string ?? "", forEnumKey: .username)
//                    CacheClass.setObject(ret_data["nickname"]?.string ?? "", forEnumKey: .nickname)
//                    CacheClass.setObject(ret_data["avatar"]?.string ?? "", forEnumKey: .avatar)
//                    CacheClass.setObject(ret_data["money"]?.string ?? "", forEnumKey: .money)
//                    CacheClass.setObject(ret_data["mobile"]?.string ?? "", forEnumKey: .mobile)
//                    CacheClass.setObject(ret_data["mobile_code"]?.string ?? "", forEnumKey: .mobile_code)
//                    CacheClass.setObject(ret_data["groupid"]?.string ?? "", forEnumKey: .groupid)
//                    CacheClass.setObject(ret_data["is_adding_friend_certification"]?.string ?? "", forEnumKey: .is_adding_friend_certification)
//                    CacheClass.setObject(ret_data["addtime"]?.string ?? "", forEnumKey: .addtime)
//                    self.setLocalData()
//                }
//
//            }else{
//                AlertClass.showErrorToat(withJson: json)
//            }
//        }) {}
    }
    func setUIAppearance(){
        self.title = "我的"
        self.view.addSubview(tbvData)
        tbvData.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }
    
    //MARK: **************************** 懒加载
    lazy var tbvData: UITableView = {
        
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.KTheme.scroll
        tableView.rowHeight = 56
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        tableView.separatorColor = UIColor.KTheme.line
        let cell = UINib.init(nibName: "MineHomeTbvCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "MineHomeTbvCell")
        
        tableView.tableHeaderView = tbvHeadView

        return tableView
    }()
    lazy var tbvHeadView: MineHomeHeadView = {
        let tableHeadView = Bundle.main.loadNibNamed("MineHomeHeadView", owner: self, options: nil)?.last as! MineHomeHeadView
        tableHeadView.frame = CGRect(x: 0, y: 0, width: ScreenW, height: 110)
        tableHeadView.autoresizingMask = UIView.AutoresizingMask(rawValue: 0)
        tableHeadView.delegate = self
        return tableHeadView
    }()
   
}
extension MineHomeVC: MineHomeHeadViewDelegate  {
    
    func onHeadBtnClicked() {
//        self.pushViewController(targetStr: "UserQRCodeVC")
        if mjdebug {
            pushDebug()

        }else{
            self.pushViewController(targetStr: "MineInfoSetVC")
        }
        
    }
    
    
}
extension MineHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = titleArray[section]
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell( withIdentifier: "MineHomeTbvCell", for: indexPath) as! MineHomeTbvCell
        cell.labTitle.text = titleArray[indexPath.section][indexPath.row]
        cell.imvIcon.image = UIImage.init(named: titleArray[indexPath.section][indexPath.row])

        return cell
    }
    /*分区头部部高度*/
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHead = UIView.init()
        sectionHead.backgroundColor = tableView.backgroundColor
        return sectionHead
    }
    /*分区尾部高度*/
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let tag = targetArray[indexPath.section][indexPath.row]
        
        if  tag == "WalletRechargeVC" {
            let vc = WalletRechargeVC()
            vc.title = "快速充值"
            self.navigationController?.pushViewController(vc)
            return
        }else if tag == "QRCode"{
            if  QRCodeReader.supportsMetadataObjectTypes([AVMetadataObject.ObjectType.qr,AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.code128]) {
                let reader = QRCodeReader.init(metadataObjectTypes: [AVMetadataObject.ObjectType.qr,AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.code128])
                let vc = QRCodeReaderVC.init()
                vc.modalPresentationStyle = .formSheet
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
                
            }else{
                AlertClass.showToat(withStatus: "设备不支持扫描二维码或条形码")
            }
        }
        else{
            
            self.pushViewController(targetStr: tag)

        }


    }
    
}
extension MineHomeVC: MJQRCodeReaderDelegate {
    func reader(_ reader: QRCodeReaderVC!, didScanResult result: String!) {
        print("=================   \(result ?? "")")

        
        let url = URL.init(string: result.mj_removeAllSapce)
        if let parm = url?.parametersFromQueryString {
            print("=======111==========   \(parm)")
            
            if result.contains("group")
            {
                let mid = parm["gid"]
     
                self.dismiss(animated: true) {
                    let timeout = parm["timeout"] ?? "0"
                    let timeoutInt = Double(timeout) ?? 0
                    
                    let timeInterval: TimeInterval = Date.init().timeIntervalSince1970
                    
                    if timeoutInt < timeInterval {
                        AlertClass.showToat(withStatus: "群二维码已过期")
                        return
                    }
                    
                    
                    JMSGGroup.applyJoin(withGid: mid ?? "", reason: "请求加群", completionHandler: { (result, error) in
                        
                        if error == nil {
                            AlertClass.showToat(withStatus: "加群请求已发送")
                        } else {
                            let e = error! as NSError
                            print("=========code======== \(e.code)")
                            if e.code == 856003 {
                                print("=========code======== \(e.code)")
                                //重复申请 IOS
                                AlertClass.showToat(withStatus: "加群请求已发送")
                                return
                            }else if e.code == 859002{
                                AlertClass.showToat(withStatus: "该群组类型不支持申请入群")
                            }else{
                                AlertClass.showToat(withStatus: "\(String.errorAlert(error! as NSError))")
                            }
                        }
                        
                        
                        
                    })
                   
                }
            }
            else
            {
                let mid = parm["username"]
                self.dismiss(animated: true) {
                    
                    if let timeout = parm["timeout"] {
                       let timeStamp = Double(timeout) ?? 0
                       let nowTimeStamp = Date().timeIntervalSince1970
                        if timeStamp < nowTimeStamp {
                            AlertClass.showToat(withStatus: "用户二维码已过期")
                            return
                        }
                    }
                    
                    JMSGFriendManager.sendInvitationRequest(withUsername: mid, appKey: nil, reason: nil) { (result, error) in
                        if error == nil {
                             let JMAPPKEY = "b940e15cdad7707d4d0172c9"
                            let info = JCVerificationInfo.create(username: mid!, nickname: nil, appkey: JMAPPKEY, resaon: nil, state: JCVerificationType.wait.rawValue)
                            JCVerificationInfoDB.shareInstance.insertData(info)
                            
                            AlertClass.showToat(withStatus: "好友请求已发送")
                            NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateVerification), object: nil)
                        } else {
                            
                            let e = error! as NSError
                            print("=========code======== \(e.code)")
                            if e.code == 805002 {
                                print("=========code======== \(e.code)")
                                //重复申请 IOS
                                AlertClass.showToat(withStatus: "双方已经是好友")
                                return
                            }else{
                                AlertClass.showToat(withStatus: "\(String.errorAlert(error! as NSError))")
                            }
                            
                            
                        }
                    }
                }
            }

           
            
            
            
            
            
            
            
//            if let timeout = parm["timeout"] {
//               let timeStamp = timeout.mj_stringConvertToDateBy(format: "yyyy-MM-ddHH:mm:ss")
//               let nowTimeStamp = Date().timeIntervalSince1970
//                if timeStamp > nowTimeStamp {
//                    AlertClass.showToat(withStatus: "二维码已过期")
//                    return
//                }
//
//            }
//                let username = parm["username"]
//                let uid = parm["uid"]
//
//                self.dismiss(animated: true) {
//                    JMSGFriendManager.sendInvitationRequest(withUsername: username, appKey: nil, reason: nil) { (result, error) in
//                        if error == nil {
//                            AlertClass.showToat(withStatus: "好友请求已发送")
//                            NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateVerification), object: nil)
//                        } else {
//                            AlertClass.showToat(withStatus: "\(String.errorAlert(error! as NSError))")
//                        }
//                    }
//                }
//
        }
        
        

    }
   
}
