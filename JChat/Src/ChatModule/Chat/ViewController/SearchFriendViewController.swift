//
//  SearchFriendViewController.swift
//  JChat
//
//  Created by DUONIU_MAC on 2019/6/29.
//  Copyright © 2019年 HXHG. All rights reserved.
//

import UIKit

class SearchFriendViewController: CTViewController {
    
    var isSearchUser: Bool = false
    
    open var user: JMSGUser?
    
    fileprivate lazy var infoView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 65.5))
    
    fileprivate lazy var bgView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
    
    fileprivate lazy var avatorView: UIImageView = UIImageView(frame: CGRect(x: 15, y: 7.5, width: 50, height: 50))
    fileprivate lazy var nameLabel: UILabel =  UILabel(frame: CGRect(x: 65 + 10, y: 21, width: 200, height: 22.5))
    private let width = UIScreen.main.bounds.size.width
    open lazy var addButton = UIButton()
    open var addChatRoomManger: Bool = false
    
    private lazy var networkErrorView: UIView = {
        let tipsView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
        var tipsLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tipsView.width, height: 22.5))
        tipsLabel.textColor = UIColor(netHex: 0x999999)
        tipsLabel.textAlignment = .center
        tipsLabel.font = UIFont.systemFont(ofSize: 16)
        tipsLabel.text = "无法连接网络"
        tipsView.addSubview(tipsLabel)
        tipsView.isHidden = true
        tipsView.backgroundColor = .white
        return tipsView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _init()

        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.addSubview(searchBar)
        
        self.navigationController?.navigationBar.addSubview(cancaelBtn)
        
        cancaelBtn.addTarget(self, action: #selector(cancaelAction), for: .touchUpInside)
        
        searchBar.delegate = self
        
        cancaelBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(30)
            make.width.equalTo(40)
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(cancaelBtn.snp.left).offset(-10)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-10)
        }
        
    }
    
    private func _init() {
        view.backgroundColor = UIColor(netHex: 0xE8EDF3)
        automaticallyAdjustsScrollViewInsets = false
        
        if isSearchUser {
            self.title = "发起单聊"
        } else {
            self.title = "添加好友"
            addButton.frame = CGRect(x: self.width - 72 - 15, y: 20, width: 72, height: 30)
            addButton.backgroundColor = UIColor.KTheme.deepOrange
            addButton.setTitle("加好友", for: .normal)
            addButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//            let image = UIImage.createImage(color: UIColor(netHex: 0x2dd0cf), size: CGSize(width: 72, height: 25))
//            addButton.setBackgroundImage(image, for: .normal)
            addButton.layer.cornerRadius = 2
            addButton.layer.masksToBounds = true
            if(self.addChatRoomManger == false){
                addButton.addTarget(self, action: #selector(_addFriend), for: .touchUpInside)
            }
            infoView.backgroundColor = .white
            infoView.addSubview(addButton)
            
            
        }
        
        
        nameLabel.textColor = UIColor(netHex: 0x2C2C2C)
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        
        let line = UILabel(frame: CGRect(x: 15, y: 50 + 15, width: view.width - 30, height: 0.5))
        line.backgroundColor = UIColor(netHex: 0xD9D9D9)
        
        tipsView.isHidden = true
        
        infoView.addSubview(avatorView)
        infoView.addSubview(nameLabel)
        infoView.addSubview(line)
        infoView.addSubview(tipsView)
        
        bgView.backgroundColor = .white
        bgView.addSubview(infoView)
        bgView.isHidden = true
        view.addSubview(bgView)
        
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(_tapHandler))
        infoView.addGestureRecognizer(tapGR)
        
        view.addSubview(networkErrorView)
        
        if JCNetworkManager.isNotReachable {
            networkErrorView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: NSNotification.Name(rawValue: "kNetworkReachabilityChangedNotification"), object: nil)
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        if let curReach = note.object as? Reachability {
            let status = curReach.currentReachabilityStatus()
            switch status {
            case NotReachable:
                networkErrorView.isHidden = false
            default :
                networkErrorView.isHidden = true
            }
        }
    }
    
    @objc func _tapHandler(sender:UITapGestureRecognizer) {
        if (user?.isEqual(to: JMSGUser.myInfo()))! {
            
            let vc = ChatPersonalCenterVC()//JCUserInfoViewController()
            vc.user = user
            vc.isMySelf = true
            
            navigationController?.pushViewController(vc, animated: true)//JCMyInfoViewController()
            return
        }
        let vc = ChatPersonalCenterVC()//JCUserInfoViewController()
        vc.user = user
//        if !isSearchUser && !(user?.isFriend)! {
//            vc.isOnAddFriend = true
//        }
       
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func _addFriend() {
        
        if (user?.isFriend)! {
            MBProgressHUD_JChat.show(text: "对方已是你的好友", view: self.view)
            return
        }
        
        let vc = JCAddFriendViewController()
        vc.user = self.user!

        navigationController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate var searchBar : UISearchBar = {
       
        let searchBar = UISearchBar()
        searchBar.barStyle = .default
        searchBar.placeholder = "手机号"
//        searchBar.showsCancelButton = true
        searchBar.barTintColor = UIColor.black

        searchBar.becomeFirstResponder()
        return searchBar
        
    }()
    
    fileprivate var cancaelBtn : UIButton = {
      
        let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()
    
    fileprivate lazy var tipsView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 67))
        view.backgroundColor = .white
        let tips = UILabel()
        tips.frame = view.frame
        tips.font = UIFont.systemFont(ofSize: 16)
        tips.textColor = UIColor(netHex: 0x999999)
        tips.textAlignment = .center
        tips.text = "未搜索到用户"
        view.addSubview(tips)
        return view
    }()
    
    //MARK: 取消
    @objc fileprivate func cancaelAction() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
        
//        self.bgView.isHidden = false
    }

}

extension SearchFriendViewController : UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        guard let name = searchBar.text else {
            return
        }
        if name.isEmpty {
            return
        }
        
        MBProgressHUD_JChat.showMessage(message: "查找中", toView: view)
        
        JMSGUser.userInfoArray(withUsernameArray: [name]) { (result, error) in
            
            self.bgView.isHidden = false
            
            MBProgressHUD_JChat.hide(forView: self.view, animated: true)
            if error == nil {
                
                let users = result as! [JMSGUser]
                let user = users.first
                self.user = user
                if (user?.isFriend)! || (user?.isEqual(to: JMSGUser.myInfo()))! {
                    self.addButton.isHidden = false
                } else {
                    self.addButton.isHidden = false
                }
                
                if(self.addChatRoomManger == true){
                    self.addButton.isHidden = false;
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "SearchChatRoomManagerResult"), object: nil)
                }
                self.nameLabel.text = user?.displayName()
                self.avatorView.image = UIImage.loadImage("com_icon_user_50")
                user?.thumbAvatarData({ (data, id, error) in
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.avatorView.image = image
                    }
                })
                
            } else {
                self.tipsView.isHidden = false
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
