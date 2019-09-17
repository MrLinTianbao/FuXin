//
//  JCContactsViewController.swift
//  JChat
//
//  Created by JIGUANG on 2017/2/16.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

class JCContactsViewController: CTViewController {
    
    public required init() {
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_updateBadge), name: NSNotification.Name(rawValue: kUpdateVerification), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        _init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _updateBadge()
        _getFriends()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private lazy var addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    fileprivate lazy var contacterView: UITableView = {
        var contacterView = UITableView(frame: .zero, style: .grouped)
        contacterView.delegate = self
        contacterView.dataSource = self
        contacterView.separatorStyle = .none
        contacterView.sectionIndexColor = UIColor.KTheme.black//UIColor(netHex: 0x2dd0cf)
        contacterView.sectionIndexBackgroundColor = .clear
        contacterView.backgroundColor = UIColor.KTheme.notice
        return contacterView
    }()
    let searchVC = JCSearchResultViewController()
    private lazy var searchController: UISearchController = UISearchController(searchResultsController: searchVC)
    private lazy var searchView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 55))
    var badgeCount = 0
    var newFriedbadgeCount = 0
    var groupBadgeCount = 0
    
    fileprivate lazy var tagArray = ["我的客服","添加好友","新好友", "群组", "群通知"]
    fileprivate lazy var users: [JMSGUser] = []
    
    fileprivate lazy var keys: [String] = []
    fileprivate lazy var data: Dictionary<String, [JMSGUser]> = Dictionary()
    
    //MARK: - private func
    private func _init() {
        
//        self.navigationController?.navigationBar.isTranslucent = true
        
        self.title = "通讯录"
        view.backgroundColor = UIColor(netHex: 0xe8edf3)
        
        if #available(iOS 10.0, *) {
            navigationController?.tabBarItem.badgeColor = UIColor(netHex: 0xEB424C)
        }
        
//        let nav = searchController.searchResultsController as! JCNavigationController
//        let vc = nav.topViewController as! JCSearchResultViewController
        
        searchController.delegate = self
        searchController.searchResultsUpdater = searchVC
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "搜索";
//        searchController.searchBar.tintColor = UIColor.KTheme.deepOrange
//        searchController.delegate = self
        
        searchView.backgroundColor = UIColor.KTheme.scroll
//        searchView.addSubview(searchController.searchBar)
//        contacterView.tableHeaderView = searchView
        //        searchView.backgroundColor = UIColor.red
        
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController;
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }else{
            contacterView.tableHeaderView = searchController.searchBar
        }
        self.definesPresentationContext = true
        self.searchVC.nav = self.navigationController

        
        contacterView.register(JCContacterCell.self, forCellReuseIdentifier: "JCContacterCell")
        contacterView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height-StatusBarAddNavBarHeight-65)
        view.addSubview(contacterView)
        
        _setupNavigation()
        _getFriends()
        _updateBadge()
        
        NotificationCenter.default.addObserver(self, selector: #selector(_updateUserInfo), name: NSNotification.Name(rawValue: kUpdateFriendInfo), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_getFriends), name: NSNotification.Name(rawValue: kUpdateFriendList), object: nil)
    }
    
    private func _setupNavigation() {
        addButton.addTarget(self, action: #selector(_clickNavRightButton(_:)), for: .touchUpInside)
        addButton.setImage(UIImage.init(named: "addFri"), for: .normal)
        let item = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem =  item
    }
    
    
    @objc func _updateUserInfo() {
        _classify(users)
        contacterView.reloadData()
    }
    
    func _classify(_ users: [JMSGUser]) {
        self.users = users
        keys.removeAll()
        data.removeAll()
        for item in users {
            var key = item.displayName().firstCharacter()
            if !key.isLetterOrNum() {
                key = "#"
            }
            var array = data[key]
            if array == nil {
                array = [item]
            } else {
                array?.append(item)
            }
            if !keys.contains(key) {
                keys.append(key)
            }
            data[key] = array
        }
        keys = keys.sortedKeys()
    }
    
    @objc func _getFriends() {
        
        JMSGFriendManager.getFriendList { (result, error) in
            if let users = result as? [JMSGUser] {
                self._classify(users)
                self.contacterView.reloadData()
            }
        }
    }
    
    //MARK: - click func
    @objc func _clickNavRightButton(_ sender: UIButton) {
        let vc = SearchFriendViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func _updateBadge() {
        if UserDefaults.standard.object(forKey: kUnreadInvitationCount) != nil {
            newFriedbadgeCount = UserDefaults.standard.object(forKey: kUnreadInvitationCount) as! Int
        } else {
            newFriedbadgeCount = 0
        }
//        if badgeCount > 99 {
//            self.rt_navigationController.tabBarItem.badgeValue = "99+"
//        } else {
//            self.rt_navigationController.tabBarItem.badgeValue = badgeCount == 0 ? nil : "\(badgeCount)"
//        }
        
        
        //***群通知**mj**
        if UserDefaults.standard.object(forKey: kUnreadGroupInvitationCount) != nil {
            groupBadgeCount = UserDefaults.standard.object(forKey: kUnreadGroupInvitationCount) as! Int
        }
        badgeCount = newFriedbadgeCount + groupBadgeCount
        if badgeCount > 99 {
            self.rt_navigationController.tabBarItem.badgeValue = "99+"
        } else {
            self.rt_navigationController.tabBarItem.badgeValue = badgeCount == 0 ? nil : "\(badgeCount)"
        }
        contacterView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)

    }
    
}

//Mark: -
extension JCContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if users.count > 0 {
            return keys.count + 1
        }
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tagArray.count
        }
        return data[keys[section - 1]]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }
        return keys[section - 1]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return keys
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        }
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "JCContacterCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? JCContacterCell else {
            return
        }
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.title = "我的客服"
                cell.icon = UIImage.init(named: "custom_service")
            case 1:
                cell.title = "添加好友"
                cell.icon = UIImage.init(named: "addFriend")
            case 2:
                cell.title = "新好友"
                cell.icon = UIImage.init(named: "newFriend")
                cell.isShowBadge = newFriedbadgeCount > 0 ? true : false
            case 3:
                cell.title = "群组"
                cell.icon = UIImage.loadImage("com_icon_group_36")
                cell.isShowBadge = false
            case 4:
                cell.title = "群通知"
                cell.icon = UIImage.loadImage("com_icon_group_36")
                cell.isShowBadge = groupBadgeCount > 0 ? true : false
            default:
                break
            }
            return
        }
        let user = data[keys[indexPath.section - 1]]?[indexPath.row]
        cell.isShowBadge = false
        cell.bindDate(user!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let vc = MyServiceViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                
                let vc = SearchFriendViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                navigationController?.pushViewController(JCIdentityVerificationViewController(), animated: true)
            case 3:
                navigationController?.pushViewController(JCGroupListViewController(), animated: true)
            case 4:
                navigationController?.pushViewController(JCGroupJoinVerificationVC(), animated: true)
            default:
                break
            }
            return
        }
        let vc = ChatPersonalCenterVC()//JCUserInfoViewController()
        let user = data[keys[indexPath.section - 1]]?[indexPath.row]
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension JCContactsViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        self.edgesForExtendedLayout = .bottom;
        
        self.searchVC.reloadSource()
        contacterView.isHidden = true
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    func willDismissSearchController(_ searchController: UISearchController) {
         self.edgesForExtendedLayout = .bottom;
        contacterView.isHidden = false
//        let nav = searchController.searchResultsController as! JCNavigationController
//        nav.isNavigationBarHidden = true
//        nav.popToRootViewController(animated: false)
        navigationController?.tabBarController?.tabBar.isHidden = false
        
        
        
    }
}



