//
//  JCConversationListViewController.swift
//  JChat
//
//  Created by JIGUANG on 2017/2/16.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import JMessage
import SwiftyJSON

class JCConversationListViewController: CTViewController {
    
    var datas: [JMSGConversation] = []

    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCustomService()
        _init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getUnReadCount(sender:)), name: .unReadCount, object: nil)
        
        
    }
    
    @objc fileprivate func getUnReadCount(sender:Notification) {
        
        _getConversations()
        
//        let json = JSON.init(sender.userInfo?["data"] ?? [String:Any]())
//
//        if let dic = json.dictionaryObject {
//
//            if let hb_infor = dic["hb_infor"] as? [String:Any] {
//                if let group_id = hb_infor["group_id"] as? String {
//
//                    let conversation = JMSGConversation.groupConversation(withGroupId: "\(group_id)")
//
//                    let dataString : NSData = try! JSONSerialization.data(withJSONObject: dic, options: []) as NSData
//                    let jsonString = NSString(data: dataString as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//                    let content = JMSGTextContent(text: jsonString)
//                    content.addStringExtra("success", forKey: "sendSate")
//                    content.addStringExtra("0", forKey: "msgStatus")
//
//                    let msg = conversation?.createMessage(with: content)
//
//
//                    if let msgId = msg?.msgId {
//                        content.addStringExtra(msgId, forKey: "msgId")
//                    }
//
//                    onReceive(msg, error: nil)
//
//                }
//            }
//        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isConnecting {
            titleTips.text = "连接中"
            titleTipsView.isHidden = false
        } else {
            titleTipsView.isHidden = true
        }
        _getConversations()
        
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        titleTipsView.isHidden = true
//        selectView.isHidden = true
        

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        JMessage.remove(self, with: nil)
    }
    
    fileprivate var isConnecting = false
    
    let searchVC = JCSearchResultViewController()
    private lazy var addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    private lazy var searchController: UISearchController = UISearchController(searchResultsController: searchVC)
//    private lazy var searchController: JCSearchController = JCSearchController(searchResultsController: JCNavigationController(rootViewController: JCSearchResultViewController()))
    private lazy var searchView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 55))
    fileprivate lazy var tableview: UITableView = {
        var tableview = UITableView(frame: .zero)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundColor = UIColor.KTheme.notice
        tableview.register(JCConversationCell.self, forCellReuseIdentifier: "JCConversationCell")
        tableview.separatorStyle = .none
        return tableview
    }()
    fileprivate lazy var errorTips: JCNetworkTipsCell = JCNetworkTipsCell()
    fileprivate var showNetworkTips = false
    fileprivate lazy var emptyView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: StatusBarAddNavBarHeight + 55, width: self.view.width, height: self.view.height - StatusBarAddNavBarHeight - 55))
        view.isHidden = true
        view.backgroundColor = .white
        let tips = UILabel()
        tips.text = "暂无会话"
        tips.textColor = UIColor(netHex: 0x999999)
        tips.sizeToFit()
        tips.center = CGPoint(x: view.centerX, y: view.height / 2 - 60)
        view.addSubview(tips)
        return view
    }()
    
    fileprivate lazy var titleTips: UILabel = {
        var tips = UILabel(frame: CGRect(x: 23, y: 0, width: 67, height: 44))
        tips.font = UIFont.systemFont(ofSize: 18)
        tips.textColor = UIColor.white
        tips.textAlignment = .left
        tips.backgroundColor = UIColor(netHex: 0x5AD4D3)
        return tips
    }()

    fileprivate lazy var titleTipsView: UIView = {
        var view = UIView(frame: CGRect(x: self.view.width / 2 - 45, y: 20, width: 90, height: 44))
        view.backgroundColor =  UIColor(netHex: 0x5AD4D3)
        let activityView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 12, width: 20, height: 20))
        view.addSubview(activityView)
        activityView.startAnimating()
        view.addSubview(self.titleTips)
        view.isHidden = true
        return view
    }()
    
    //Mark: - private func
    private func _init() {
        view.backgroundColor = UIColor(netHex: 0xe8edf3)
        if #available(iOS 10.0, *) {
            navigationController?.tabBarItem.badgeColor = UIColor(netHex: 0xEB424C)
        }
        
        

        let appDelegate = UIApplication.shared.delegate
        let window = appDelegate?.window!
        window?.addSubview(titleTipsView)
        
        _setupNavigation()
        JMessage.add(self, with: nil)
//        let nav = searchController.searchResultsController as! JCNavigationController
//        let vc = nav.topViewController as! JCSearchResultViewController
        searchController.delegate = self
        searchController.searchResultsUpdater = searchVC
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "搜索";
//        searchController.searchResultsUpdater = vc
//        searchView.addSubview(searchController.searchBar)
        searchView.backgroundColor = UIColor.KTheme.scroll
//        tableview.tableHeaderView = searchView
        view.addSubview(tableview)
        view.addSubview(emptyView)
        
        tableview.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController;
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }else{
            tableview.tableHeaderView = searchController.searchBar
        }
        self.definesPresentationContext = true
        self.searchVC.nav = self.navigationController
        
//        selectView.isHidden = true
//        self.view.addSubview(selectView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: NSNotification.Name(rawValue: "kNetworkReachabilityChangedNotification"), object: nil)

        _getConversations()
        NotificationCenter.default.addObserver(self, selector: #selector(_getConversations), name: NSNotification.Name(rawValue: kUpdateConversation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectClose), name: NSNotification.Name.jmsgNetworkDidClose, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectSucceed), name: NSNotification.Name.jmsgNetworkDidLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connecting), name: NSNotification.Name.jmsgNetworkIsConnecting, object: nil)
    }
    
    @objc func reachabilityChanged(note: NSNotification) {
        if let curReach = note.object as? Reachability {
            let status = curReach.currentReachabilityStatus()
            switch status {
            case NotReachable:
                notReachable()
            default :
                reachable()
            }
        }
    }
    
    private func _setupNavigation() {
        
        addButton.addTarget(self, action: #selector(_clickNavRightButton(_:)), for: .touchUpInside)
        addButton.setImage(UIImage.init(named: "addFri"), for: .normal)
        let item = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem =  item
    }
    
    func _updateBadge() {
        let count = datas.unreadCount
//        if count > 99 {
//            navigationController?.tabBarItem.badgeValue = "99+"
//
//        } else {
//            navigationController?.tabBarItem.badgeValue = count == 0 ? nil : "\(count)"
//        }
        
        if self.rt_navigationController == nil {
            return
        }
        
        if count > 99 {
            self.rt_navigationController.tabBarItem.badgeValue = "99+"
        } else {
            self.rt_navigationController.tabBarItem.badgeValue = count == 0 ? nil : "\(count)"
        }
    }
    
    @objc func _getConversations() {
        JMSGConversation.allConversations { (result, error) in
            guard let conversatios = result else {
                return
            }
            self.datas = conversatios as! [JMSGConversation]
            
            for i in 0..<self.datas.count {
                
                let conv = self.datas[i]
                
                if let target = conv.target as? JMSGGroup {
                    if let unreadCount = UserDefaults.standard.string(forKey: JMSGUser.myInfo().username + target.gid) {
                        
                        conv.unreadCount = NSNumber.init(value: Int(unreadCount) ?? 0)
                        
                        self.datas[i] = conv
                    }
                    
                }
                
                
            }
            
//            var convs = [JMSGConversation]()
//
//            for conv in self.datas {
//
////                var isFlag = false //判断用户是否是群成员
//
//                if let group = conv.target as? JMSGGroup {
//
//                    let users = group.memberArray()
//
//                    for user in users {
//
//                        //判断用户是否是群成员
//                        if user.username == JMSGUser.myInfo().username {
//
//                            convs.append(conv)
//                        }
//                    }
//
//
//                }
//            }
//
//            self.datas = convs
            
            self.datas = self.sortConverstaions(self.datas)
            self.tableview.reloadData()
            if self.datas.count == 0 {
                self.emptyView.isHidden = false
            } else {
                self.emptyView.isHidden = true
            }
            self._updateBadge()
        }
    }

    fileprivate func sortConverstaions(_ convs: [JMSGConversation]) -> [JMSGConversation] {
        var stickyConvs: [JMSGConversation] = []
        var allConvs: [JMSGConversation] = []
        for index in 0..<convs.count {
            let conv = convs[index]
            if conv.ex.isSticky {
                stickyConvs.append(conv)
            } else {
                allConvs.append(conv)
            }
        }

        stickyConvs = stickyConvs.sorted(by: { (c1, c2) -> Bool in
            c1.ex.stickyTime > c2.ex.stickyTime
        })

        allConvs.insert(contentsOf: stickyConvs, at: 0)
        return allConvs
    }
    
    //MARK: - click func
    @objc func _clickNavRightButton(_ sender: UIButton) {
        _setupPopView()
    }
    
    private func _setupPopView() {
//        presentPopupView(selectView)
        
        
//        selectView.isHidden = !selectView.isHidden
        
        let configuration = FTPopOverMenuConfiguration.default()
        configuration?.textAlignment = .center
        configuration?.menuWidth = 140
        configuration?.textColor = UIColor.white
        configuration?.borderColor = UIColor.clear
        configuration?.borderWidth = 0.5
        configuration?.backgroundColor = UIColor.KTheme.deepOrange
        configuration?.menuRowHeight = 50
        configuration?.textFont = UIFont.systemFont(ofSize: 16)
        configuration?.separatorColor = UIColor.white
        configuration?.menuIconMargin = 15
        
        
        let customer_type = CacheClass.stringForEnumKey(.customer_type) ?? ""
        let gid = CacheClass.stringForEnumKey(.groupid) ?? ""
        
        
        
        if gid == "5" && customer_type == "0" {
            FTPopOverMenu.show(forSender: addButton, withMenuArray:  ["发起单聊","发起群聊","添加朋友","我的客服"], imageArray: [UIImage.loadImage("com_icon_conv_single") as Any,UIImage.loadImage("com_icon_conv_group") as Any,UIImage.loadImage("com_icon_friend_add") as Any,UIImage.init(named: "myService") as Any], configuration: configuration, doneBlock: { (selectIndex) in
                
                switch selectIndex {
                case 0:
                    let vc = SearchFriendViewController()//JCSearchFriendViewController()
                    vc.hidesBottomBarWhenPushed = true
                    vc.isSearchUser = true
                    self.navigationController?.pushViewController(vc, animated: true)
                case 1:
                    
                    
                    let vc = JCUpdateMemberViewController()
                    vc.isAddMember = false
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    
                case 2:
                    let vc = SearchFriendViewController()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                case 3:
                    let vc = MyServiceViewController()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
                
            }) {
                
            }
        }else{
            FTPopOverMenu.show(forSender: addButton, withMenuArray:  ["添加朋友","我的客服"], imageArray: [UIImage.loadImage("com_icon_friend_add") as Any,UIImage.init(named: "myService") as Any], configuration: configuration, doneBlock: { (selectIndex) in
                
                switch selectIndex {
//                case 0:
//                    let vc = SearchFriendViewController()//JCSearchFriendViewController()
//                    vc.hidesBottomBarWhenPushed = true
//                    vc.isSearchUser = true
//                    self.navigationController?.pushViewController(vc, animated: true)
//
                    
                case 0:
                    let vc = SearchFriendViewController()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                case 1:
                    let vc = MyServiceViewController()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
                
            }) {
                
            }
        }

        
        
        
        
    }
    

    
    fileprivate lazy var selectView: MorePopupView = {
        let popupView = MorePopupView(frame: CGRect(x: self.view.width - 150, y: 65, width: 145, height: 554 / 3))
        popupView.delegate = self
        return popupView
    }()
    
    //MARK: 获取客服列表
    fileprivate func getCustomService() {
        
        NetworkRequest.requestMethod(.get, URLString: url_myServiceList, parameters: nil, success: { (value, json) in
            
            
            if json["status"] == "SUCCESS" {
                
                
                if let array = json["ret_data"]["list"].arrayObject as? [[String:Any]] {
                    
                    var customServiceList = [String]()
                    
                    if let list = CacheClass.arrayForEnumKey(.customServiceList) as? [String] {
                        
                        customServiceList = list
                    }
                    
                    for item in array {
                        
                        let model = MyServiceModel.setModel(with: item)
                        
                        if  !customServiceList.contains(model.username ?? "") {
                            
                            customServiceList.append(model.username ?? "")
                        }
                    }
                    
                    CacheClass.setObject(customServiceList, forEnumKey: .customServiceList)
                    
                }
                
                
            }
            
        }) {
            
            
            
        }
    }
}

extension JCConversationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showNetworkTips ? datas.count + 1 : datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showNetworkTips && indexPath.row == 0 {
            errorTips.selectionStyle = .none
            return errorTips
        }
        return tableView.dequeueReusableCell(withIdentifier: "JCConversationCell", for: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? JCConversationCell else {
            return
        }
        cell.bindConversation(datas[showNetworkTips ? indexPath.row - 1 : indexPath.row])
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if showNetworkTips && indexPath.row == 0 {
            return 40
        }
        return 65
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        selectView.isHidden = true
        
        if showNetworkTips && indexPath.row == 0 {
            return 
        }
        let conversation = datas[showNetworkTips ? indexPath.row - 1 : indexPath.row]
        conversation.clearUnreadCount()
        
        //如果是群会话
        if let target = conversation.target as? JMSGGroup {
            //保存未读消息数
            CacheClass.setObject("0", forEnumKey: JMSGUser.myInfo().username + target.gid)
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? JCConversationCell else {
            return
        }
        cell.bindConversation(conversation)
        
        let vc = JCChatViewController(conversation: conversation)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action1 = UITableViewRowAction(style: .destructive, title: "删除") { (action, indexPath) in
            self._delete(indexPath)
        }
        let conversation = datas[showNetworkTips ? indexPath.row - 1 : indexPath.row]
        let action2 = UITableViewRowAction(style: .normal, title: "置顶") { (action, indexPath) in
            conversation.ex.isSticky = !conversation.ex.isSticky
            self._getConversations()
        }
        if conversation.ex.isSticky {
            action2.title = "取消置顶"
        } else {
            action2.title = "置顶"
        }
        return [action1, action2]
    }

    private func _delete(_ indexPath: IndexPath) {
        let conversation = datas[indexPath.row]
        let tager = conversation.target
        JCDraft.update(text: nil, conversation: conversation)
        if conversation.ex.isGroup {
            guard let group = tager as? JMSGGroup else {
                return
            }
            JMSGConversation.deleteGroupConversation(withGroupId: group.gid)
            
            if let taget = conversation.target as? JMSGGroup {
                CacheClass.setObject("0", forEnumKey: JMSGUser.myInfo().username + taget.gid)
            }
            
        } else {
            guard let user = tager as? JMSGUser else {
                return
            }
            JMSGConversation.deleteSingleConversation(withUsername: user.username, appKey: user.appKey!)
        }
        datas.remove(at: indexPath.row)
        if datas.count == 0 {
            emptyView.isHidden = false
        } else {
            emptyView.isHidden = true
        }
        tableview.reloadData()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateConversation), object: nil, userInfo: nil)
    }
    
}

extension JCConversationListViewController: MorePopupViewDelegate {
    func popupView(view: MorePopupView, addGroup addButton: UIButton) {
//        dismissPopupView()
//        selectView.isHidden = true
        let vc = JCUpdateMemberViewController()
        vc.isAddMember = false
        navigationController?.pushViewController(vc, animated: true)
    }

    func popupView(view: MorePopupView, addFriend addButton: UIButton) {
//        dismissPopupView()
//        selectView.isHidden = true
        navigationController?.pushViewController(JCSearchFriendViewController(), animated: true)
    }

    func popupView(view: MorePopupView, addSingle addButton: UIButton) {
//        dismissPopupView()
//        selectView.isHidden = true
        let vc = JCSearchFriendViewController()
        vc.isSearchUser = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func popupView(view: MorePopupView, scanQRCode addButton: UIButton) {
//        dismissPopupView()
//        selectView.isHidden = true
        let vc = ScanQRCodeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension JCConversationListViewController: JMessageDelegate {
    
    func onReceive(_ message: JMSGMessage!, error: Error!) {
        _getConversations()
    }

    func onConversationChanged(_ conversation: JMSGConversation!) {
        _getConversations()
    }

    func onGroupInfoChanged(_ group: JMSGGroup!) {
        _getConversations()
    }

    func onSyncRoamingMessageConversation(_ conversation: JMSGConversation!) {
        _getConversations()
    }

    func onSyncOfflineMessageConversation(_ conversation: JMSGConversation!, offlineMessages: [JMSGMessage]!) {
        _getConversations()
    }

    func onReceive(_ retractEvent: JMSGMessageRetractEvent!) {
        _getConversations()
    }
    
}

extension JCConversationListViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        tableview.isHidden = true
        emptyView.isHidden = true
//        UIView.animate(withDuration: 0.35, animations: {
            self.emptyView.frame = CGRect(x: 0, y: StatusBarAddNavBarHeight+20, width: self.view.width, height: self.view.height - 64)
//        }) { (_) in
            self.navigationController?.tabBarController?.tabBar.isHidden = true
//        }
    }
    func willDismissSearchController(_ searchController: UISearchController) {
//        UIView.animate(withDuration: 0.35) {
            self.emptyView.frame = CGRect(x: 0, y: StatusBarAddNavBarHeight + 55, width: self.view.width, height: self.view.height - StatusBarAddNavBarHeight - 36)
//        }
        tableview.isHidden = false
        if datas.count == 0 {
            emptyView.isHidden = false
        }
//        let nav = searchController.searchResultsController as! JCNavigationController
//        nav.isNavigationBarHidden = true
//        nav.popToRootViewController(animated: false)
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - network tips
extension JCConversationListViewController {
    
    func reachable() {
        if !showNetworkTips {
            return
        }
        showNetworkTips = false
        tableview.reloadData()
    }
    
    func notReachable() {
        if showNetworkTips {
            return
        }
        showNetworkTips = true
        if datas.count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            tableview.beginUpdates()
            tableview.insertRows(at: [indexPath], with: .automatic)
            tableview.endUpdates()
        } else {
            tableview.reloadData()
        }
    }
    
    @objc func connectClose() {
        isConnecting = false
        titleTipsView.isHidden = true
    }
    
    @objc func connectSucceed() {
        
        
        DispatchQueue.main.async {
            self.isConnecting = false
            self.titleTipsView.isHidden = true
        }
        
    }
    
    @objc func connecting() {
        _connectingSate()
    }
    
    func _connectingSate() {
        let window = UIApplication.shared.delegate?.window
        if let window = window {
            guard let rootViewController = window?.rootViewController as? JCMainTabBarController else {
                return
            }
            guard let nav = rootViewController.selectedViewController as? JCNavigationController else {
                return
            }
            guard let currentVC = nav.topViewController else {
                return
            }
            if currentVC.isKind(of: JCConversationListViewController.self) {
                isConnecting = true
                titleTips.text = "连接中"
                titleTipsView.isHidden = false
            }
        }
    }
}
