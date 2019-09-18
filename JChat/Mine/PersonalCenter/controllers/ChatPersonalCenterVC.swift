//
//  PocketPay1VC.swift
//  XLCustomer
//
//  Created by longma on 2019/1/9.
//  Copyright © 2019年 XLH. All rights reserved.
//

import UIKit

class ChatPersonalCenterVC: CTViewController {
    var group: JMSGGroup?
    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labID: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var blackListView: UIView!
    @IBOutlet weak var btnSend: MJButton!
    @IBOutlet weak var switchFlag: UISwitch!
    @IBOutlet weak var clvData: UICollectionView!
    
    var isMySelf = false
    
    @IBOutlet weak var btnRemark: UIButton!
    fileprivate var images = [String]()
    
    //用户信息
    var user: JMSGUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isMySelf {
            btnSend.isHidden = true
            blackListView.isHidden = true
            deleteBtn.isHidden = true
            btnRemark.isHidden = true
        }
        
        if !user.isFriend {
            deleteBtn.setTitle("添加好友", for: .normal)
        }
        
        getData()

        self.setUIAppearance()
        self.setData()

    }
    func setData(){
        if group != nil {
            btnRemark.setTitle("设置备注名", for: .normal)
            if let groupNickname = self.group?.memberInfo(withUsername: user.username, appkey: user.appKey)?.groupNickname {
                labName.text = "昵称：\(groupNickname)"
            }else{
                labName.text = "昵称：\(user.displayName())"
            }
        }else{
            btnRemark.setTitle("修改好友备注", for: .normal)
            labName.text = "昵称：\(user.displayName())"
        }
        
        labID.text = "ID：\(user.uid)"
        
        user.thumbAvatarData({ (data, id, error) in
            if let data = data {
                self.imvIcon.image = UIImage.init(data: data)
            }else{
                self.imvIcon.image = chatDefaultHead
            }
        })
        
//        imvIcon.setUrlImage(with: user.avatar, placeholder: chatDefaultHead)
    }
    //通知刷新页面
    @objc func _updateUserInfo() {
        self.setData()
    }
    
    @IBAction func onFriendClicked(_ sender: Any) {
        
        let vc = MyCircleViewController()
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onRemarkBtnClicked(_ sender: Any) {
        
        if group != nil {
            let username  = CacheClass.stringForEnumKey(.username)
            if let memberInfo = group?.memberInfo(withUsername: username!, appkey: user.appKey) {
                if memberInfo.memberType != .owner{
                    MBProgressHUD_JChat.show(text: "你没有修改权限", view: self.view)
                    return
                }
            }
        }
        
        let vc = ChangeRemarkNameVC()
        vc.group = group
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
    
    @IBAction func onSendBtnClicked(_ sender: Any) {
        //跳转到聊天页面
        JMSGConversation.createSingleConversation(withUsername: (user?.username)!, appKey: (user?.appKey)!) { (result, error) in
            if error == nil {
                let conv = result as! JMSGConversation
                let vc = JCChatViewController(conversation: conv)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateConversation), object: nil, userInfo: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
 
    }
    @IBAction func onDelBtnClicked(_ sender: Any) {
        
        if deleteBtn.titleLabel?.text == "添加好友" {
            let vc = JCAddFriendViewController()
            vc.user = self.user!
            
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let selectPhotoVC = SelectPhotoViewController.init(titleArray: ["确认删除该好友"])
            selectPhotoVC.modalPresentationStyle = .overCurrentContext
            selectPhotoVC.photoBlock = {(title) in
                if title == "确认删除该好友" {
                    JMSGFriendManager.removeFriend(withUsername: self.user.username, appKey: self.user.appKey, completionHandler: { (result, error) in
                        if error == nil {
                            let conv = JMSGConversation.singleConversation(withUsername: self.user.username)
                            if conv != nil {
                                JMSGConversation.deleteSingleConversation(withUsername: self.user.username)
                            }
                            NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateFriendList), object: nil)
                            self.navigationController?.popToRootViewController(animated: true)
                        } else {
                            MBProgressHUD_JChat.show(text: "\(String.errorAlert(error! as NSError))", view: self.view)
                        }
                    })
                }
            }
            self.present(selectPhotoVC, animated: false, completion: nil)
        }
        
        
        
    }
    
    func setUIAppearance(){
        
        JMSGUser.userInfoArray(withUsernameArray: [user.username]) { (result, error) in
            
            if let userList = result as? [JMSGUser] {
                
                if let user = userList.first {
                    
                    user.thumbAvatarData({ (data, id, error) in
                        if let data = data {
                            self.imvIcon.image = UIImage.init(data: data)
                        }
                    })
                }
            }
        }
        
         NotificationCenter.default.addObserver(self, selector: #selector(_updateUserInfo), name: NSNotification.Name(rawValue: kUpdateFriendInfo), object: nil)
        
        self.view.backgroundColor = UIColor.KTheme.scroll
        btnSend.isClickEnabled = true
        switchFlag.onTintColor = UIColor.KTheme.deepOrange
        switchFlag.isOn = user.isInBlacklist
        switchFlag.addTarget(self, action: #selector(switchDidChange(_:)), for: .valueChanged)

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0; //列与列之间的间距
        layout.minimumLineSpacing = 8;//行与行之间的间距
        layout.itemSize = CGSize.init(width: 60, height: 60)
        layout.scrollDirection = .horizontal
 
        clvData.collectionViewLayout = layout
        clvData.backgroundColor = UIColor.white
        clvData.delegate = self
        clvData.dataSource = self
        let cell = UINib.init(nibName: "KSampleClvCell", bundle: nil)
        clvData.register(cell, forCellWithReuseIdentifier: "KSampleClvCell")
        
    }
    
    //MARK: 获取内容
    fileprivate func getData() {
        
        NetworkRequest.requestMethod(.get, URLString: url_friendCircle, parameters: ["username":user.username], success: { (value, json) in
            
            
            if json["status"].stringValue == "SUCCESS" {
                
                if let array = json["ret_data"]["list"].arrayObject as? [[String:Any]] {
                    
                    
                    for item in array {
                        let model = FriendCircleModel.setModel(with: item)
                        
                        if let images = model.images as? [String] {
                            for image in images {
                                
                                self.images.append(image)
                                
                                if self.images.count == 5 {
                                    break
                                }
                            }
                            
                        }
                        
                        
                        
                    }
                    
                    self.clvData.reloadData()
                    
                    
                }
            }
            
        }) {
            
        }
    }
   
    @objc func switchDidChange(_ sender: UISwitch){
    
        MBProgressHUD_JChat.showMessage(message: "修改中", toView: view)
        if sender.isOn {
            JMSGUser.addUsers(toBlacklist: [user.username]) { (result, error) in
                MBProgressHUD_JChat.hide(forView: self.view, animated: true)
                if error == nil {
                    MBProgressHUD_JChat.show(text: "修改成功", view: self.view)
                } else {
                    sender.isOn = !sender.isOn
                    MBProgressHUD_JChat.show(text: "\(String.errorAlert(error! as NSError))", view: self.view)
                }
            }
        } else {
            JMSGUser.delUsers(fromBlacklist: [user.username]) { (result, error) in
                MBProgressHUD_JChat.hide(forView: self.view, animated: true)
                if error == nil {
                    MBProgressHUD_JChat.show(text: "修改成功", view: self.view)
                } else {
                    sender.isOn = !sender.isOn
                    MBProgressHUD_JChat.show(text: "\(String.errorAlert(error! as NSError))", view: self.view)
                }
            }
        }
        
    }
    
}
extension ChatPersonalCenterVC: UICollectionViewDelegate, UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KSampleClvCell", for: indexPath) as! KSampleClvCell
        cell.imvIcon.setUrlImage(with: images[indexPath.row], placeholder: UIImage.init(named: ""))
//        cell.imvIcon.contentMode = .scaleAspectFill
//        cell.imvIcon.contentMode = .scaleToFill
        return cell
    }
   
}
